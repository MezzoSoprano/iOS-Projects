//
//  UIViewExtension.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/24/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

extension UIView {
    
    func setShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 2
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
        
//        func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
//            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
//            rotateAnimation.fromValue = 0.0
//            rotateAnimation.toValue = CGFloat(.pi * 2.0)
//            rotateAnimation.duration = duration
//            
//            if let delegate: AnyObject = completionDelegate {
//                rotateAnimation.delegate = delegate as? CAAnimationDelegate
//            }
//            self.layer.add(rotateAnimation, forKey: nil)
//        }
//        
    }
    
    func setLightShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 0.5
        self.layer.masksToBounds = false
        
        //        func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        //            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        //            rotateAnimation.fromValue = 0.0
        //            rotateAnimation.toValue = CGFloat(.pi * 2.0)
        //            rotateAnimation.duration = duration
        //
        //            if let delegate: AnyObject = completionDelegate {
        //                rotateAnimation.delegate = delegate as? CAAnimationDelegate
        //            }
        //            self.layer.add(rotateAnimation, forKey: nil)
        //        }
        //
    }
}

// MARK: - Animation

extension UIView {
    
    func lightAnimate(completion: @escaping () -> Void ) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = .identity
                        
        }) { (isFinished) in
            UIView.animate(withDuration: 0.5, animations: {
                completion()
            }, completion: nil)
        }
    }
}
