//
//  UserViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Foundation

protocol UserViewModelProtocol {
    var user: Bindable<User> { get set }
    var error: Bindable<Error> { get set }
    var result: Bindable<Bool> { get set }
    
    
    func followUser(uid: String, completion: @escaping(Bool) -> Void)
    func unfollowUser(uid: String, completion: @escaping(Bool) -> Void)
    func checkIfUserIsFollowd(uid: String, completion: @escaping(Bool) -> Void)
    func fetchUser(withUsername username: String)
    func fetchUserStatus(uid: String, completion: @escaping(UserRelationStats) -> Void)
}

class UserViewModel: UserViewModelProtocol {
    
    // MARK: - Private Properties
    var page = 0
    let userService: UserRepositoryProtocol
    
    var posts = Bindable<Posts>()
    var error = Bindable<Error>()
    var result = Bindable<Bool>()
    var user = Bindable<User>()
    
    var actionButtonTitle: String?
    var placeholderText: String?
    var shouldShowReplyLabel: Bool?
    var replyText: String?
    
    // MARK: - Inits
    
    init(userService: UserRepositoryProtocol) {
        self.userService = userService
    }
    
    func followUser(uid: String, completion: @escaping(Bool) -> Void) {
        userService.followUser(uid: uid) { error, ref in
            if let error = error {
                self.error.value = error
                return
            }
            completion(true)
        }
    }
    func unfollowUser(uid: String, completion: @escaping(Bool) -> Void) {
        userService.unfollowUser(uid: uid) { error, ref in
            if let error = error {
                self.error.value = error
                return
            }
            completion(true)
        }
    }
    
    func checkIfUserIsFollowd(uid: String, completion: @escaping(Bool) -> Void) {
        userService.checkIfUserIsFollowd(uid: uid, completion: completion)
    }
    
    func fetchUser(withUsername username: String) {
        userService.fetchUser(withUsername: username) { user in
            self.user.value = user
        }
    }
    
    func fetchUserStatus(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        userService.fetchUserStatus(uid: uid, completion: completion)
    }
}
