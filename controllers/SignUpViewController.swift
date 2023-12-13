//
//  SignUpViewController.swift
//  Firebase_Twitter
//
//  Created by Vishal on 11/12/23.
//

import UIKit
import Firebase
import FirebaseAuth


struct User {
    var Uuid: String
    var name: String
        var email: String
        var tweets: [String]
        var likes: [String]
        var comments: [String]
    var following: [String]
        var followers: [String]
}


class SignUpViewController: UIViewController,protocolToSetBG,UITextFieldDelegate{
    
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
     
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        
        guard let email = emailSignTxtField.text, !email.isEmpty,
                    let name = nameSignTxtField.text, !name.isEmpty,
                    let password = passSignTxtField.text, !password.isEmpty else {
                  
                  print("Please enter name, email, and password.")
                  return
              }
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print("Error creating user: \(error.localizedDescription)")
                    } else {
                        print("User created successfully.")
                        
                        guard let user = authResult?.user else {
                            print("User data is not available.")
                            return
                        }
                        
                        let userUUID = user.uid
                        
                        let newUser = User(Uuid: userUUID, name: name, email: email, tweets: [], likes: [], comments: [], following: [], followers: [])

                        self.storeUserData(user: newUser) { result in
                            switch result {
                            case .success(let storedUser):
                                print("User data stored successfully: \(storedUser)")
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let DataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
                                
                                self.navigationController?.pushViewController(DataViewController, animated: true) ?? self.present(DataViewController, animated: true, completion: nil)
                                
                            case .failure(let storeError):
                                print("Error storing user data: \(storeError.localizedDescription)")
                            }
                        }
                    }
                }
       
    }
    
    func storeUserData(user: User, completion: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(user.Uuid).setData([
            "name": user.name,
            "email": user.email,
            "following": user.following,
            "followers": user.followers,
            "UUID": user.Uuid,
            "comments":user.comments,
            "tweets":user.tweets,
            "likes":user.likes
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(user))
            }
        }
    }

    
    
    @IBAction func logInNavigateBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
