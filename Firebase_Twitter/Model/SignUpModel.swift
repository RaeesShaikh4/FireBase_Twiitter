//
//  SignUpModel.swift
//  Firebase_Twitter
//
//  Created by Vishal on 21/12/23.
//

import Foundation


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
