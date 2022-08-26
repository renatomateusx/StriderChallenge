//
//  PostsRepository.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

protocol PostsRepositoryProtocol: AnyObject {
    
    var appConfiguration: AppConfigurations { get }
    
    func fetchData(_ page: Int, completion: @escaping(Result<Posts, Error>) -> Void)
}

class PostsRepository {
    private let service: NetworkRepository
    let appConfiguration: AppConfigurations
    
    init(service: NetworkRepository = NetworkRepository(),
         appConfiguration: AppConfigurations = AppConfigurations()) {
        self.service = service
        self.appConfiguration = appConfiguration
    }
}

extension PostsRepository: PostsRepositoryProtocol {
    func fetchData(_ page: Int, completion: @escaping(Result<Posts, Error>) -> Void) {
        let endpoint = PostsEndpoint(appConfiguration: self.appConfiguration)
        _ = service.request(for: endpoint.url, completion: completion)
    }
}
