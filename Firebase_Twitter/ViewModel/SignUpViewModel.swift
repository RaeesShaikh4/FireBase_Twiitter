//
//  SignUpViewModel.swift
//  Firebase_Twitter
//
//  Created by Vishal on 21/12/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol completionDelegate{
    func success(user: User?)
    func failure(message: String)
}

class SignUpViewModel {
    
    var delegate: completionDelegate?
    var FireStore = Firestore.self
    
    func signUp(name: String?, email: String?, password: String?) {
        
        guard let name = name, !name.isEmpty,
              let email = email, !email.isEmpty,
              let password = password, !password.isEmpty  else {
            delegate?.failure(message: "Please enter name, email, and password.")
            
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.delegate?.failure(message: error.localizedDescription)
            } else {
                guard let user = authResult?.user else {
                    self.delegate?.failure(message: "User data is not available.")
                    return
                }
                
                let userUUID = user.uid
                
                let newUser = User(Uuid: userUUID, name: name, email: email, tweets: [], likes: [], comments: [], following: [], followers: [])
                
                self.storeUserData(user: newUser) { result in
                    switch result {
                    case .success(let storedUser):
                        self.delegate?.success(user: storedUser)
                    case .failure(let storeError):
                        self.delegate?.failure(message: storeError.localizedDescription)
                    }
                }
            }
        }
    }

    private func storeUserData(user:User, completion : @escaping (Result<User,Error>) -> Void){
        let dataBase = FireStore.firestore()
        dataBase.collection("users").document(user.Uuid).setData([
            "name": user.name,
            "email": user.email,
            "following": user.following,
            "followers": user.followers,
            "UUID": user.Uuid,
            "comments": user.comments,
            "tweets": user.tweets,
            "likes": user.likes
        ]) { error in
            if let error = error {
                self.delegate?.failure(message: error.localizedDescription)
            } else {
                self.delegate?.success(user: user)
            }
            
        }
    }
}




