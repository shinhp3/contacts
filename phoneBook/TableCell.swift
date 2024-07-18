//
//  TableCell.swift
//  phoneBook
//
//  Created by 신효범 on 7/18/24.
//

import UIKit

class FriendCell: UITableViewCell{
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let phoneLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //프로필 이미지 설정
        profileImageView.layer.cornerRadius = 30
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)
        
        //이름 라벨 설정
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        //전화번호 라벨 설정
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phoneLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            
            phoneLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, phone: String, profileImageUrl: String?) {
        nameLabel.text = name
        phoneLabel.text = phone
        
        // 프로필 이미지 설정
        if let profileImageUrl = profileImageUrl, let url = URL(string: profileImageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        } else {
            // 기본 프로필 이미지 설정
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
}
