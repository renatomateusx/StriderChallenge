//
//  AuthManager.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import FirebaseAuth

public class AuthManager {
    static let shared = AuthManager()
   
    // MARK: public functions
    /// Create a new user
    func registerNewUser(with credentials: Authentication, completion: @escaping (Bool) -> Void){
        var imageURL: String!
        guard let imageData = credentials.profileImage?.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        
        
        DatabaseManager.shared.canCreateNewUser(with: credentials.email, username: credentials.username) { canCreate in
            if canCreate {
               
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                    guard error == nil, result != nil else {
                        completion(false)
                        return
                    }
                    // Insert into database
                    guard let uuid = result?.user.uid else {return}
                    let joinedDate = Int(NSDate().timeIntervalSince1970)
                    let credentialsList = ["email": credentials.email,
                                           "username": credentials.username,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": nil,
                                           "joinedDate": joinedDate] as [String : AnyObject]
                    
                    DatabaseManager.shared.updateUser(with: uuid, values: credentialsList) { inserted in
                        if inserted {
                            
                           completion(true)
                            return
                        }
                        else {
                            // Failed to insert to database
                            completion(false)
                            return
                        }
                    }
                }
                
               
            }else{
                completion(false)
            }
        }
    }
    /// Login with an User
    public func login(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void){
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
        else if let username = username {
            // usernamelogin
            print(username)
        }
    }
    /// Attempt to log out from firebase
    public func logOut(completion: @escaping (Bool) -> Void){
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch{
            completion(false)
            print(error)
            return
        }
    }
}
