////
////  DataViewViewModel.swift
////  Firebase_Twitter
////
////  Created by Vishal on 22/12/23.
////
//
//import Foundation
//import Firebase
//import FirebaseFirestore
//
//class DataViewViewModel {
//    private var users:[Uuser] = []
//
//    var filteredUsers : [Uuser] {
//        didSet {
//            self.didUpdateData?()
//        }
//    }
//
//    var didUpdateData : (() -> Void)?
//
//    init() {
//        self.filteredUsers = []
//
//    }
//    func fetchUserData(completion: @escaping (Error?) -> Void) {
//        let database = Firestore.firestore()
//        database.collection("users").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                completion(error)
//            } else {
//                self.users = querySnapshot?.documents.compactMap({ document in
//                    let data = document.data()
//                    let uuid = document.documentID
//                    let name = data["name"] as? String ?? ""
//                    let email = data["email"] as? String ?? ""
//                    return Uuser(uuid: uuid, name: name, email: email)
//                }) as! [Uuser]
//                self.filteredUsers = self.users
//                completion(nil)
//            }
//        }
//    }
//
//    func filterContentForSearchText(_ searchText: String) {
//        if searchText.isEmpty {
//            filteredUsers = users
//        } else {
//            filteredUsers = users.filter {
//                $0.name.range(of: searchText, options: .caseInsensitive) != nil
//            }
//        }
//    }
//
//}

// DataViewViewModel.swift

import Foundation
import Firebase
import FirebaseFirestore

protocol DataViewViewModelDelegate: AnyObject {
    func didUpdateData()
}

class DataViewViewModel {
    private var users: [Uuser] = []
    
    var filteredUsers: [Uuser] {
        didSet {
            self.delegate?.didUpdateData()
        }
    }
    
    weak var delegate: DataViewViewModelDelegate?
    
    init() {
        self.filteredUsers = []
    }
    
    func fetchUserData(completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                self.users = querySnapshot?.documents.compactMap({ document in
                    let data = document.data()
                    let uuid = document.documentID
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    return Uuser(uuid: uuid, name: name, email: email)
                }) as! [Uuser]
                self.filteredUsers = self.users
                completion(nil)
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter {
                $0.name.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
    }
}


