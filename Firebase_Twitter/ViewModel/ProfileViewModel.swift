////
////  ProfileViewModel.swift
////  Firebase_Twitter
////
////  Created by Vishal on 22/12/23.

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

protocol ProfileViewModelDelegate: AnyObject {
    func didUpdateProfile(_ profileModel: ProfileModel)
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    private var profileModel = ProfileModel()
    private let db = Firestore.firestore()
    private var profileCache: [String: ProfileModel] = [:]
    var isProfileLoaded: Bool = false

    // MARK: - Authentication

    func signIn(completion: @escaping () -> Void) {
        // Authentication logic goes here
        completion()
    }

    // MARK: - Profile Loading

    func loadProfile(profileUserID: String?, completion: @escaping () -> Void) {
        guard let profileUserID = profileUserID else {
            print("Profile user ID not available.")
            return
        }

        // Check if the profile is already in the cache
        if let cachedProfile = profileCache[profileUserID] {
            self.profileModel = cachedProfile
            self.delegate?.didUpdateProfile(cachedProfile)
            return
        }

        db.collection("users").whereField("UUID", isEqualTo: profileUserID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let document = querySnapshot?.documents.first else {
                return
            }

            let name = document.data()["name"] as? String ?? ""
            let email = document.data()["email"] as? String ?? ""

            self.profileModel.name = name
            self.profileModel.email = email
            self.profileModel.followers = []
            self.profileModel.following = []

            print("loadProfile: name = \(self.profileModel.name), email: \(self.profileModel.email)")

            // Cache the loaded profile
            self.profileCache[profileUserID] = self.profileModel

            DispatchQueue.main.async {
                self.delegate?.didUpdateProfile(self.profileModel)
                completion()
            }
        }
    }

    // MARK: - Profile Setup

    func setupForSelectedUser(profileUserID: String) {
        isProfileLoaded = false
        loadProfile(profileUserID: profileUserID) { [weak self] in
            guard let self = self else { return }
            self.loadFollowerFollowingCounts(profileUserID: profileUserID)

            if let loggedInUserID = Auth.auth().currentUser?.uid {
                self.checkAndSetFollowStatus(loggedInUserID: loggedInUserID, profileUserID: profileUserID)
            } else {
                print("User is not logged in.")
            }
        }
    }

    // MARK: - Follow Button

    func followButtonTapped(profileUserID: String?) {
        print("followButtonTapped called")

        guard let profileUserID = profileUserID else { return }

        if !isProfileLoaded {
            updateFollowStatus(loggedInUserID: Auth.auth().currentUser?.uid, profileUserID: profileUserID)
            isProfileLoaded = true
        }
    }

    // MARK: - Follower/Following Counts

    func loadFollowerFollowingCounts(profileUserID: String?) {
        guard let profileUserID = profileUserID else { return }
        let userDocRef = db.collection("users").document(profileUserID)

        userDocRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document else { return }

            if let followersCount = document.data()?["followers"] as? [String],
                let followingCount = document.data()?["following"] as? [String] {

                self.profileModel.name = document.data()?["name"] as? String ?? ""
                self.profileModel.email = document.data()?["email"] as? String ?? ""
                self.profileModel.followers = followersCount
                self.profileModel.following = followingCount

                print("loadFollowerFollowingCounts followers: \(self.profileModel.followers), following: \(self.profileModel.following)")

                self.delegate?.didUpdateProfile(self.profileModel)
            } else {
                print("Error in data format in user document.")
            }
        }
    }

    // MARK: - Follow Status

    func checkAndSetFollowStatus(loggedInUserID: String?, profileUserID: String?) {
        guard let loggedInUserID = loggedInUserID, let profileUserID = profileUserID else { return }
        let userDocRef = db.collection("users").document(profileUserID)

        userDocRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document else { return }

            if let profileFollowers = document.data()?["followers"] as? [String] {
                self.profileModel.isFollowing = profileFollowers.contains(loggedInUserID)
                self.delegate?.didUpdateProfile(self.profileModel)
            } else {
                print("Error in data format in user document.")
            }
        }
    }

    func updateFollowStatus(loggedInUserID: String?, profileUserID: String?) {
        guard let loggedInUserID = loggedInUserID, let profileUserID = profileUserID else { return }
        let userDocRef = db.collection("users").document(profileUserID)

        userDocRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document else { return }

            var profileFollowers = document.data()?["followers"] as? [String] ?? []

            if profileFollowers.contains(loggedInUserID) {
                profileFollowers.removeAll { $0 == loggedInUserID }
                self.profileModel.isFollowing = false
            } else {
                profileFollowers.append(loggedInUserID)
                self.profileModel.isFollowing = true
            }

            userDocRef.updateData(["followers": profileFollowers]) { error in
                if let error = error {
                    print("Error updating profile followers: \(error.localizedDescription)")
                } else {
                    self.loadFollowerFollowingCounts(profileUserID: profileUserID)
                    self.delegate?.didUpdateProfile(self.profileModel)
                    self.updateLoggedInUserFollowing(loggedInUserID: loggedInUserID, profileUserID: profileUserID)
                }
            }
        }
    }

    // MARK: - Logged-In User Following

    func updateLoggedInUserFollowing(loggedInUserID: String?, profileUserID: String?) {
        guard let loggedInUserID = loggedInUserID else { return }
        let loggedInUserDocRef = db.collection("users").document(loggedInUserID)

        loggedInUserDocRef.getDocument { document, error in
            guard let document = document else { return }

            var loggedInUserFollowing = document.data()?["following"] as? [String] ?? []

            if self.profileModel.isFollowing ?? false {
                loggedInUserFollowing.append(profileUserID!)
            } else {
                loggedInUserFollowing.removeAll { $0 == profileUserID }
            }

            loggedInUserDocRef.updateData(["following": loggedInUserFollowing]) { error in
                if let error = error {
                    print("Error updating logged-in user's following: \(error.localizedDescription)")
                } else {
                    self.delegate?.didUpdateProfile(self.profileModel)
                }
            }
        }
    }
}
