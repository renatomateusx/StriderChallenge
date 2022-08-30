//
//  FeedViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import Foundation

enum UploadPostConfiguration {
    case post
    case reply(Post)
    case repost(Post)
}

protocol FeedViewModelProtocol {
    var page: Int { get set }
    var posts: Bindable<Posts> { get set }
    var error: Bindable<Error> { get set }
    var result: Bindable<Bool> { get set }
    var user: Bindable<User> { get set }
    var replies: Bindable<Posts> { get set }
    var likes: Bindable<Posts> { get set }
    
    var postsLocal: Posts { get }
    var repliesLocal: Posts { get }
    var actionButtonTitle: String { get }
    var placeholderText: String { get }
    var shouldShowReplyLabel: Bool { get }
    var replyText: String? { get }
    
    func fetchPosts(_ page: Int, user: User)
    func fetchPosts(_ page: Int)
    func uploadPost(text: String, type: UploadPostConfiguration)
    func fetchUser(withUsername username: String)
    func likePost(post: Post, completion: @escaping() -> Void)
    func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) ->Void)
    func fetchReplies(forUser user: User)
    func fetchLikes(forUser user: User)
}

class FeedViewModel: FeedViewModelProtocol {
    
    // MARK: - Private Properties
    var page = 0
    var postsLocal = Posts()
    var repliesLocal = Posts()
    let postService: PostsRepositoryProtocol
    let userService: UserRepositoryProtocol
    var config: UploadPostConfiguration {
        didSet {
            self.setConfig(self.config)
        }
    }
    var posts = Bindable<Posts>()
    var error = Bindable<Error>()
    var result = Bindable<Bool>()
    var user = Bindable<User>()
    var replies = Bindable<Posts>()
    var likes = Bindable<Posts>()
    
    var actionButtonTitle: String = ""
    var placeholderText: String = ""
    var shouldShowReplyLabel: Bool = false
    var replyText: String?
    
    // MARK: - Inits
    
    init(with service: PostsRepositoryProtocol,
         userService: UserRepositoryProtocol,
         config: UploadPostConfiguration) {
        self.postService = service
        self.userService = userService
        self.config = config
        
        setConfig(config)
    }
    
    func fetchPosts(_ page: Int, user: User) {
        postService.fetchPosts(forUser: user, completion: { [weak self] posts in
            self?.posts.value = posts
            self?.postsLocal = posts
        })
    }
    
    func uploadPost(text: String, type: UploadPostConfiguration) {
        postService.uploadPost(text: text, type: type) { error, ref in
            if let error = error {
                self.error.value = error
            }
            
            self.result.value = true
        }
    }
    
    func fetchUser(withUsername username: String) {
        userService.fetchUser(withUsername: username) { user in
            self.user.value = user
        }
    }
    
    func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) ->Void) {
        postService.checkIfUserLikedPost(post, completion: completion)
    }
    
    func likePost(post: Post, completion: @escaping() -> Void) {
        postService.likePost(post: post) { [weak self] error, ref in
            if let error = error {
                self?.error.value = error
            }
        }
        completion()
    }
    
    func fetchReplies(forUser user: User) {
        postService.fetchReplies(forUser: user) { [weak self] replies in
            self?.replies.value = replies
            self?.repliesLocal = replies
        }
    }
    
    func fetchLikes(forUser user: User) {
        postService.fetchLikes(forUser: user) { [weak self] likes in
            self?.likes.value = likes
        }
    }
    
    func fetchPosts(_ page: Int) {
        postService.fetchPosts { [weak self] posts in
            self?.posts.value = posts
            self?.postsLocal = posts
        }
    }
}

extension FeedViewModel {
    func setConfig(_ config: UploadPostConfiguration) {
        switch config {
        case .post:
            actionButtonTitle = "Post"
            placeholderText = "Whats's happening"
            shouldShowReplyLabel = false
        case .reply(let post):
            actionButtonTitle = "Reply"
            placeholderText = "Post your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(post.user.username)"
        
        case .repost(let post):
            actionButtonTitle = "Repost"
            placeholderText = post.text
            shouldShowReplyLabel = true
            replyText = "Reposting from @\(post.user.username)"
        }
        self.fetchPosts(page)
    }
}
