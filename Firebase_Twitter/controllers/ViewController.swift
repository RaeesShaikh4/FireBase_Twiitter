//
//  ViewController.swift
//  Firebase_Twitter
//
//  Created by Vishal on 08/12/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    
    @IBOutlet var followBTN: UIButton!
    @IBOutlet var commentBTN: UIButton!
    
    
    var profileUserID: String?
    var name: String?
    var email: String?
    var loggedInUserID: String?
    var isFollowing: Bool = false
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn()
        loadUserData()
        loadFollowerFollowingCounts()
        checkAndSetFollowStatus()
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SignOutBtn(_ sender: UIButton) {
        do {
               try Auth.auth().signOut()
               print("User signed out successfully")
               
               // Redirecting to LoginViewController after sign OUT
               let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               appDelegate.window?.rootViewController = loginVC
               
           } catch let signOutError as NSError {
               print("Error signing out: \(signOutError)")
        }
    }
    
    @IBAction func followBTN(_ sender: UIButton) {
        guard let loggedInUserID = loggedInUserID, let profileUserID = profileUserID else {
            print("User not authenticated.")
            return
        }
        
        let userDocRef = db.collection("users").document(profileUserID)
        
        // fetching the profile user's document
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var profileFollowers = document.data()?["followers"] as? [String] ?? []
                
                if profileFollowers.contains(loggedInUserID) {
                    // User is already following, then unfollow
                    profileFollowers.removeAll { $0 == loggedInUserID }
                    self.isFollowing = false
                } else {
                    // User is not following, then follow
                    profileFollowers.append(loggedInUserID)
                    self.isFollowing = true
                }
                
                // Updating the profile user's followers field in Firestore
                userDocRef.updateData(["followers": profileFollowers]) { error in
                    if let error = error {
                        print("Error updating profile followers: \(error.localizedDescription)")
                    } else {
                        // Reloading follower count after updating profile followers
                        self.loadFollowerFollowingCounts()
                        // Updating the button title based on new follow status
                        self.updateFollowButtonTitle()
                        
                        // Updating logged-in user's following array
                        self.updateLoggedInUserFollowing()
                    }
                }
            } else {
                print("Error getting profile user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
    }
    
    @IBAction func commentBTN(_ sender: UIButton) {
        presentCommentViewController()
    }
    
    func signIn() {
        if let user = Auth.auth().currentUser {
            loggedInUserID = user.uid
            
            print("User authenticated.")
        } else {
            print("User not authenticated.")
        }
    }
    
    
    func loadUserData() {
        print("loadUserData called----")
        
        // Used whereField to get data using UUID
        db.collection("users").whereField("UUID", isEqualTo: profileUserID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = querySnapshot?.documents.first {
                let name = document.data()["name"] as? String ?? ""
                let email = document.data()["email"] as? String ?? ""
                
                self.nameLabel.text = name
                self.emailLabel.text = email
                
                print("\(name) + \(email)")
            }
        }
    }
    
    func loadFollowerFollowingCounts() {
        print("loadFollowerFollowingCounts called----")
        
        guard let profileUserID = profileUserID else {
            print("Profile user ID not available.")
            return
        }
        
        let userDocRef = db.collection("users").document(profileUserID)
        
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let followersCount = document.data()?["followers"] as? [String] ?? []
                let followingCount = document.data()?["following"] as? [String] ?? []
                
                self.followersCount.text = "\(followersCount.count)"
                self.followingCount.text = "\(followingCount.count)"
            } else {
                print("Error getting user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
}



extension ViewController {
    func checkAndSetFollowStatus() {
        guard let loggedInUserID = loggedInUserID, let profileUserID = profileUserID else {
            print("User not authenticated.")
            return
        }
        
        
        let userDocRef = db.collection("users").document(profileUserID)
        
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let profileFollowers = document.data()?["followers"] as? [String] ?? []
                self.isFollowing = profileFollowers.contains(loggedInUserID)
                
                // Set the button title based on follow status
                self.updateFollowButtonTitle()
            } else {
                print("Error getting profile user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func updateFollowButtonTitle() {
        let title = isFollowing ? "Following" : "Follow"
        followBTN.setTitle(title, for: UIControl.State.normal)
    }
    
    func updateLoggedInUserFollowing() {
        guard let loggedInUserID = loggedInUserID else {
            print("User not authenticated.")
            return
        }
        
        let loggedInUserDocRef = db.collection("users").document(loggedInUserID)
        
        loggedInUserDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var loggedInUserFollowing = document.data()?["following"] as? [String] ?? []
                
                if self.isFollowing {
                    // If following, adding profile user's UUID to logged-in user's following array
                    loggedInUserFollowing.append(self.profileUserID!)
                } else {
                    // If unfollowing, removing profile user's UUID from logged-in user's following array
                    loggedInUserFollowing.removeAll { $0 == self.profileUserID }
                }
                
                // Updating logged-in user's following field in Firestore
                loggedInUserDocRef.updateData(["following": loggedInUserFollowing]) { error in
                    if let error = error {
                        print("Error updating logged-in user's following: \(error.localizedDescription)")
                    } else {
                        // Toggling the button title based on the updated follow status
                        self.updateFollowButtonTitle()
                    }
                }
            } else {
                print("Error getting logged-in user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    func presentCommentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        commentVC.modalPresentationStyle = .overCurrentContext
        commentVC.profileUserId = profileUserID
       
        self.present(commentVC, animated: true, completion: nil)
    }
    
}


