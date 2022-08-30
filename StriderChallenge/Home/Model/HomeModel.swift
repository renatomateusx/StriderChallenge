//
//  HomeModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

typealias Posts = [Post]

struct Post: Codable {
    let text: String
    let postID: String
    let uid: String
    var likes: Int
    var timestamp: Date!
    let rePostCount: Int
    let user: User
    var didLiked = false
    var replyingTo: String?
    
    var isReply: Bool {return replyingTo != nil}
    
    init(user: User, postID: String, dictionary: [String: Any]){
        self.user = user
        self.postID = postID
        
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.rePostCount = dictionary["reposts"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        
    }
}

enum ActionButtonConfiguration {
    case post
    case message
}

enum ExploreConrollerConfiguration {
    case messages
    case userSearch
}
