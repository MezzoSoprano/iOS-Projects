//
//  TableViewController.swift
//  ChargeMe
//
//  Created by Святослав Катола on 2/16/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    let tableCellID = "CellID"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        self.view.backgroundColor = LightTheme.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    private func setupTableView() {
        self.view.addSubview(tableView)
        
        tableView.register(tableCell.self, forCellReuseIdentifier: tableCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = LightTheme.background
        
        //constarints adding
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showedStaions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID, for: indexPath) as! tableCell
        
        cell.nameLabel.text = showedStaions[indexPath.row].AddressInfo?.Title
        
        //govnokod
        if let distance = showedStaions[indexPath.row].AddressInfo?.Distance {
            var doubleStr = String(format: "%.2f", distance)
            doubleStr += " km"
            if showedStaions[indexPath.row].Connections.count > 0 {
                doubleStr += ", "
                for item in showedStaions[indexPath.row].Connections {
                    if item?.ConnectionType?.Title == showedStaions[indexPath.row].Connections.last!?.ConnectionType?.Title {
                        doubleStr += (item?.ConnectionType?.Title!)!
                        break
                    }
                    doubleStr += (item?.ConnectionType?.Title!)! + ", "
                }
                
            }
            cell.distanceLabel.text = doubleStr
            
            if cell.distanceLabel.text!.contains("Tesla") {
                cell.pictureImageView.image = UIImage(named: "superChargerPin")
            } else if cell.distanceLabel.text!.contains("CHAdeMO") {
                cell.pictureImageView.image = UIImage(named: "chademoChargerPin")
            } else {
                cell.pictureImageView.image = UIImage(named: "chargerPin")
            }
        }
        
        return cell
    }
    
}
