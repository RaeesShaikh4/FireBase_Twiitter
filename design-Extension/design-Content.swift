//
//  background-Image.swift
//  Firebase_Twitter
//
//  Created by Vishal on 11/12/23.
//
import UIKit
import Foundation

protocol protocolToSetBG: AnyObject {
    func setBackGroundImage(imageName: String)
    func applyCornerRadius(to view: UIView, cornerRadius: CGFloat)
}



extension protocolToSetBG where Self: UIViewController {
    func setBackGroundImage(imageName: String) {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
    }
    
    
    func applyCornerRadius(to view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
}

