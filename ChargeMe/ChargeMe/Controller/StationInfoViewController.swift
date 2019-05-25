//
//  CharherInfoViewController.swift
//  ChargeMe
//
//  Created by Святослав Катола on 2/19/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit
import moa
import Auk
import GravitySliderFlowLayout

class StationInfoViewController: UIViewController {
    
    var receivedStaition: ChargeStation?
    var viewModel: ChargeInfoViewModel!
    
    @IBOutlet weak var chargerPhotosScrollView: UIScrollView!
    @IBOutlet weak var socketCollectionView: UICollectionView!
    @IBOutlet weak var addreNameLabel: UILabel!
    @IBOutlet weak var distanceSocketsLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var contactWebSiteLabel: UILabel!
    @IBOutlet weak var payImageView: UIImageView!
    
    let gravitySliderLayout = GravitySliderFlowLayout(with: CGSize(width: 400, height: 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChargeInfoViewModel(station: receivedStaition!)
        viewModel.configureWith(view: self)
        
        chargerPhotosScrollView.auk.settings.contentMode = UIView.ContentMode.scaleAspectFit
        chargerPhotosScrollView.backgroundColor = UIColor(r: 154, g: 244, b: 204)
    
        socketCollectionView.collectionViewLayout = gravitySliderLayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let station = receivedStaition {
            if station.needPayForLocation {
                payImageView.image = UIImage(named: "dollar")
            }
        }
    }
}

extension StationInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedStaition!.socketTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = socketCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SocketViewCell
        cell.configureWith(socket: receivedStaition!.socketTypes[indexPath.row], name: viewModel.socketsNames[indexPath.row])
        return cell
    }
}
