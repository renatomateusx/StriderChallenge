//
//  HomeViewModel.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

protocol HomeViewModelProtocol {
    func fetchData(_ page: Int)
    
    var weather: Bindable<Posts> { get set }
    var error: Bindable<Error> { get set }
}

class HomeViewModel {
    
    // MARK: - Private Properties
    let postsService: PostsRepositoryProtocol
    let coordinator: HomeCoordinator
    var weather = Bindable<Posts>()
    var error = Bindable<Error>()
    // MARK: - Inits
    
    init(with service: PostsRepositoryProtocol, coordinator: HomeCoordinator) {
        self.postsService = service
        self.coordinator = coordinator
    }
    
    func fetchData(_ page: Int) {
        postsService.fetchData(page) { result in
            switch result {
            
            case .success(let weather):
                self.weather.value = weather
            case .failure(let error):
                self.error.value = error
            }
        }
    }
}
