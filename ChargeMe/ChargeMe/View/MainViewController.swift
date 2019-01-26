//
//  ViewController.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/19/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshOutlet: UIButton!
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var selectedRange: UILabel!
    
    let goButton: UIButton = UIButton()
    var selectedAnnotation: MKAnnotationView?
    
    let locationManager = CLLocationManager()
    
    lazy var stationManager = APIStaionsManager(sessionConfiguration: URLSessionConfiguration.default, viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsCompass = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationservices()
        
        if let location = locationManager.location {
                self.showStations(near: Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), distance: Double(self.selectedRange.text!)!, sender: self)
        } else { print("couldnt get location") }
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        
        if let location = locationManager.location {
            refreshOutlet.isEnabled = false
            rotateAnimation(view: refreshOutlet)
            showStations(near: Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), distance: Double(selectedRange.text!)!, sender: self)
            //refreshOutlet.isEnabled = true
        } else { print("couldnt get location") }
    }
    
    @IBAction func rangeChanged(_ sender: UISlider) {
        selectedRange.text = String(Int(sender.value))
    }
    
    @IBAction func seartchTapped(_ sender: Any) {
        
        searchOutlet.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.searchOutlet.transform = .identity
        },
                       completion: nil)
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
    
    func showStations(near coordinates: Coordinates, distance: Double, sender: AnyObject) {
        stationManager.fetchStationsWith(coordinates: coordinates, radius: distance, sender: sender) { (result) in
            switch result {
            case .Success(let nearStations):
                
                if nearStations.count == 0 {
                    self.createAlert(title: "Couldn't find charge stations", message: "Sorry, there ara no any charge stations near you with distance \(distance) km")
                } else {
                print(nearStations.count)
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                for item in nearStations {
                        print("\(item.ID ?? 1) + \(item.GeneralComments ?? "null") + \(item.OperatorInfo?.Title ?? "null")")
                    
                        let annotaion = item.createAnnotaion()
                        self.mapView.addAnnotation(annotaion)
                    }
                        self.centerViewOnUserLocation(regionInKM: Double(self.selectedRange.text!)!)
                }
            case .Failure(let error as NSError):
                
                let alert = UIAlertController(title: "Unable to get data", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
                    self.showStations(near: coordinates, distance: distance, sender: sender)
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation(regionInKM: Double(selectedRange.text!)!)
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
        }
    }
    
    @objc func goButtonPressed(sender: Any) {
        
        if selectedAnnotation != nil {
            let location = selectedAnnotation!.annotation as! ChargeStationAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        } else {
            createAlert(title: "Couldn't build the  route", message: "Sorry, we couldn't build this route")
        }
    }
}

extension MainViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MainViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? ChargeStationAnnotation else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
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
        //button creating
        goButton.backgroundColor = .darkGray
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        goButton.layer.cornerRadius = 30
        goButton.setTitle("Go", for: .normal)
        goButton.setShadow()
        
        self.view.addSubview(goButton)
        goButton.translatesAutoresizingMaskIntoConstraints = false
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
                        self.goButton.transform = .identity
                        self.goButton.backgroundColor = UIColor(r: 127, g: 181, b: 181)
            },
                       completion: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.goButton.removeFromSuperview()
    }
}
