//
//  Alert.swift
//  Firebase_Twitter
// Raees Folder
//  Created by Vishal on 22/12/23.
//

import Foundation
import UIKit

class Alert{
    
    private init(){}
    static let shared = Alert()
    
    func ShowAlertWithOKBtn(title:String,message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }
}
