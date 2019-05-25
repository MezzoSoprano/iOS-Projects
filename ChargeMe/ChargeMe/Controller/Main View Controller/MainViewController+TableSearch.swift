//
//  MainViewController+TableSearch.swift
//  ChargeMe
//
//  Created by Svyatoslav Katola on 5/13/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Search Bar delegate

extension MainViewController: UISearchBarDelegate {
    
    @IBAction func seartchTapped(_ sender: Any) {
        
        searchButton.lightAnimate { () in
            self.showStackView(bool: false)
            self.blurViewMap.frame = self.mapView.bounds
            self.mapView.addSubview(self.blurViewMap)
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.obscuresBackgroundDuringPresentation = false
        self.present(searchController, animated: true, completion: nil)
        
        self.setupTableView()
        
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
                self.showStations(near: self.selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
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
            self.selectedRangeLabel.isHidden = false
        } else {
            self.topStackView.isHidden = true
            self.selectedRangeLabel.isHidden = true
        }
    }
}

// MARK: - Table View Completer

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            
            if error != nil {
                print(error!.localizedDescription)
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
                self.showStations(near: self.selectedCoordinates, distance: Double(self.selectedRangeLabel.text!)!)
                
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.showStackView(bool: true)
            self.tableAutocomplete.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
            self.blurViewMap.removeFromSuperview()
        }
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

// MARK: - Local Search Completer

extension MainViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableAutocomplete.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.createAlert(title: "Error", message: error.localizedDescription)
    }
}
