//
//  ProfileFilterCell.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    //MARK: Properties
    static let identifier = "ProfileFilterCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Test Filtering"
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? .twitterBlue : .lightGray
        }
    }
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
    //MARK: Helpers
    
    func configureUI(){
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    func configure(option: String?){
        guard let option = option else {return}
        self.titleLabel.text = option
        
    }
}
