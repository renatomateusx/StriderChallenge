//
//  EditProfileViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import UIKit

protocol EditProfileViewControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileViewController, wantsToUpdate user:User)
    func handleLogout()
}

class EditProfileViewController: UITableViewController {
    
    //MARK: Properties
    var viewModel: UserViewModelProtocol!
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    
    private var userInfoChanged = false
    
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var selectedImage: UIImage? {
        didSet {headerView.profileImageView.image = selectedImage}
    }
    
    //MARK: Lifecycle
    
    init(user: User){
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       configureImagePicker()
        
        configureNavigationBar()
        configureTableView()
    }
    
    //MARK: Selectors
    @objc func didTapCancelButton(){
        dismiss(animated: true, completion: nil)
    }
    @objc func didTapDoneButton(){
        view.endEditing(true)
        guard imageChanged || userInfoChanged else {return}
        updateUserData()
    }
    //MARK: API
    func updateUserData(){
        
        if imageChanged && !userInfoChanged {
            // UPDATE PROFILE IMAGE
        }
    }
    
    //MARK: Helpers
    
    func configureImagePicker(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.barTintColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Edit Profile"
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        //navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func configureTableView(){
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        tableView.tableFooterView = footerView
        headerView.delegate = self
        footerView.delegate = self
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: EditProfileCell.identifier)
    }
}

extension EditProfileViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileCell.identifier,
                                                 for: indexPath) as! EditProfileCell
        cell.delegate = self
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {return cell}
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        return cell
    }
}

extension EditProfileViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {return 0}
        return option == .bio ? 100 : 48
    }
}

extension EditProfileViewController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhotoButton() {
       present(imagePicker, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {return}
        self.selectedImage = image
        
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController: EditProfileCellDelegate{
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else {return}
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else {return}
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else {return}
            user.username = username
        case .bio:
            guard let bio = cell.bioTextView.text else {return}
            user.bio = bio
        }
    }
    
    
}

extension EditProfileViewController: EditProfileFooterDelegate {
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _IOFBF in
            self.dismiss(animated: true) {
                self.delegate?.handleLogout()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
