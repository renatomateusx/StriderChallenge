//
//  HomeModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

struct Posts: Codable {
    let text: String
    let tweetID: String
    let uid: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    let user: User
    var didLiked = false
    var replyingTo: String?
    
    var isReply: Bool {return replyingTo != nil}
    
    init(user: User, tweetID: String, dictionary: [String: Any]){
        self.user = user
        self.tweetID = tweetID
        
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        
    }
}

struct User: Codable {
    let uuid: String
    let email: String
    var fullname: String
    var username: String
    var profileImage: URL?
    var isFollowed = false
    var status: UserRelationStats?
    var isCurrentUser: Bool = false //{ Auth.auth().currentUser?.uid == uuid }
    var bio: String?
    
    init(with uuid: String){
        self.uuid = uuid
        self.email = String.init()
        self.fullname = String.init()
        self.username = String.init()
        self.profileImage = URL(string: String.init())
    }
    
    init(with uuid: String, dictionary: [String: AnyObject]){
        self.uuid = uuid
        
        let email = dictionary["email"] as? String ?? ""
        let username = dictionary["username"] as? String ?? ""
        let fullname = dictionary["fullname"] as? String ?? ""
        let bio = dictionary["bio"] as? String ?? ""
        
        self.email = email
        self.username = username
        self.fullname = fullname
        self.bio = bio
        
        self.profileImage = URL(string: String.init())
        if let profileImage = dictionary["profileImageUrl"] as? String {
            guard let url  = URL(string: profileImage) else {return}
            self.profileImage = url
        }
    }
}

struct UserRelationStats: Codable {
    var followers: Int
    var following: Int
}

enum ActionButtonConfiguration {
    case tweet
    case message
}

enum ExploreConrollerConfiguration {
    case messages
    case userSearch
}
