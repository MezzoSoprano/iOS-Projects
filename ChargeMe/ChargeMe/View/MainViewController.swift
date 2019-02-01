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

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshOutlet: UIButton!
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var selectedRange: UILabel!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var goToMyLocation: LOTAnimationView!
    @IBOutlet weak var settingsOutlet: LOTAnimationView!
    
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
        
        goToMyLocation.setAnimation(named: "location")
        goToMyLocation.play()
        goToMyLocation.setLightShadow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToInitialCoordinates))
        goToMyLocation.addGestureRecognizer(tapGesture)
        goToMyLocation.isUserInteractionEnabled = true
        goToMyLocation.translatesAutoresizingMaskIntoConstraints = false
        
        settingsOutlet.setAnimation(named: "settings1")
        settingsOutlet.play()
        settingsOutlet.setLightShadow()
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        settingsOutlet.addGestureRecognizer(tapGest)
        settingsOutlet.isUserInteractionEnabled = true
        settingsOutlet.translatesAutoresizingMaskIntoConstraints = false
        
        refreshOutlet.setLightShadow()
        searchOutlet.setLightShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationservices()
        
        if locationManager.location != nil {
            selectedCoordinates = locationManager.location!.coordinate
        }
        
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRange.text!)!)
    }
    
    func showStations(near coordinates: CLLocationCoordinate2D, distance: Double) {
        stationManager.fetchStationsWith(coordinates: coordinates, radius: distance) { (result) in
            
            switch result {
            case .Success(let nearStations):
                
                if nearStations.count == 0 {
                    self.createAlert(title: "Couldn't find charge stations", message: "Sorry, there ara no any charge stations near you with distance \(distance) km")
                    self.centerView(with: coordinates, region: Double(self.selectedRange.text!)!)
                } else {
                    print(nearStations.count)
                    
                    self.mapView.removeAnnotations(self.mapView.annotations.filter({ $0.coordinate.latitude != self.selectedCoordinates.latitude && $0.coordinate.longitude != self.selectedCoordinates.longitude
                    }))
                    for item in nearStations {
                        print("\(item.ID ?? 1) + \(item.GeneralComments ?? "null") + \(item.OperatorInfo?.Title ?? "null")")
                        
                        let annotaion = item.createAnnotaion()
                        self.mapView.addAnnotation(annotaion)
                    }
                    self.centerView(with: coordinates, region: Double(self.selectedRange.text!)!)
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
            self.refreshOutlet.layer.removeAllAnimations()
            self.refreshOutlet.isEnabled = true
            self.searchOutlet.isEnabled = true
        }
        
        self.refreshOutlet.isEnabled = false
        self.searchOutlet.isEnabled = false
        self.progressIndicator.center = self.view.center
        self.progressIndicator.startAnimating()
        
        self.view.addSubview(progressIndicator)
    }
    
    func centerView(with coordinates: CLLocationCoordinate2D, region: Double) {
        let regionKM = region * 1800
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionKM, longitudinalMeters: regionKM)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func settingsTapped() {
        settingsOutlet.play()
    }
    
    @objc func goToInitialCoordinates() {
        goToMyLocation.play()
        
        
        if let location = locationManager.location {
            selectedCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            centerView(with: selectedCoordinates, region: Double(self.selectedRange.text!)!)
        }
    }

    @IBAction func refreshTapped(_ sender: Any) {
        rotateAnimation(view: refreshOutlet)
        self.showStations(near: selectedCoordinates, distance: Double(self.selectedRange.text!)!)
    }
    
    @IBAction func rangeChanged(_ sender: UISlider) {
        selectedRange.text = String(Int(sender.value))
    }
    
}

extension MainViewController : CLLocationManagerDelegate {
    
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
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 0)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if (annotation.title!.contains("Tesla")) {
                view.image = UIImage(named: "superChargerPin")
                print("\(annotation.title!) contains Tesla")
            } else { view.image = UIImage(named: "chargerPin")
                print("\(annotation.title!) doenst contains Tesla") }
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
                            self.goToMyLocation.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
                        }
                        self.goButton.transform = .identity
                        self.goButton.backgroundColor = UIColor(r: 127, g: 181, b: 181)
        }, completion: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.goButton.removeFromSuperview()
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

extension MainViewController: UISearchBarDelegate {
    
    @IBAction func seartchTapped(_ sender: Any) {

        searchOutlet.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.searchOutlet.transform = .identity
                
        }) { (isFinished) in
            UIView.animate(withDuration: 0.5, animations: {
                self.showStackView(bool: false)
                self.blurViewMap.frame = self.mapView.bounds
                self.mapView.addSubview(self.blurViewMap)
            }, completion: nil)
            
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.delegate = self
            searchController.searchBar.searchBarStyle = .minimal
            searchController.obscuresBackgroundDuringPresentation = false
            self.present(searchController, animated: true, completion: nil)
            
            self.setupTableView()
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity Indicator
        self.progressIndicator.startAnimating()
        self.view.addSubview(progressIndicator)
        
        //Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            self.progressIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("ERROR")
            } else {
                //Getting data
                let latitude = response?.mapItems[0].placemark.coordinate.latitude
                let longitude = response?.mapItems[0].placemark.coordinate.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()

                annotation.title = response?.mapItems[0].name
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.selectedCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                self.mapView.addAnnotation(annotation)
                
                //Zooming in on annotation
                self.showStations(near: self.selectedCoordinates, distance: Double(self.selectedRange.text!)!)
                
            }
            
        }
    }
    
    private func setupTableView() {
        
        //table view presenting
        self.view.addSubview(self.tableAutocomplete)

        self.tableAutocomplete.dataSource = self
        self.tableAutocomplete.delegate = self
        self.tableAutocomplete.backgroundColor = .clear
        
        //constarints adding
        self.tableAutocomplete.translatesAutoresizingMaskIntoConstraints = false
        self.tableAutocomplete.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        self.tableAutocomplete.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        self.tableAutocomplete.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor).isActive = true
        self.tableAutocomplete.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.showStackView(bool: true)
            self.tableAutocomplete.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
            self.blurViewMap.removeFromSuperview()
        }
    }
    
    func showStackView(bool: Bool) {
        if bool {
            self.topStackView.isHidden = false
            self.selectedRange.isHidden = false
        } else {
            self.topStackView.isHidden = true
            self.selectedRange.isHidden = true
        }
    }
}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        cell.backgroundColor = .clear
        
        cell.textLabel?.attributedText = highlightedText(searchResult.title, inRanges: searchResult.titleHighlightRanges, size: 17.0)
        cell.detailTextLabel?.attributedText = highlightedText(searchResult.subtitle, inRanges: searchResult.subtitleHighlightRanges, size: 12.0)
        return cell
    }
    
    func highlightedText(_ text: String, inRanges ranges: [NSValue], size: CGFloat) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let regular = UIFont.systemFont(ofSize: size)
        attributedText.addAttribute(NSAttributedString.Key.font, value:regular, range:NSMakeRange(0, text.count))
        
        let bold = UIFont.boldSystemFont(ofSize: size)
        for value in ranges {
            attributedText.addAttribute(NSAttributedString.Key.font, value:bold, range:value.rangeValue)
        }
        return attributedText
    }

}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity Indicator
        self.progressIndicator.startAnimating()
        self.view.addSubview(progressIndicator)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.progressIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("ERROR")
            } else {
                //Getting data
                let latitude = response?.mapItems[0].placemark.coordinate.latitude
                let longitude = response?.mapItems[0].placemark.coordinate.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()
                
                annotation.title = response?.mapItems[0].name
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.selectedCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                self.mapView.addAnnotation(annotation)
                
                //Zooming in on annotation
                self.showStations(near: self.selectedCoordinates, distance: Double(self.selectedRange.text!)!)
                
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.showStackView(bool: true)
            self.tableAutocomplete.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
            self.blurViewMap.removeFromSuperview()
        }
    }
}

extension MainViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableAutocomplete.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

