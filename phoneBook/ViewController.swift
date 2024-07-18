//
//  ViewController.swift
//  phoneBook
//
//  Created by 신효범 on 7/17/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddFriendDelegate {
    
    
    let tableView = UITableView()
    let addButton = UIButton()
    var contacts: [[String: String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "친구 목록"
        
        
        // 추가 버튼
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        // 편집 모드 버튼
        let editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(toggleEditing))
        navigationItem.leftBarButtonItem = editButton
        
        
        // 기존에 저장된 연락처 로드
        contacts = UserDefaults.standard.array(forKey: "contacts") as? [[String: String]] ?? []
        
        //테이블 뷰 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        
    }
    
    @objc func addButtonTapped() {
        let addFriendPage = AddFriend()
        addFriendPage.delegate = self
        self.navigationController?.pushViewController(addFriendPage, animated: true)
    }
    
    @objc func toggleEditing() {
        let isEditing = tableView.isEditing
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = isEditing ? "편집" : "완료"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let contact = contacts[indexPath.row]
        cell.nameLabel.text = contact["name"]
        cell.phoneLabel.text = contact["phone"]
        
        if let imageUrlString = contact["profileImageUrl"], let imageUrl = URL(string: imageUrlString) {
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        cell.profileImageView.image = nil
                    }
                    return
                }
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        } else {
            cell.profileImageView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                contacts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // UserDefaults에서 업데이트
                UserDefaults.standard.set(contacts, forKey: "contacts")
            }
        }
    

    func didAddContact(contact: [String: String]) {
        contacts.append(contact)
        tableView.reloadData()
    }
    
    
}




