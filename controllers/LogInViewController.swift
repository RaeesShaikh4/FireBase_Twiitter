//
//  LogInViewController.swift
//  Firebase_Twitter
//
//  Created by Vishal on 11/12/23.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController,protocolToSetBG {

    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passTxtField: UITextField!
    @IBOutlet var logInBtnOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackGroundImage(imageName: "LogInBackGround")
        emailTxtField.layer.cornerRadius = 15
        passTxtField.layer.cornerRadius = 15
        logInBtnOutlet.layer.cornerRadius = 15
    }
    

    @IBAction func logInBtn(_ sender: UIButton) {
        print("logInBTN tapped-----")
        guard let email = emailTxtField.text, !email.isEmpty,
              let password = passTxtField.text, !password.isEmpty else{
            print("Missing Field data")
            return
        }
        
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { [weak self] Result, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                strongSelf.showCreateAccountFunc()
                return
            }
            print("you have signed in.....")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let DataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController

            strongSelf.navigationController?.pushViewController(DataViewController, animated: true) ?? strongSelf.present(DataViewController, animated: true, completion: nil)

        }
    }
    
    func showCreateAccountFunc(){
        print("showCreateAccountFunc called----")
        let alert = UIAlertController(title: "Invalid user", message: "Tap sign in to create an account", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
           
          
           DispatchQueue.main.async {
               self.present(alert, animated: true, completion: nil)
           }
    }
        
    
    
    @IBAction func SignUpNavigateButton(_ sender: UIButton) {
        print("SignUpNavigateButton clicked----")
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    
}
