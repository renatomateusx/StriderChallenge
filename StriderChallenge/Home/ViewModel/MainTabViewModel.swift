//
//  MainTabViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

protocol MainTabViewModelProtocol {
    
    var posts: Bindable<Posts> { get set }
    var error: Bindable<Error> { get set }
    var user: Bindable<User> { get set }
    
    func fetchData(_ page: Int)
    func fetchUser(_ userId: String)
}

class MainTabViewModel {
    
    // MARK: - Private Properties
    let postsService: PostsRepositoryProtocol
    let userService: UserRepositoryProtocol
    let coordinator: HomeCoordinator
    var posts = Bindable<Posts>()
    var error = Bindable<Error>()
    var user = Bindable<User>()
    
    // MARK: - Inits
    
    init(with service: PostsRepositoryProtocol, userService: UserRepositoryProtocol,
         coordinator: HomeCoordinator) {
        self.postsService = service
        self.userService = userService
        self.coordinator = coordinator
    }
    
    func fetchData(_ page: Int, user: User) {
        postsService.fetchPosts(forUser: user) { posts in
            self.posts.value = posts
        }
    }
    
    func fetchUser(_ userId: String) {
        userService.fetchUser(uid: userId) { user in
            self.user.value = user
        }
    }
}
