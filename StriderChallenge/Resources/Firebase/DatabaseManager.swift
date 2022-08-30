//
//  DatabaseManager.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Foundation

import FirebaseDatabase

public class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    // MARK: public functions
    
    /// Check if a username and email is available
    /// - Parameters
    ///     - email: String representing email
    ///     - password: String representing password
    public func canCreateNewUser(with email: String, username: String, completion: @escaping (Bool)-> Void){
        completion(true)
    }
    
    /// Insert new user into a database
    /// - Parameters
    ///     - email: String representing email
    ///     - password: String representing password
    ///     - completion: Async callback for result if database entry succeded
    public func updateUser(with uuid: String, values: [String: Any], completion: @escaping (Bool)-> Void){
        REF_USERS.child(uuid).updateChildValues(values) { error, _ in
            if error == nil {
                //succeded
                completion(true)
                return
            }
            else {
                // failed
                completion(false)
                return
            }
        }
    }
    
    func fetchUser(with uuid: String, completion: @escaping (User)-> Void){
        REF_USERS.child(uuid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { completion(User(with: uuid)); return}
            
           
            let user = User(with: uuid, dictionary: dictionary)
            completion(user)
        }
    }
}
