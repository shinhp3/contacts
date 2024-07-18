//
//  AddFriend.swift
//  phoneBook
//
//  Created by 신효범 on 7/18/24.
//

import UIKit

protocol AddFriendDelegate: AnyObject {
    func didAddContact(contact: [String: String])
}

class AddFriend: UIViewController {
    
    weak var delegate: AddFriendDelegate?
    let profileImageView = UIImageView()
    let randomImageButton = UIButton()
    let nameTextView = UITextField()
    let phoneTextView = UITextField()
    var profileImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view .backgroundColor = .white
        title = "연락처 추가"
        
        let addButton = UIBarButtonItem(title: "적용", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        // 프로필 이미지 설정
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 75
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.contentMode = .scaleAspectFill
        view.addSubview(profileImageView)
        
        // 랜덤 이미지 생성 버튼 설정
        randomImageButton.setTitle("랜덤 이미지 생성", for: .normal)
        randomImageButton.setTitleColor(.systemBlue, for: .normal)
        randomImageButton.translatesAutoresizingMaskIntoConstraints = false
        randomImageButton.addTarget(self, action: #selector(randomImage), for: .touchUpInside)
        view.addSubview(randomImageButton)
        
        // 이름 입력 필드 설정
        nameTextView.placeholder = "이름"
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        nameTextView.layer.borderWidth = 1
        nameTextView.layer.borderColor = UIColor.gray.cgColor
        nameTextView.layer.cornerRadius = 5
        nameTextView.font = UIFont.systemFont(ofSize: 18)
        let namePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTextView.frame.height))
        nameTextView.leftView = namePaddingView
        nameTextView.leftViewMode = .always
        
        
        view.addSubview(nameTextView)
        
        // 전화번호 입력 필드 설정
        phoneTextView.placeholder = "전화번호"
        phoneTextView.translatesAutoresizingMaskIntoConstraints = false
        phoneTextView.layer.borderWidth = 1
        phoneTextView.layer.borderColor = UIColor.gray.cgColor
        phoneTextView.layer.cornerRadius = 5
        phoneTextView.font = UIFont.systemFont(ofSize: 18)
        let phonePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: phoneTextView.frame.height))
        phoneTextView.leftView = phonePaddingView
        phoneTextView.leftViewMode = .always
        
        view.addSubview(phoneTextView)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            
            randomImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            randomImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextView.topAnchor.constraint(equalTo: randomImageButton.bottomAnchor, constant: 20),
            nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextView.heightAnchor.constraint(equalToConstant: 50),
            
            phoneTextView.topAnchor.constraint(equalTo: nameTextView.bottomAnchor, constant: 20),
            phoneTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneTextView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                print("데이터 로드 실패: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    //적용 버튼 로직
    @objc func saveButtonTapped() {
        let name = nameTextView.text ?? ""
        let phone = phoneTextView.text ?? ""
        
        // UserDefaults에 저장
        var contacts = UserDefaults.standard.array(forKey: "contacts") as? [[String: String]] ?? []
        let newContact = ["name": name, "phone": phone, "profileImageUrl": profileImageUrl ?? ""]
        contacts.append(newContact)
        UserDefaults.standard.set(contacts, forKey: "contacts")
        
        print("이름: \(name), 전화번호: \(phone) 저장됨")
        
        // delegate를 통해 ViewController에 데이터가 추가되었음을 알림
        delegate?.didAddContact(contact: newContact)
        
        // 이전 화면으로 돌아가기
        navigationController?.popViewController(animated: true)  
    }
    
    
    //랜덤 이미지 로직
    @objc func randomImage() {
        print("random")
        let randomId = Int.random(in: 1...1000)
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(randomId)"
        
        guard let url = URL(string: urlString) else { return }
        
        fetchData(url: url) { (pokemon: Pokemon?) in
            guard let pokemon = pokemon, let imageUrlString = pokemon.sprites.frontDefault, let imageUrl = URL(string: imageUrlString) else {
                print("포켓몬 또는 이미지 URL 없음")
                return
            }
            
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                        self.profileImageUrl = imageUrlString
                    }
                }
            }
        }
    }
}



// Pokemon 모델 정의
struct Pokemon: Decodable {
    let sprites: Sprites
}

struct Sprites: Decodable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
