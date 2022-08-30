//
//  PostViewCell.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit
import SDWebImage
import ActiveLabel

protocol PostViewCellDelegate: AnyObject {
    func didTapProfileImage(_ cell: PostViewCell)
    func didTapReplyPost(_ cell: PostViewCell)
    func didTapRepostPost(_ cell: PostViewCell)
    func didTapLikePost(_ cell: PostViewCell)
    func didTapUsername(withUsername username:String)
}

class PostViewCell: UICollectionViewCell  {
    // MARK: Properties
    static let identifier = "PostViewCell"
    var user: User?
    var post: Post?
    weak var delegate: PostViewCellDelegate?
    
    static let imageSize: CGFloat = 48
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .twitterBlue
        profileImageView.setDimensions(width: PostViewCell.imageSize, height: PostViewCell.imageSize)
        profileImageView.layer.cornerRadius = PostViewCell.imageSize/2
        profileImageView.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        
        return profileImageView
    }()
    
    private let replyLabel: ActiveLabel = {
       let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
       let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "Post Test"
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(didTapRetweetButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var sharedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(didTapSharedButton), for: .touchUpInside)
        return button
    }()
    
    private let infoLabel = UILabel()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
       
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
       
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.text = "Renato Moura"
        captionLabel.text =  "Testezin"
        replyLabel.isHidden = true
        
        let actiontack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, sharedButton])
        actiontack.axis = .horizontal
        actiontack.spacing = 72
        
        addSubview(actiontack)
        actiontack.centerX(inView: self)
        actiontack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selectors
    
    @objc func didTapCommentButton() {
        delegate?.didTapReplyPost(self)
    }
    
    @objc func didTapRetweetButton() {
        delegate?.didTapRepostPost(self)
    }
    
    @objc func didTapLikeButton() {
        delegate?.didTapLikePost(self)
    }
    
    @objc func didTapSharedButton() {
        
    }
    
    @objc func didTapProfileImage(){
        delegate?.didTapProfileImage(self)
    }
    
    // MARK: Helpers
    
    func configure(post: Post){
        self.user = post.user
        self.post = post
        let viewM = PostViewModel(user: post.user, post: post, postService: PostsRepository())
        self.profileImageView.sd_setImage(with: post.user.profileImage, completed: nil)
        self.infoLabel.attributedText = viewM.userInfoText()
        self.captionLabel.text = post.text
        likeButton.tintColor = viewM.likeButtonTintColor
        likeButton.setImage(viewM.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewM.shouldHideReplyLabel
        replyLabel.text = viewM.replyText
    }
    func configureMentionHandler(){
        captionLabel.handleMentionTap { username in
            self.delegate?.didTapUsername(withUsername: username)
        }
    }
    
}
