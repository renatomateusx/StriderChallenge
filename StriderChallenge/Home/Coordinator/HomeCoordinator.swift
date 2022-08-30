//
//  HomeCoordinator.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import UIKit

class HomeCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private weak var homeViewController: MainTabViewController?
    let feedViewModel = FeedViewModel(with: PostsRepository(),
                                  userService: UserRepository(),
                                  config: .post)
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MainTabViewModel(with: PostsRepository(),
                                         userService: UserRepository(),
                                         coordinator: self)
        
        let vc = MainTabViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: false)
        homeViewController = vc
    }
    
    func goToPost(vc: UIViewController) {
        DispatchQueue.main.async {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func goToVC(vc: UIViewController) {
        DispatchQueue.main.async {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func presentVC(vc: UIViewController) {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            vc.modalPresentationStyle = .fullScreen
            self.navigationController.present(nav, animated: true, completion: nil)
        }
    }
    
    
    func goToReply(post: Post) {
        DispatchQueue.main.async {
            
            self.feedViewModel.setConfig(.reply(post))
            self.feedViewModel.fetchReplies(forUser: post.user)
            let controller = UploadPostViewController(viewModel: self.feedViewModel,
                                                      coordiinator: self,
                                                      user: post.user,
                                                      config: .reply(post))
            
            
            self.navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func goToRepost(post: Post) {
        DispatchQueue.main.async {
            
            self.feedViewModel.setConfig(.repost(post))
            self.feedViewModel.fetchReplies(forUser: post.user)
            let controller = UploadPostViewController(viewModel: self.feedViewModel,
                                                      coordiinator: self,
                                                      user: post.user,
                                                      config: .repost(post))
            
            
            self.navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func pop(vc: UIViewController) {
        self.navigationController.popToRootViewController(animated: true)
    }
    
    func goToProfile(user: User) {
        DispatchQueue.main.async {
            let controller = ProfileViewController(user: user)
            controller.viewModel = self.feedViewModel
            controller.userViewModel = UserViewModel(userService: UserRepository())
            controller.coordinator = self
            self.navigationController.pushViewController(controller, animated: true)
        }
    }
}

/// Here you can extends any delegate, to navigate to another page or trigger a new coordinator if the new screen is not a part of home group.
extension HomeCoordinator  { }
