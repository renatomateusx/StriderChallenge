//
//  Coordinator.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}
