//
//  MainTabViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import UIKit
import Firebase

class MainTabViewController: UITabBarController, UIProtocols {
    
    //MARK: Properties
    var user: User?
    weak var delegateUser: UserDelegate?
    private var buttonConfig: ActionButtonConfiguration = .post
    
    let viewModel: MainTabViewModel
    let coordinator: HomeCoordinator
    let feedViewModel = FeedViewModel(with: PostsRepository(),
                                      userService: UserRepository(),
                                      config: .post)
    
    private lazy var addTwitterButton: UIButton = {
       let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(didTapAddPost), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: MainTabViewModel, coordinator: HomeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureObservers()
        authenticAndUserConfigureUI()
        
    }
    
    private func configureObservers() {
        viewModel.user.bind { [weak self] _ in
            if let user = self?.viewModel.user.value {
                self?.user = user
                self?.configureUI()
            }
        }
    }
    
    private func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.viewModel.fetchUser(uid)
    }
    
    
    func authenticAndUserConfigureUI() {
        if Auth.auth().currentUser == nil {
            AuthManager.shared.login(username: "renatomateusx",
                                     email: "renatomateusx@gmail.com",
                                     password: "123456") { (loggedIn) in
                if loggedIn {
                    self.authenticAndUserConfigureUI()
                } else {
                    let auth = Authentication(email: "renatomateusx@gmail.com",
                                              password: "123456",
                                              fullname: "Renato Santos",
                                              username: "renatomateusx",
                                              profileImage: UIImage(named: "profile"))
                    AuthManager.shared.registerNewUser(with: auth) { registered in
                        if registered {
                            self.authenticAndUserConfigureUI()
                        }
                    }
                }
            }
        }
        else {
            print("DEBUG: User is logged in")
            configureUI()
            fetchUser()
        }
    }
    
    internal func configureUI() {
        view.backgroundColor = .systemBackground
        self.delegate = self
        guard let user = user else { return }
        
        let feed = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feed.viewModel = feedViewModel
        feed.coordinator = coordinator
        feed.user = user
        let nav1 = setTemplateNavController(image: "home_unselected", rootViewController: feed)
        
        let profile = ProfileViewController(user: user)
        profile.viewModel = feedViewModel
        profile.userViewModel = UserViewModel(userService: UserRepository())
        profile.coordinator = coordinator
        let nav2 = setTemplateNavController(image: "ic_person_outline_white_2x", rootViewController: profile)
        
        feedViewModel.posts.bind { [weak self] _ in
            if let posts = self?.feedViewModel.posts.value {
                feed.setPosts(posts)
                profile.setPosts(posts)
            }
        }
        
        viewControllers = [nav1, nav2]
        
        addSubViews()
        
    }
    
    private func addSubViews(){
        view.addSubview(addTwitterButton)
        let buttonSize: CGFloat = 56
        addTwitterButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: buttonSize, height: buttonSize)
        addTwitterButton.layer.cornerRadius = buttonSize / 2
    }
    
    private func setTemplateNavController(image: String, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = UIImage(named: image)
        nav.navigationBar.barTintColor = .white
        return nav
    }
}

extension MainTabViewController {
    @objc private func didTapAddPost() {
        switch buttonConfig {
        case .message :
            break
        case .post:
            guard let user = user else {return}
            
            let controller = UploadPostViewController(viewModel: feedViewModel,
                                                      coordiinator: self.coordinator,
                                                      user: user,
                                                      config: .post)
            controller.viewModel.result.bind { [weak self] _ in
                self?.feedViewModel.fetchPosts(self?.feedViewModel.page ?? 0)
            }
            self.coordinator.goToPost(vc: controller)
        }
    }
}

extension MainTabViewController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let image = index == 3 ? #imageLiteral(resourceName: "mail") : #imageLiteral(resourceName: "new_tweet")
        self.addTwitterButton.setImage(image, for: .normal)
        buttonConfig = index == 3 ? .message : .post
    }
}
