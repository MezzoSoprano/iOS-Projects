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
        
        tableView.register(StationTableCell.self, forCellReuseIdentifier: tableCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = LightTheme.background
        
        // constarints adding
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
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID, for: indexPath) as! StationTableCell
        cell.configure(with: showedStaions[indexPath.row])
        return cell
    }
}
