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

class CharherInfoViewController: UIViewController {
    
    var receivedStaion: ChargeStation?
    
    @IBOutlet weak var chargerPhotos: UIScrollView!
    @IBOutlet weak var socketCollectionView: UICollectionView!
    @IBOutlet weak var addreNameLabel: UILabel!
    @IBOutlet weak var distanceSocketsLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var contactWebSiteLabel: UILabel!
    
    let images: [UIImage] = [UIImage(named: "type1")!, UIImage(named: "type2")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketCollectionView.dataSource = self
        socketCollectionView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let station = receivedStaion {
            self.addreNameLabel.text = station.AddressInfo?.Title
            self.distanceSocketsLabel.text = "Drive: \(String(format: "%.2f", station.AddressInfo?.Distance ?? 0)) km"
            if station.Connections.count > 0 {
                self.distanceSocketsLabel.text?.append(", ")
                for item in station.Connections {
                    self.distanceSocketsLabel.text?.append(item?.ConnectionType?.Title! ?? "")
                    if item?.ConnectionType?.Title == station.Connections.last!?.ConnectionType?.Title {
                        break
                    }
                }
            }
            
            self.contactEmailLabel.text = receivedStaion?.OperatorInfo?.ContactEmail
            self.contactPhoneLabel.text = receivedStaion?.OperatorInfo?.PhonePrimaryContact
            self.contactWebSiteLabel.text = receivedStaion?.OperatorInfo?.WebsiteURL
            
            self.chargerPhotos.auk.settings.contentMode = UIView.ContentMode.scaleAspectFill
            self.chargerPhotos.auk.settings.placeholderImage = UIImage(named: "noPicture")
            if let medItems = station.MediaItems {
                for item in medItems {
                    if let imageUrl = item?.ItemThumbnailURL {
                        self.chargerPhotos.auk.settings.placeholderImage = UIImage(named: "waitingImage")
                        self.chargerPhotos.auk.show(url: imageUrl)
                    }
                }
            }
        }
    }
}

extension CharherInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let types = self.receivedStaion?.Connections {
            return types.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = socketCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SocketViewCell
        cell.typeImage.image = UIImage(named: "noPicture")
        cell.typeName.text = "?"
        if let types = receivedStaion?.Connections {
            cell.typeName.text = types[indexPath.row]?.ConnectionType?.Title
            
            if (cell.typeName.text)!.contains("Type 2") {
                cell.typeImage.image = UIImage(named: "type2")
            } else if (cell.typeName.text)!.contains("Type 1") {
                cell.typeImage.image = UIImage(named: "type1")
            } else if (cell.typeName.text)!.contains("Tesla") {
                cell.typeImage.image = UIImage(named: "teslaCharg")
            } else if (cell.typeName.text)!.contains("CCS") {
                cell.typeImage.image = UIImage(named: "ccs")
            } else if (cell.typeName.text)!.contains("CHAdeMO") {
                cell.typeImage.image = UIImage(named: "chademo")
            }
        }
        
        return cell
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        print("takoe")
        if let focusedView = context.nextFocusedView as? UICollectionViewCell {
            
            print("uzhe luchz")
            self.socketCollectionView.isScrollEnabled = false
            let indexPath = socketCollectionView.indexPath(for: focusedView)!
            self.socketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.socketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}
