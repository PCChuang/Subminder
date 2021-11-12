//
//  AddFriendViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/28.
//

import UIKit

class AddFriendViewController: SUBaseViewController {

    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var searchBtn: UIButton!

    @IBOutlet weak var friendImg: UIImageView!

    @IBOutlet weak var friendNameLbl: UILabel!

    @IBOutlet weak var sendRequestBtn: UIButton!

    @IBAction func searchFieldDidEnter(_ sender: UITextField) {

        searchFriend()
    }

    @IBAction func onTapSendRequest(_ sender: UIButton) {

        sendFriendRequest(with: &request)
    }

    let userUID = KeyChainManager.shared.userUID

    var searchText: String = ""

    var request: Request = Request(
        to: "",
        from: ""
    )

    var searchResults: [User] = []
    
    var friendsList: [String] = []
    
    var friendsInfo: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        setupProfileView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchFriendList(userUID: userUID ?? "")
    }

    func setupBarItems() {

        self.navigationItem.title = "加入好友"

        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        navigationController?.navigationBar.isTranslucent = false
    }

    func setupProfileView() {

        searchBtn.setTitle("", for: .normal)

        friendImg.layer.cornerRadius = friendImg.frame.size.width / 2.0

        friendImg.isHidden = true

        friendNameLbl.isHidden = true

        sendRequestBtn.isHidden = true
    }

    func searchFriend() {

        guard let text = searchTextField.text else { return }

        searchText = text

        UserManager.shared.searchUser(uid: searchText) { [weak self] result in

            switch result {

            case .success(let users):

                print("searchFriend success")

                for user in users {
                    self?.searchResults.append(user)
                }
                
                print(self?.searchResults)

                if self?.searchResults.count != 0 {

                    self?.friendImg.isHidden = false

                    self?.friendNameLbl.isHidden = false

                    self?.sendRequestBtn.isHidden = false

                    self?.friendNameLbl.text = self?.searchResults[0].name
                    
                    if self?.friendsList.contains(self?.searchResults.first?.uid ?? "") == true {
                        
                        self?.disableSendBtn(title: "已經是朋友囉")
                    }
                } else {

                    self?.friendNameLbl.isHidden = false

                    self?.friendNameLbl.text = "搜尋無此ID，請重新輸入搜尋"
                }

            case .failure(let error):

                print("searchFriend.failure: \(error)")
            }
        }
    }

    func sendFriendRequest(with request: inout Request) {

        request.to = searchText

        request.from = userUID ?? ""

        RequestManager.shared.sendRequest(request: &request) { result in

            switch result {

            case .success:
                print("onTapSend, success")
                self.disableSendBtn(title: "已發送好友邀請")

            case .failure(let error):
                print("sendFriendRequest.failure: \(error)")
            }
        }
    }
    
    func fetchFriendList(userUID: String) {
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("fetchFriendList success")
                
                self?.friendsInfo.removeAll()

                for user in users {

                    let friends = user.friendList
                    self?.friendsList = friends

//                    for friend in friends {
//
//                        self?.fetchFriendInfo(friendUID: friend)
//                    }
                }

            case .failure(let error):

                print("fetchFriendList.failure: \(error)")
            }
        }
    }

    func disableSendBtn(title: String) {

        sendRequestBtn.isEnabled = false
        sendRequestBtn.setTitle(title, for: .disabled)
        sendRequestBtn.backgroundColor = .lightGray
        sendRequestBtn.tintColor = .white
    }

}
