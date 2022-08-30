//
//  PostsViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

class PostsViewController: UICollectionViewController {
    //MARK: Properties
    
    var viewModel: PostViewModelProtocol!
    var userViewModel: UserViewModelProtocol!
    var coordinator: HomeCoordinator!
    private let post: Post
    private var actionSheet: ActionSheet?
    private var replies = Posts() {
        didSet {
            collectionView.reloadData()
        }
    }
    //MARK: LifeCycle
    
    init(post: Post){
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupObserver()
        fetchReplies()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Helpers
    func configureUI(){
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PostViewCell.self, forCellWithReuseIdentifier: PostViewCell.identifier)
        collectionView.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PostHeader.identifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else {return}
        collectionView.contentInset.bottom = tabHeight
    
    }
    
    fileprivate func showActionSheet(forUser user: User){
        actionSheet = ActionSheet(user: post.user, post: post)
        actionSheet?.delegate = self
        actionSheet?.showSheet()
    }
    
    func setupObserver() {
        viewModel.posts.bind { [weak self] _ in
            if let replies = self?.viewModel.posts.value {
                self?.replies = replies
            }
        }
        
        userViewModel.user.bind { [weak self] _ in
            if let user = self?.userViewModel.user.value {
                let controller = ProfileViewController(user: user)
                self?.coordinator.goToVC(vc: controller)
            }
        }
    }
    
    //MARK: API
    func fetchReplies(){
        viewModel.fetchReplies(forPost: post)
    }
    
    //MARK: Selectors
}

//MARK: UICollectionViewDataSource
extension PostsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostViewCell.identifier,
                                                      for: indexPath) as! PostViewCell
        cell.configure(post: replies[indexPath.row])
        return cell
    }
}
//MARK: UICollectionViewDelegate
extension PostsViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: PostHeader.identifier,
                                                                     for: indexPath) as! PostHeader
        header.configure(post: post)
        header.delegate = self
        return header
    }
}

//MARK: UICollectionViewDelegateFlowLayout

extension PostsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = PostViewModel(user: post.user, post: self.post, postService: PostsRepository())
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        let plusHeight: CGFloat = 260
        return CGSize(width: view.frame.width, height: captionHeight + plusHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = PostViewModel(user: post.user, post: self.post, postService: PostsRepository())
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        let plusHeight: CGFloat = 120
        return CGSize(width: view.frame.width, height: plusHeight)
    }
}


//MARK: PostHeaderDelegate
extension PostsViewController: PostHeaderDelegate {
    func handleFetchUser(withUsername username: String) {
        userViewModel.fetchUser(withUsername: username)
    }
    
    
   
    func showActionSheet() {
        if post.user.isCurrentUser {
            showActionSheet(forUser: post.user)
        }
        else {
            userViewModel.checkIfUserIsFollowd(uid: post.user.uuid) { isFollowed in
                var user = self.post.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
        
    }
    
}

//MARK: PostViewController/ActionSheetDelegate
extension PostsViewController: ActionSheetDelegate {
    func didSelect(option: ActionSheetOptions) {
        print("DEBUG: Option selected is \(option.description)")
        
        switch option {
        
        case .follow(let user):
            userViewModel.followUser(uid: user.uuid) { result in
                print("DEBUG: Did follow user \(user.username)")
            }
        case .unfollow(let user):
            userViewModel.unfollowUser(uid: user.uuid) { result in
                print("DEBUG: Did unfollow user \(user.username)")
            }
        case .report(let tweet):
            print("DEBUG: Report Twet \(tweet.text)")
        case .delete(let tweet):
            print("DEBUG: Delete Twet \(tweet.text)")
        }
    }
}
