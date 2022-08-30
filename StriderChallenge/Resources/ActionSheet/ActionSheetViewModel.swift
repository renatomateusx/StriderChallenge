//
//  ActionSheetViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Foundation

struct ActionSheetViewModel {
    private let user: User
    private let post: Post?
    
    var options: [ActionSheetOptions]{
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            if let post = post {
                results.append(.delete(post))
            }
        }
        else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        if let post = post {
            results.append(.report(post))
        }
        
        return results
    }
    
    
    
    init(user: User, post: Post?){
        self.user = user
        self.post = post
    }
}


enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report(Post)
    case delete(Post)
    
    
    var description: String {
        switch self {
        
        case .follow(let user):
            return "Follow @\(user.username)"
        case .unfollow(let user):
            return "Unfollow @\(user.username)"
        case .report(let post):
            return "Report Post"
        case .delete(let post):
            return "Delete Post"
        }
    }
}
