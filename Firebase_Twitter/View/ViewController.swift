    //
    //  ViewController.swift
    //  Firebase_Twitter
   

    import UIKit
    import Firebase
    import FirebaseFirestore
    import FirebaseAuth

    class ViewController: UIViewController, ProfileViewModelDelegate {
        
        @IBOutlet var profileImg: UIImageView!
        @IBOutlet var nameLabel: UILabel!
        @IBOutlet var emailLabel: UILabel!
        @IBOutlet var followersCount: UILabel!
        @IBOutlet var followingCount: UILabel!
        @IBOutlet var followBTN: UIButton!
        @IBOutlet var commentBTN: UIButton!
        
        var viewModel: ProfileViewModel!
        var profileUserID: String?
        
        var loggedInUserID: String?
        var selectedUserID: String?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            signIn()
            viewModel = ProfileViewModel()
            viewModel.delegate = self
            print("profileUserID: \(profileUserID)")
            print("loggedInUserID: \(loggedInUserID)")
            print("selectedUserID : \(selectedUserID)")
            loadUserProfile()
        }
        
        func loadUserProfile(completion: (() -> Void)? = nil){
            guard let selectedUserID = selectedUserID else {
                    print("loadUserProfile selectedUserID is nil")
                    return
                }
                profileUserID = selectedUserID
            viewModel.setUpForSelectedUser(profileUserId: selectedUserID){
                completion?()
            }
        }
        
        func didUpdateProfile(_ profileModel: ProfileModel) {
            print("didUpdateProfile called with profileModel: \(profileModel)")
            DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.nameLabel.text = profileModel.name ?? ""
                        self.emailLabel.text = profileModel.email ?? ""
                        
                        // Handle follower and following counts
                        self.followersCount.text = "\(profileModel.followers?.count ?? 0)"
                        self.followingCount.text = "\(profileModel.following?.count ?? 0)"
                        
                        let title = profileModel.isFollowing == true ? "Following" : "Follow"
                        self.followBTN.setTitle(title, for: .normal)
                    }
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
            print("Follow button tapped")
            print("ProfileUserID: \(profileUserID ?? "nil")")
            guard let profileUserID = self.profileUserID else {
                print("ProfileUserID is nil. Cannot follow.")
                return
            }
            print("Follow button tapped for ProfileUserID: \(profileUserID)")
            viewModel.followButtonTapped(profileUserID: profileUserID)
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
    }

    extension ViewController {
        func presentCommentViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            commentVC.modalPresentationStyle = .overCurrentContext
            commentVC.profileUserId = profileUserID
            self.present(commentVC, animated: true, completion: nil)
        }
    }
