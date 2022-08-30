//
//  ActionSheetCell.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import UIKit

class ActionSheetCell: UITableViewCell {
    //MARK: Properties
    static let identifier = "ActionSheetCell"
    
    private let optionsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "twitter_logo_blue")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Option"
        return label
    }()
    
    //MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers
    func configureUI(){
        addSubview(optionsImageView)
        optionsImageView.centerY(inView: self)
        optionsImageView.anchor(left: leftAnchor, paddingLeft: 8)
        optionsImageView.setDimensions(width: 36, height: 36)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: optionsImageView.rightAnchor, paddingLeft: 12)
    }
    
    func configure(option: String){
        titleLabel.text = option
    }
    
    //MARK: Selectors
}
