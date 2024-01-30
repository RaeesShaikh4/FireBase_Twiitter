//
//  LogInViewModel.swift
//  Firebase_Twitter


import Foundation
import Firebase
import FirebaseAuth

protocol CompletionDelegate {
    func success()
    func failure(message:String)
}

class LogInViewModel {
    var delegate:CompletionDelegate?
    
    func signIn(email: String?, password: String?) {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else{
            Alert.shared.ShowAlertWithOKBtn(title: "Missing Field data", message: "Please fill both textfields...")
            return
        }
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.delegate?.failure(message: error.localizedDescription)
            } else {
                self.delegate?.success()
            }
        }
    }
    
}
