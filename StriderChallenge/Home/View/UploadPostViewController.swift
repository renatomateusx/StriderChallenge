//
//  UploadPostViewController.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 28/08/22.
//

import UIKit
import ActiveLabel

class UploadPostViewController: UIViewController {
    
    // MARK: Properties
    let viewModel: FeedViewModelProtocol
    let coordinator: HomeCoordinator
    private var loading: UIActivityIndicatorView?
    
    let user: User
    private let config: UploadPostConfiguration
    
    private lazy var barButtonCancelTweet: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        return button
    }()
    
    private lazy var sendTweet: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet it!", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(didTapAddTweet), for: .touchUpInside)
        
        return button
    }()
    
    private let profileImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setDimensions(width: 48, height: 48)
        image.layer.cornerRadius = 48 / 2
        image.backgroundColor = .white
        return image
    }()
    
    private lazy var replyLabel: ActiveLabel = {
       let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "replying to @rufino"
        label.mentionColor = .twitterBlue
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        return label
    }()
    
    private let captionTextView = CaptionTextView()
    
    let charactersLeft: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "777 characters left"
        return label
    }()
    
    // MARK: Lifecycle
    
    init(viewModel: FeedViewModel, coordiinator: HomeCoordinator, user: User, config: UploadPostConfiguration) {
        self.viewModel = viewModel
        self.coordinator = coordiinator
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupObserver()
        configureMentionHandler()
    }
    
    // MARK: Selectors
    @objc func didTapCancelButton(){
        coordinator.pop(vc: self)
    }
    
    @objc func didTapAddTweet(){
        guard let text = captionTextView.text else {return}
        
        
        if checkTodaysLimit() {
            viewModel.uploadPost(text: text, type: config)
            coordinator.pop(vc: self)
        }
    }

    
    // MARK: Helpers
    
    func checkTodaysLimit() -> Bool {
        let todayPost = Utils.getDateFrom(date: Date())
        var count = 0
        for rep in viewModel.postsLocal {
            if let postedDate = rep.timestamp {
                let finalDate = Utils.getDateFrom(date: postedDate)
                if finalDate == todayPost {
                    count += 1
                }
            }
        }
        if count >= 5 {
            DispatchQueue.main.async {
                self.alert(title: .localized(.oopsTitle),
                           message: .localized(.postLimitReachedOut))
            }
            return false
        }
        for rep in viewModel.repliesLocal {
            if let postedDate = rep.timestamp {
                let finalDate = Utils.getDateFrom(date: postedDate)
                if finalDate == todayPost {
                    count += 1
                }
            }
        }
        if count >= 5 {
            DispatchQueue.main.async {
                self.alert(title: .localized(.oopsTitle),
                           message: .localized(.postLimitReachedOut))
            }
            return false
        }
        
        return true
    }
    
    func setupObserver() {
        viewModel.error.bind { [weak self] _ in
            if let error = self?.viewModel.error.value {
                DispatchQueue.main.async {
                    self?.alert(title: .localized(.oopsTitle), message: error.localizedDescription)
                    self?.loading?.stopAnimating()
                }
            }
        }
        
        viewModel.result.bind { [weak self] _ in
            if let result = self?.viewModel.result.value {
                if result {
                    self?.viewModel.fetchPosts(0)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func configureUI(){
        view.backgroundColor = .white
        configureNavigationBar()
        captionTextView.delegate = self
        let stackCaption = UIStackView(arrangedSubviews: [profileImageView,
                                                          captionTextView])
        stackCaption.axis = .horizontal
        stackCaption.spacing = 12
        stackCaption.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel,
                                                   stackCaption,
                                                   charactersLeft])
        stack.axis = .vertical
        //stack.alignment = .leading
        stack.spacing = 12
        
        view.addSubview(stack)
        let padding: CGFloat = 16
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingRight: padding)
        
        profileImageView.sd_setImage(with: user.profileImage, completed: nil)
        sendTweet.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        guard let replyText = viewModel.replyText else {return}
        replyLabel.text = replyText
        
        setupLoading()
    }
    
    private func setupLoading() {
        loading = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loading?.color = UIColor.white
        loading?.translatesAutoresizingMaskIntoConstraints = false
        if let loading = loading {
            self.view.addSubview(loading)
            loading.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            loading.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.leftBarButtonItem = barButtonCancelTweet
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendTweet)
    }
    
    func configureMentionHandler(){
        replyLabel.handleMentionTap { mention in
            print("DEBUG: Mentioned user is \(mention)")
        }
    }
}

extension UploadPostViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count == CHARACTERS_LENGTH {
            return false
        }
        let math = CHARACTERS_LENGTH - textView.text.count
        charactersLeft.text = .localizedFormat(.charLeft, String(math))
        return true
    }
}
