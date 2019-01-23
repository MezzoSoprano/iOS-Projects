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
    
    let goButton: UIButton = UIButton()
    var selectedAnnotation: MKAnnotationView?
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 5000
    
    lazy var stationManager = APIStaionsManager(sessionConfiguration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let trackingButton = MKUserTrackingBarButtonItem(mapView: mapView)
//        trackingButton.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 35, height: 35))
//        mapView.addSubview(trackingButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationservices()
        
        if let location = locationManager.location {
            showStations(near: Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), distance: 200)
        } else { print("couldnt get location") }
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
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        } else { print("Couldnt get location!")}
    }
    
    func showStations(near coordinates: Coordinates, distance: Double) {
        stationManager.fetchStationsWith(coordinates: coordinates, radius: distance) { (result) in
            switch result {
            case .Success(let nearStations):
                if nearStations.count == 0 {
                    self.createAlert(title: "Couldn't find charge stations", message: "Sorry, there ara no any charge stations near you with distance \(distance) km")
                }
                print(nearStations.count)
                
                for item in nearStations {
    
                    print("\(item.ID ?? 1) + \(item.GeneralComments ?? "null") + \(item.OperatorInfo?.Title ?? "null")")
                    
                    let annotaion = item.createAnnotaion()
                    self.mapView.addAnnotation(annotaion)
                }
            case .Failure(let error as NSError):
                self.createAlert(title: "Unable to get data", message: "\(error.localizedDescription)")
            default: break
            }
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
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
    
    @objc func buttonAction(sender: UIButton!) {
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
        
        //button creating
        goButton.backgroundColor = .gray
        goButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        goButton.layer.cornerRadius = 30
        goButton.setTitle("Go", for: .normal)
        
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
