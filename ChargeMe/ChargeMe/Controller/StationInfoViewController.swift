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
    
    let gravitySliderLayout = GravitySliderFlowLayout(with: CGSize(width: 400, height: 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChargeInfoViewModel(station: receivedStaition!)
        viewModel.configureWith(view: self)
        
        chargerPhotosScrollView.auk.settings.contentMode = UIView.ContentMode.scaleAspectFit
        chargerPhotosScrollView.backgroundColor = UIColor(r: 154, g: 244, b: 204)
        
        socketCollectionView.collectionViewLayout = gravitySliderLayout
    }
}

extension StationInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.socketsNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = socketCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SocketViewCell
        cell.configureWith(typeName: viewModel.socketsNames[indexPath.row])
        return cell
    }
    
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) 
//        if let focusedView = context.nextFocusedView as? UICollectionViewCell {
//            self.socketCollectionView.isScrollEnabled = false
//            let indexPath = socketCollectionView.indexPath(for: focusedView)!
//            self.socketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        self.socketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//    }
}
