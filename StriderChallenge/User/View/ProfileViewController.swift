//
//  ProfileViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import UIKit
import Firebase

class ProfileViewController: UICollectionViewController {
    
    //MARK: Properties
    var viewModel: FeedViewModelProtocol!
    var userViewModel: UserViewModelProtocol!
    var coordinator: HomeCoordinator!
    private var loading: UIActivityIndicatorView?
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .posts {
        didSet {collectionView.reloadData()}
    }
    
    private var posts = Posts()
    private var likedPosts = Posts()
    private var replies = Posts()
    
    private var currentDataSource: Posts{
        switch selectedFilter {
        case .posts: return posts
        case .replies: return replies
        case .likes: return likedPosts
        }
    }
    
    //MARK: Lifecycle
    
    init(user: User){
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        configureScreen()
    }
    
    private func configureScreen() {
        setupObserver()
        configureCollectionView()
        fetchPosts()
        fetchLikedPosts()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUsersStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupObserver() {
        viewModel.error.bind { [weak self] _ in
            if let error = self?.viewModel.error.value {
                DispatchQueue.main.async {
                    self?.alert(title: .localized(.oopsTitle), message: error.localizedDescription)
                    self?.loading?.stopAnimating()
                }
            }
        }
        
        viewModel.posts.bind { [weak self] _ in
            if let posts = self?.viewModel.posts.value {
                self?.posts = posts
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.replies.bind { [weak self] _ in
            if let replies = self?.viewModel.replies.value {
                self?.replies = replies
            }
        }
        
        viewModel.likes.bind { [weak self] _ in
            if let likes = self?.viewModel.likes.value {
                self?.likedPosts = likes
            }
        }
    }
    
    //MARK: API
    
    func fetchPosts() {
        viewModel.fetchPosts(0, user: user)
    }
    
    func checkIfUserIsFollowed() {
        userViewModel.checkIfUserIsFollowd(uid: user.uuid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUsersStatus() {
        userViewModel.fetchUserStatus(uid: user.uuid) { stats in
            print("DEBUG: User Status")
            self.user.status = stats
            self.collectionView.reloadData()
        }
    }
    
    func fetchLikedPosts() {
        viewModel.fetchLikes(forUser: user)
    }
    
    func fetchReplies(){
        viewModel.fetchReplies(forUser: user)
    }
    
    //MARK: Helpers
    func configureCollectionView(){
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(PostViewCell.self, forCellWithReuseIdentifier: PostViewCell.identifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else {return}
        collectionView.contentInset.bottom = tabHeight
        
        setupLoading()
    }
    
    private func setupLoading() {
        loading = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loading?.color = UIColor.white
        loading?.translatesAutoresizingMaskIntoConstraints = false
        if let loading = loading {
            self.view.addSubview(loading)
            loading.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            loading.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
    }
    
}
//MARK: UICollectionViewDataSource
extension ProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostViewCell.identifier, for: indexPath) as! PostViewCell
        let post = currentDataSource[indexPath.row]
        cell.configure(post: post)
        cell.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension ProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        
        header.delegate = self
        header.posts = self.posts
        header.replies = self.replies
        header.reposts = self.replies
        header.user = user
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = currentDataSource[indexPath.row]
        let controller = PostsViewController(post: post)
        controller.viewModel = PostViewModel(user: post.user,
                                             post: post,
                                             postService: PostsRepository())
        controller.userViewModel = self.userViewModel
        coordinator.goToVC(vc: controller)
    }
}


//MARK: UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 350)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = currentDataSource[indexPath.row]
        let viewModel = PostViewModel(user: post.user, post: post, postService: PostsRepository())
        var captionHeight = viewModel.size(forWidth: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            captionHeight += 20
        }
        
        return CGSize(width: view.frame.width, height: captionHeight)
    }
}


//MARK: ProfileHeaderDelegate

extension ProfileViewController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func didTapEditProfile(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            coordinator.presentVC(vc: controller)
            return
        }
        
        if user.isFollowed {
            userViewModel.unfollowUser(uid: user.uuid) { result in
                self.user.isFollowed  = false
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.fetchUsersStatus()
            }
        }
        else {
            userViewModel.followUser(uid: user.uuid) { result in
                self.user.isFollowed  = true
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                self.fetchUsersStatus()
            }
        }
    }
    
    func didTapDismissal() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: EditProfileViewControllerDelegate

extension ProfileViewController: EditProfileViewControllerDelegate{
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            // CALL HOME COORDINATOR WHICH WILL CALL LOGIN COORDINATOR HERE
        }
        catch {
            print("DEBUG: Error tried logout")
        }
    }
    
    func controller(_ controller: EditProfileViewController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
}

//MARK: PostViewCellDelegate
extension ProfileViewController: PostViewCellDelegate {
    func didTapUsername(withUsername username: String) {
        viewModel.fetchUser(withUsername: username)
    }
    
    func didTapLikePost(_ cell: PostViewCell) {
        guard let post = cell.post else {return}
        viewModel.likePost(post: post) {
            guard var post = cell.post else {return}
            post.didLiked.toggle()
            let likes = post.didLiked ? post.likes - 1 : post.likes + 1
            post.likes = likes
            cell.configure(post: post)
        }
    }
    
    func didTapReplyPost(_ cell: PostViewCell) {
        guard let post = cell.post else {return}
        coordinator.goToReply(post: post)
    }
    
    func didTapRepostPost(_ cell: PostViewCell) {
        guard let post = cell.post else {return}
        coordinator.goToRepost(post: post)
    }
    
    func didTapProfileImage(_ cell: PostViewCell) {
        guard let user = cell.user else {return}
        coordinator.goToProfile(user: user)
    }
    
}

extension ProfileViewController {
    func setPosts(_ posts: Posts) {
        self.posts = posts
    }
}
