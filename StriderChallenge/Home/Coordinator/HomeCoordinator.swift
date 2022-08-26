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
    
    private weak var homeViewController: HomeViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel(with: WeatherRepository(), coordinator: self)
        
        let vc = HomeViewController()
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: false)
        homeViewController = vc
    }
    
    func goToDetails() {
        print("details")
    }
}

/// Here you can extends any delegate, to navigate to another page or trigger a new coordinator if the new screen is not a part of home group.
extension HomeCoordinator  { }
