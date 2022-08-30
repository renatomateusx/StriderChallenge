//
//  PostsRepository.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Firebase

protocol PostsRepositoryProtocol: AnyObject {
    
    var appConfiguration: AppConfigurations { get }
    var posts: Posts { get }
    var replies: Posts { get }
    
    func uploadPost(text: String, type: UploadPostConfiguration, completion: @escaping(DatabaseCompletion))
    func fetchPosts(forUser user: User, completion: @escaping(Posts) -> Void)
    func fetchPosts(completion: @escaping(Posts) -> Void)
    func fetchReplies(forPost post: Post, completion: @escaping(Posts) -> Void)
    func fetchLikes(forUser user: User, completion: @escaping(Posts)->Void)
    func likePost(post: Post, completion: @escaping(DatabaseCompletion))
    func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) ->Void)
    func fetchPost(withPostID postID: String, completion: @escaping(Post) -> Void)
    func fetchReplies(forUser user: User, completion: @escaping(Posts) -> Void)
    
}

class PostsRepository {
    private let service: UserRepository
    let appConfiguration: AppConfigurations
    var posts = Posts()
    var replies = Posts()
    
    
    init(service: UserRepository = UserRepository(),
         appConfiguration: AppConfigurations = AppConfigurations()) {
        self.service = service
        self.appConfiguration = appConfiguration
    }
}

extension PostsRepository: PostsRepositoryProtocol {
    
    func uploadPost(text: String, type: UploadPostConfiguration, completion: @escaping(DatabaseCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0, "reposts": 0, "text": text] as [String: Any]
        
        switch type {
        case .post:
            REF_POSTS.childByAutoId().updateChildValues(values) { (err, ref) in
                guard let postID = ref.key else {return}
                REF_USER_POSTS.child(uid).updateChildValues([postID: 1], withCompletionBlock: completion)
            }
        case .reply(let post):
            values["replyingTo"] = post.user.username
            REF_POST_REPLIES.child(post.postID).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([post.postID: replyKey],
                                                              withCompletionBlock: completion)
            }
        case .repost(let post):
            values["repostingFrom"] = post.user.username
            REF_POST_REPLIES.child(post.postID).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([post.postID: replyKey],
                                                              withCompletionBlock: completion)
            }
        }
    }
    
    func fetchPosts(completion: @escaping(Posts) -> Void) {
        var posts = Posts()
        guard let currentUID = Auth.auth().currentUser?.uid else { completion(posts); return}
        
        REF_USER_FOLLOWING.child(currentUID).observe(.childAdded) { snapshot in
            let followingUID = snapshot.key
            
            REF_USER_POSTS.child(followingUID).observe(.childAdded) { snapshot in
                let postID = snapshot.key
                self.fetchPost(withPostID: postID) { post in
                    posts.append(post)
                    completion(posts)
                }
            }
            
        }
        REF_USER_POSTS.child(currentUID).observe(.childAdded) { snapshot in
            let postID = snapshot.key
            
            self.fetchPost(withPostID: postID) { post in
                posts.append(post)
                completion(posts)
            }
        }
        
    }
    
    func fetchPosts(forUser user: User, completion: @escaping(Posts) -> Void){
        var posts = Posts()
        REF_USER_POSTS.child(user.uuid).observe(.childAdded) { snapshot in
            let postID = snapshot.key
            
            self.fetchPost(withPostID: postID) { post in
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func fetchReplies(forPost post: Post, completion: @escaping(Posts) -> Void){
        var posts = Posts()
        REF_POST_REPLIES.child(post.postID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            let postID = snapshot.key
            self.service.fetchUser(uid: uid) { user in
                let post = Post(user: user, postID: postID, dictionary: dictionary)
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func fetchLikes(forUser user:User, completion: @escaping(Posts)->Void){
        var posts = Posts()
        
        REF_USER_LIKES.child(user.uuid).observe(.childAdded) { snapshot in
            let postID = snapshot.key
            self.fetchPost(withPostID: postID) { likedPost in
                var post = likedPost
                post.didLiked = true
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func likePost(post: Post, completion: @escaping(DatabaseCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let likes = post.didLiked ? post.likes - 1 : post.likes + 1
        
        REF_POSTS.child(post.postID).child("likes").setValue(likes)
        
        if post.didLiked {
            //unlike POST
            REF_USER_LIKES.child(uid).child(post.postID).removeValue { (err, ref) in
                REF_POST_LIKES.child(post.postID).removeValue(completionBlock: completion)
            }
        }
        else {
            //like POST
            REF_USER_LIKES.child(uid).updateChildValues([post.postID: 1]){ (err, ref) in
                REF_POST_LIKES.child(post.postID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
        
    }
    func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) ->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_USER_LIKES.child(uid).child(post.postID).observeSingleEvent(of: .value) {snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchPost(withPostID postID: String, completion: @escaping(Post) -> Void){
        REF_POSTS.child(postID).observeSingleEvent(of: .value) {snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            self.service.fetchUser(uid: uid) { user in
                let post = Post(user: user, postID: postID, dictionary: dictionary)
                completion(post)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping(Posts) -> Void){
        var replies = Posts()
        print("DEBUG: \(user.username)")
        REF_USER_REPLIES.child(user.uuid).observe(.childAdded) { snapshot in
            let POSTKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            print("DEBUG: \(POSTKey)")
            print("DEBUG: \(replyKey)")
            
            
            REF_POST_REPLIES.child(POSTKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                guard let uid = dictionary["uid"] as? String else {return}
                let replyID = snapshot.key
                
                self.service.fetchUser(uid:uid) { user in
                    let reply = Post(user: user, postID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
}

// MARK: - Mock
extension PostsRepository {
    private func mockPosts(){
        
        for i in 0..<4 {
            uploadPost(text: "Post Number \(i)", type: .post) { _, _ in }
        }
    }
}
