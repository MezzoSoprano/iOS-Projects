//
//  ViewController.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/19/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit
import MapKit
import Lottie
import CoreLocation

var showedStaions: [ChargeStation] = []
class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var selectedRangeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var sideStackView: UIStackView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var goHomeButton: UIButton!
    
    
    let tableAutocomplete = UITableView()
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    //custom views
    var goButton: UIButton = {
        let gb = UIButton()
        gb.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        gb.translatesAutoresizingMaskIntoConstraints = false
        gb.setTitle("Go", for: .normal)
        gb.layer.cornerRadius = 30
        gb.setShadow()
        return gb
    }()
    
    var progressIndicator: UIActivityIndicatorView = {
        let pi = UIActivityIndicatorView(style: .whiteLarge)
        pi.color = UIColor(r: 127, g: 181, b: 181)
        return pi
    }()
    
    var selectedAnnotation: MKAnnotationView?
    var selectedCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)
    
    let locationManager = CLLocationManager()
    lazy var stationManager = APIStaionsManager(sessionConfiguration: URLSessionConfiguration.default)
    
    let blurViewMap: UIVisualEffectView = {
        let lightBlur = UIBlurEffect(style: UIBlurEffect.Style.light)
        return UIVisualEffectView(effect: lightBlur)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
        
        refreshButton.setLightShadow()
        searchButton.setLightShadow()
        filterButton.setLightShadow()
        goHomeButton.setLightShadow()
        
        //getting the slider released method
        self.slider.addTarget(self, action: #selector(rangeRealesed), for: .touchUpInside)
        
        checkLocationservices()
        if locationManager.location != nil {
            selectedCoordinates = locationManager.location!.coordinate
        }
        
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showStations(near coordinates: CLLocationCoordinate2D, distance: Double) {
        stationManager.fetchStationsWith(coordinates: coordinates, radius: distance) { (result) in
            
            switch result {
            case .Success(let nearStations):
                
                if nearStations.count == 0 {
                    self.createAlert(title: "Couldn't find charge stations", message: "Sorry, there ara no any charge stations near selected region with distance \(distance) km")
                    self.centerView(with: coordinates, region: Double(self.selectedRangeLabel.text!)!)
                } else {
                    print(nearStations.count)
                    
                    self.mapView.removeAnnotations(self.mapView.annotations.filter({ $0.coordinate.latitude != self.selectedCoordinates.latitude && $0.coordinate.longitude != self.selectedCoordinates.longitude
                    }))
                    for item in nearStations {
                        
                        let annotaion: MKAnnotation = item.createAnnotaion()
                        self.mapView.addAnnotation(annotaion)
                        
                    }
                    showedStaions = nearStations
                    self.centerView(with: coordinates, region: Double(self.selectedRangeLabel.text!)!)
                }
            case .Failure(let error as NSError):
                
                let alert = UIAlertController(title: "Unable to get data", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
                    self.showStations(near: coordinates, distance: distance)
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            default: break
            }
            
            self.progressIndicator.removeFromSuperview()
            self.refreshButton.layer.removeAllAnimations()
            self.refreshButton.isEnabled = true
            self.searchButton.isEnabled = true
            self.longPressGesture.isEnabled = true
        }
        
        self.longPressGesture.isEnabled = false
        self.refreshButton.isEnabled = false
        self.searchButton.isEnabled = false
        self.progressIndicator.center = self.view.center
        self.progressIndicator.startAnimating()
        self.view.addSubview(progressIndicator)
    }
    
    func centerView(with coordinates: CLLocationCoordinate2D, region: Double) {
        let regionKM = region * 1800
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionKM, longitudinalMeters: regionKM)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showModally" {
                if let viewController = segue.destination as? FilterViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                }
            } else if identifier == "swgueToInfo" {
                if let sa = selectedAnnotation, let vc = segue.destination as? StationInfoViewController {
                    vc.receivedStaition = showedStaions.first(where: { $0.AddressInfo?.Latitude == sa.annotation?.coordinate.latitude && $0.AddressInfo?.Longitude == sa.annotation?.coordinate.longitude})
                }
            }
        }
    }
}

// MARK: - Actions

extension MainViewController {
    
    @IBAction func filter(_ sender: Any) {
        filterButton.lightAnimate {() in self.definesPresentationContext = true
            self.providesPresentationContextTransitionStyle = true
            
            self.overlayBlurredBackgroundView()
            self.performSegue(withIdentifier: "showModally", sender: nil)}
    }
    
    @IBAction func goToHome(_ sender: Any) {
        goHomeButton.lightAnimate {}
        
        if let location = self.locationManager.location {
            self.selectedCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.centerView(with: self.selectedCoordinates, region: 20)
        } else {
            self.checkLocationservices()
        }
    }
    
    @objc func rangeRealesed() {
        rotateAnimation(view: refreshButton)
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        rotateAnimation(view: refreshButton)
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
    }
    
    @IBAction func rangeChanged(_ sender: UISlider) {
        selectedRangeLabel.text = String(Int(sender.value))
    }
    
    @IBAction func longMapPressed(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        //creating pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.selectedCoordinates = coordinate
        self.mapView.addAnnotation(annotation)
        
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
    }
    
    @objc func goButtonPressed(sender: Any) {
        
        if selectedAnnotation != nil, let location = selectedAnnotation!.annotation as? ChargeStationAnnotation {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
            
        } else {
            createAlert(title: "Couldn't build the  route", message: "Select the staion or/and location")
        }
    }
}

// MARK: - Location Manager

extension MainViewController : CLLocationManagerDelegate {
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation(regionInKM: Double(selectedRangeLabel.text!)!)
            locationManager.startUpdatingLocation()
            break
        case .denied:
            self.createAlert(title: "Couldn't get your location", message: "You denied the use of location services for this app or location services are currently disabled in Settings.")
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.createAlert(title: "Couldn't get your location", message: "This app is not authorized to use location services possibly due to active restrictions such as parental control.")
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationservices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            self.createAlert(title: "Couldn't get your location", message: "Location services are currently disabled in Settings.")
        }
    }
    
    func centerViewOnUserLocation(regionInKM: Double) {
        let regionKM = regionInKM * 1800
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionKM, longitudinalMeters: regionKM)
            mapView.setRegion(region, animated: true)
        } else { print("Couldnt get location!")}
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

// MARK: - Map View Delegate

extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? ChargeStationAnnotation else { return nil }
        let identifier = "marker"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 0)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if (annotation.title!.contains("Tesla")) {
            view.image = UIImage(named: "superChargerPin")
        } else if (annotation.title!.contains("CHAdeMO")) {
            view.image = UIImage(named: "chademoChargerPin")
        } else {
            view.image = UIImage(named: "chargerPin")
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        self.selectedAnnotation = view
        if let myLocation = locationManager.location?.coordinate {
            if selectedAnnotation?.annotation?.coordinate.latitude == myLocation.latitude && selectedAnnotation?.annotation?.coordinate.longitude == myLocation.longitude {
                return
            }
        }
        
        //go button configuration
        self.goButton.backgroundColor = .darkGray
        self.view.addSubview(goButton)
        NSLayoutConstraint.activate([
            goButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            goButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            goButton.widthAnchor.constraint(equalToConstant: 60),
            goButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        
        goButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                        UIView.animate(withDuration: 5) {
                            self.sideStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
                        }
                        self.goButton.transform = .identity
                        self.goButton.backgroundColor = UIColor(r: 127, g: 181, b: 181)
        }, completion: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.goButton.removeFromSuperview()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "swgueToInfo", sender: nil)
    }
}

// MARK: - Modal View Presenting

extension MainViewController: ModalViewControllerDelegate {
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        self.tabBarController?.tabBar.isHidden = false
    }
}

