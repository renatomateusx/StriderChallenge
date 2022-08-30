//
//  FeedViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import UIKit
import SDWebImage

class FeedViewController: UICollectionViewController, UIProtocols {

    //MARK: Properties
    private var loading: UIActivityIndicatorView?
    private var page: Int = 0
    var user: User! {
        didSet {
            changeUserImage()
        }
    }
    var viewModel: FeedViewModelProtocol!
    var coordinator: HomeCoordinator!
    
    private var posts = Posts() {
        didSet { collectionView.reloadData()}
    }
    
    private var replies = Posts() {
        didSet { collectionView.reloadData() }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32/2
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        configureScreen()
    }
    
    private func configureScreen() {
        setupObserver()
        configureUI()
        fetchPosts()
    }
    
    //MARK: Helpers
    internal func configureUI(){
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PostViewCell.self, forCellWithReuseIdentifier: PostViewCell.identifier)
        
        navigationItem.titleView = logoImageView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLeftButtonImageView))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
    
    private func changeUserImage(){
        guard let image = self.user?.profileImage else {return}
        profileImageView.sd_setImage(with: image, completed: nil)
    }
    
    //MARK: Bindable
    private func setupObserver() {
        self.collectionView.refreshControl?.beginRefreshing()
        viewModel.posts.bind { [weak self] (_) in
            if let posts = self?.viewModel.posts.value {
                self?.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                self?.checkIfUserLikedTweets()
                self?.collectionView.refreshControl?.endRefreshing()
                self?.loading?.stopAnimating()
            }
        }
        
        viewModel.replies.bind { [weak self] (_) in
            if let replies = self?.viewModel.replies.value {
                self?.replies = replies
                self?.collectionView.refreshControl?.endRefreshing()
                self?.loading?.stopAnimating()
            }
        }
        
        viewModel.error.bind { [weak self] (_) in
            if let error = self?.viewModel.error.value {
                DispatchQueue.main.async {
                    self?.alert(title: .localized(.oopsTitle), message: error.localizedDescription)
                    self?.loading?.stopAnimating()
                }
            }
        }
        
        viewModel.result.bind { [weak self] _ in
            if let result = self?.viewModel.result.value {
                if result {
                    self?.fetchPosts()
                    self?.loading?.stopAnimating()
                }
            }
        }
        
        viewModel.user.bind { [weak self] _ in
            if let user = self?.viewModel.user.value {
                let controller = ProfileViewController(user: user)
                self?.coordinator.goToVC(vc: controller)
            }
        }
    }
    
    //MARK: API
    func fetchPosts(){
        collectionView.refreshControl?.beginRefreshing()
        viewModel.fetchPosts(0)
        collectionView.refreshControl?.endRefreshing()
    }
    
    func checkIfUserLikedTweets(){
        self.posts.forEach { post in
            viewModel.checkIfUserLikedPost(post) { didLiked in
                guard didLiked == true else {return}
                if let index = self.posts.firstIndex(where: { $0.postID == post.postID}) {
                    self.posts[index].didLiked = true
                }
            }
        }
    }
    
    //MARK: Selectors
    
    @objc func handleRefresh(){
        fetchPosts()
    }
    
    @objc func didTapLeftButtonImageView(){
        guard let user = user else {return}
        let controller = ProfileViewController(user: user)
        coordinator.goToVC(vc: controller)
        
    }
}
//MARK: UICollectionViewDelegate/DataSource
extension FeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostViewCell.identifier, for: indexPath) as! PostViewCell
        cell.configure(post: post)
        cell.delegate = self
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let controller = PostsViewController(post: post)
        controller.userViewModel = UserViewModel(userService: UserRepository())
        controller.viewModel = PostViewModel(user: post.user, post: post, postService: PostsRepository())
        coordinator.goToVC(vc: controller)
    }
}
//MARK: UICollectionViewDelegate/FlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = PostViewModel(user: user,
                                      post: posts[indexPath.row],
                                      postService: PostsRepository())
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        let plusHeight: CGFloat = 72
        return CGSize(width: view.frame.width, height: captionHeight + plusHeight)
    }
}

//MARK: TweetViewCellDelegate
extension FeedViewController: PostViewCellDelegate {
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
    
    func didTapProfileImage(_ cell: PostViewCell) {
        guard let user = cell.user else {return}
        coordinator.goToProfile(user: user)
    }
    
}

extension FeedViewController {
    func setPosts(_ posts: Posts) {
        self.posts = posts
    }
}
