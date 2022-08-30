//
//  EditProfileHeader.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func didTapChangeProfilePhotoButton()
}

class EditProfileHeader: UIView {
    //MARK: Properties
    private let user:User
    weak var delegate: EditProfileHeaderDelegate?
    
    let profileImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 3.0
        return image
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.addTarget(EditProfileHeader.self, action: #selector(handleChangePhoto), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    //MARK: Lifecycle
    init(user: User){
        self.user = user
        super.init(frame: .zero)
        
        backgroundColor = .twitterBlue
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Selectors
    
    @objc func handleChangePhoto(){
        delegate?.didTapChangeProfilePhotoButton()
    }
    
    //MARK: Helpers
    
    func configureView(){
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
        profileImageView.sd_setImage(with: user.profileImage)
    }
}
