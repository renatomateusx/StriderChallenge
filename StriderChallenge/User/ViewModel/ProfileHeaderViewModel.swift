//
//  ProfileHeaderViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case posts
    case replies
    case likes
    
    var description: String {
        switch self {
        case .posts: return "Posts"
        case .replies: return "Posts & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    private let user: User
    
    var usernameText: String
    
    var followersString: NSAttributedString? {
        return attributeText(withValue: user.status?.followers ?? 0, text: " Followers")
    }
    
    var followingString: NSAttributedString? {
        return attributeText(withValue: user.status?.following ?? 0, text: " Following")
    }
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        if user.isFollowed {
            return "Following"
        }
        return "Loading"
    }
    
    init(user: User){
        self.user = user
        self.usernameText = "@\(self.user.username)"
    }
    
    fileprivate func attributeText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
