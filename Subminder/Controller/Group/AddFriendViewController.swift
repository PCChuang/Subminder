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

    var searchResults: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        setupProfileView()
    }

    func setupBarItems() {

        self.navigationItem.title = "加入好友"

        navigationController?.navigationBar.tintColor = .label
    }

    func setupProfileView() {

        searchBtn.setTitle("", for: .normal)

        friendImg.layer.cornerRadius = friendImg.frame.size.width / 2.0

        friendImg.isHidden = true

        friendNameLbl.isHidden = true

        sendRequestBtn.isHidden = true
    }

    func searchFriend() {

        guard let searchText = searchTextField.text else { return }

        UserManager.shared.searchUser(id: searchText) { [weak self] result in

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
                } else {

                    self?.friendNameLbl.isHidden = false

                    self?.friendNameLbl.text = "搜尋無此ID，請重新輸入搜尋"
                }

            case .failure(let error):

                print("searchFriend.failure: \(error)")
            }
        }
    }

}
