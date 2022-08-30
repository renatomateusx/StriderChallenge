//
//  ConstantsDatabase.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import Firebase

///Profile Images
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_image")

///Database
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_USER_USERNAMES = DB_REF.child("user-usernames")

///Posts
let REF_POSTS = DB_REF.child("posts")
let REF_USER_POSTS = DB_REF.child("user-posts")
let REF_POST_REPLIES =  DB_REF.child("post-replies")
let REF_POST_LIKES = DB_REF.child("post-likes")
let REF_USER_REPLIES = DB_REF.child("user-replies")


//User Follow Unfollow
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")

//Notifications
let REF_NOTIFICATIONS = DB_REF.child("notifications")

let CHARACTERS_LENGTH = 777
let USERNAME_LENGTH = 14
