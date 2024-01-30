//
//  LogInViewController.swift
//  Firebase_Twitter

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController,protocolToSetBG,CompletionDelegate{
    
    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passTxtField: UITextField!
    @IBOutlet var logInBtnOutlet: UIButton!
    
    private var viewModel = LogInViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackGroundImage(imageName: "LogInBackGround")
        emailTxtField.layer.cornerRadius = 15
        passTxtField.layer.cornerRadius = 15
        logInBtnOutlet.layer.cornerRadius = 10
        viewModel.delegate = self
    }
    
    
    @IBAction func logInBtn(_ sender: UIButton) {
        print("logInBTN tapped-----")
        viewModel.signIn(email: emailTxtField.text, password: passTxtField.text)
    }
    
    func success() {
        print("you have signed in.....")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        navigationController?.pushViewController(DataViewController, animated: true) ?? present(DataViewController, animated: true, completion: nil)
    }
    
    func failure(message: String) {
        Alert.shared.ShowAlertWithOKBtn(title: "Invalid user", message: "Tap sign up to create an account")
    }
    
    @IBAction func SignUpNavigateButton(_ sender: UIButton) {
        print("SignUpNavigateButton clicked----")
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    
}
