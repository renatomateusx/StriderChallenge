//
//  EditProfileOptions.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    //MARK: Properties
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        case .bio: return user.bio
        }
    }
    
    var shouldHidePlaceHolderLabel: Bool {
        return user.bio != nil
    }
    
    
    //MARK: Lifecycle
    init(user: User, option: EditProfileOptions){
        self.user = user
        self.option = option
    }
}
