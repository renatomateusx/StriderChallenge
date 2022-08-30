//
//  UserRepository.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Firebase

protocol UserRepositoryProtocol: AnyObject {
    
    var appConfiguration: AppConfigurations { get }
    
    func fetchUser(uid: String, completion: @escaping (User)-> Void)
    func fetchUsers(completion: @escaping([User]) -> Void)
    func followUser(uid: String, completion: @escaping(DatabaseCompletion))
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion))
    func checkIfUserIsFollowd(uid: String, completion: @escaping(Bool) -> Void)
    func fetchUserStatus(uid: String, completion: @escaping(UserRelationStats) -> Void)
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion))
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void)
    func fetchUser(withUsername username: String, completion:@escaping(User) ->Void)
}

class UserRepository {
    private let service: NetworkRepository
    let appConfiguration: AppConfigurations
    var posts = Posts()
    
    
    init(service: NetworkRepository = NetworkRepository(),
         appConfiguration: AppConfigurations = AppConfigurations()) {
        self.service = service
        self.appConfiguration = appConfiguration
    }
}

extension UserRepository: UserRepositoryProtocol {
    func fetchUser(uid: String, completion: @escaping (User)-> Void) {
        DatabaseManager.shared.fetchUser(with: uid) { user in
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        REF_USERS.observe(.childAdded) {snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
            let user = User(with: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentId = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentId).updateChildValues([uid: 1]) { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentId: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentId = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentId).removeValue { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowd(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentId = Auth.auth().currentUser?.uid else {return}
        REF_USER_FOLLOWING.child(currentId).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStatus(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["fullname" : user.fullname, "username": user.username, "bio": user.bio ?? ""]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let filename = NSUUID().uuidString
        let ref = STORAGE_PROFILE_IMAGES.child(filename)
        
        ref.putData(imageData, metadata: nil) { (meta, error) in
            ref.downloadURL { (url, error) in
                guard let profileImageURL = url?.absoluteString else {return}
                let values = ["profileImageUrl": profileImageURL]
                
                REF_USERS.child(uid).updateChildValues(values) { (err, ref) in
                    completion(url)
                }
            }
        }
    }
    
    func fetchUser(withUsername username: String, completion:@escaping(User) ->Void) {
        REF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { snapshot in
            guard let uid = snapshot.value as? String else {return}
            self.fetchUser(uid: uid, completion: completion)
        }
    }
}
