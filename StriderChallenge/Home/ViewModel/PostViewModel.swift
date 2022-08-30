//
//  PostViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

protocol PostViewModelProtocol: AnyObject {
    var posts: Bindable<Posts> { get set }
    
    func fetchReplies(forPost post: Post)
}

class PostViewModel {
    
    var user: User?
    var post: Post?
    var postService: PostsRepositoryProtocol!
    var posts = Bindable<Posts>()
    
    var profileImageURL: URL? {
        guard let user = self.user else {return URL(string: String.init())}
        return user.profileImage
    }
    var timestamp: String {
        guard let post = post else {return String.init()}
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: post.timestamp, to: now) ?? "30s"
    }
    
    // MARK: - Init
    
    init(user: User, post: Post, postService: PostsRepositoryProtocol) {
        self.user = user
        self.post = post
        self.postService = postService
    }
    
    func userInfoText() -> NSAttributedString {
        guard let user = self.user else {return NSAttributedString()}
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        title.append(NSAttributedString(string: " · \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return title
    }
    
    var usernameText: String {
        guard let username = user?.username else { return  String.init()}
        return "@\(username)"
    }
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a · MM/dd/yyyy"
        return formatter.string(from: (post?.timestamp)!)
    }
    
    var retweetsAttributedString: NSAttributedString? {
        guard let count = post?.rePostCount else { return NSAttributedString()}
        return attributeText(withValue: count, text: " Retweets")
    }
    
    var likesAttributedString: NSAttributedString? {
        guard let count = post?.likes else { return NSAttributedString()}
        return attributeText(withValue: count, text: " Likes")
    }
    
    var likeButtonTintColor: UIColor {
        guard let post = post else {return .lightGray}
        return post.didLiked ? .red : .lightGray
    }
    var likeButtonImage: UIImage {
        guard let post = post else {return UIImage(named: "like")!}
        let imageName = post.didLiked ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        guard let post = self.post else {return true}
        return !post.isReply
    }
    
    var replyText: String? {
        guard let replyingToUser = post?.replyingTo else {return nil}
        return "→ replying to @\(replyingToUser)"
    }
    
    fileprivate func attributeText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = post?.text
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

extension PostViewModel: PostViewModelProtocol {
    func fetchReplies(forPost post: Post) {
        postService.fetchReplies(forPost: post) { posts in
            self.posts.value = posts
        }
    }
}
