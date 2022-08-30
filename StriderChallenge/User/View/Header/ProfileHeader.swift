//
//  ProfileHeader.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func didTapDismissal()
    func didTapEditProfile(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilterOptions)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: Properties
    
    static let identifier = "ProfileHeader"
    
    private let filterBar = ProfileFilterView()
    
    weak var delegate: ProfileHeaderDelegate?
    
    var user: User? {
        didSet { instantiateViewModel()}
    }
    
    var posts: Posts?
    var replies: Posts?
    var reposts: Posts?
    
    private lazy var containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .twitterBlue
//        view.addSubview(backButton)
//        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
//        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_white_24dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 4
        return image
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(didTapEditProfileFollowButton), for: .touchUpInside)
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
//        label.text = "Renato Mateus"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
//        label.text = "@renatomateusx"
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = "This is a user bio which was provided by the user for tests"
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowingLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        label.text = "0 Following"
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        label.text = "10 Followers"
        return label
    }()
    
    private lazy var postsCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "10 Posts"
        label.textColor = .twitterBlue
        return label
    }()
    
    private lazy var repliesCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "10 Replies"
        label.textColor = .twitterBlue
        return label
    }()
    
    private lazy var repostsCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "10 Reposts"
        label.textColor = .twitterBlue
        return label
    }()
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(){
        backgroundColor = .systemBackground
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        let imageSie: CGFloat = 80
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor, paddingTop: -24, paddingLeft: 8)
        profileImageView.setDimensions(width: imageSie, height: imageSie)
        profileImageView.layer.cornerRadius = imageSie/2
        
        let padding: CGFloat = 12
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor, paddingTop: padding, paddingRight: padding)
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36/2
        
        /// stackview vertical
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                              usernameLabel,
                                                              bioLabel,
                                                              postsCount,
                                                              repliesCount,
                                                              repostsCount])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: padding, paddingRight: padding)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        
        addSubview(followStack)
        followStack.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        

    }
    
    
    //MARK: Helpers
    
    func instantiateViewModel(){
        guard let user = user else {return}
        let viewModel = ProfileHeaderViewModel(user: user)
        
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
        
        profileImageView.sd_setImage(with: user.profileImage)
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
        
        bioLabel.text = user.bio
        
        guard let posts = posts else { return }
        postsCount.text = "\(posts.count) Posts"
        
        guard let replies = replies else { return }
        repliesCount.text = "\(replies.count) Replies"
        
        guard let reposts = reposts else { return }
        repostsCount.text = "\(reposts.count) Reposts"
    }
    
    //MARK: Selectors
    
    @objc func didTapBackButton(){
        delegate?.didTapDismissal()
    }
    
    @objc func didTapEditProfileFollowButton(){
        delegate?.didTapEditProfile(self)
    }
    
    @objc func didTapFollowingLabel(){
        
    }
    
    @objc func didTapFollowersLabel(){
        
    }
}
//MARK: ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else {return}
        
        delegate?.didSelect(filter: filter)
    }
}

