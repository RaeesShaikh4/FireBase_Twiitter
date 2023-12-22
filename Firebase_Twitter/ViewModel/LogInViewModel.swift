//
//  LogInViewModel.swift
//  Firebase_Twitter
//
//  Created by Vishal on 21/12/23.
//

import Foundation
import Firebase
import FirebaseAuth

protocol LogInCompletionDelegate {
    func success()
    func failure(message:String)
}

class LogInViewModel {
    var loginCompletion:LogInCompletionDelegate?
    
    func signIn(email: String?, password: String?) {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else{
//            print("Missing Field data")
            Alert.shared.ShowAlertWithOKBtn(title: "Missing Field data", message: "Please fill both textfields...")
            return
        }
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.loginCompletion?.failure(message: error.localizedDescription)
            } else {
                self.loginCompletion?.success()
            }
        }
    }
    
}
