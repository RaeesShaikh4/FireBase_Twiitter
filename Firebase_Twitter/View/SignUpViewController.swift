//
//  SignUpViewController.swift
//  Firebase_Twitter
//
//  Created by Vishal on 11/12/23.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController,protocolToSetBG,UITextFieldDelegate,completionDelegate{
    
    private var viewModel = SignUpViewModel()
    var currentUser: User?
    
    @IBOutlet var nameSignTxtField: UITextField!
    @IBOutlet var emailSignTxtField: UITextField!
    @IBOutlet var passSignTxtField: UITextField!
    
    @IBOutlet var signUpOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackGroundImage(imageName: "LogInBackGround")
        nameSignTxtField.layer.cornerRadius = 15
        emailSignTxtField.layer.cornerRadius = 15
        passSignTxtField.layer.cornerRadius = 15
        signUpOutlet.layer.cornerRadius = 10
        
        viewModel.delegate = self   
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        viewModel.signUp(name: nameSignTxtField.text, email: emailSignTxtField.text, password: passSignTxtField.text)
    }
    
    func success(user: User?) {
            if let user = user {
                print("User created successfully: \(user)")

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController

                navigationController?.pushViewController(dataViewController, animated: true) ?? present(dataViewController, animated: true, completion: nil)

            } else {
                print("User object is nil.")
            }
        }

        func failure(message: String) {
            print("Error creating user: \(message)")
        }
    
    @IBAction func logInNavigateBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
