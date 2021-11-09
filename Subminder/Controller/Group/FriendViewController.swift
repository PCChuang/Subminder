//
//  FriendViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/28.
//

import UIKit

class FriendViewController: SUBaseViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.dataSource = self

            tableView.delegate = self
        }
    }

    let userUID = KeyChainManager.shared.userUID

    var friendsList: [String] = [] {

        didSet {

            tableView.reloadData()
        }
    }

    var friendsInfo: [User] = [] {

        didSet {

            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        fetchFriendList(userID: userID)

        setupBarItems()

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchFriendList(userUID: userUID ?? "")
    }

    func setupBarItems() {

        self.navigationItem.title = "好友"

        navigationController?.navigationBar.tintColor = .label

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Add01"),
                style: .done,
                target: self,
                action: #selector(navAddFriend)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "mail"),
                style: .done,
                target: self,
                action: #selector(navFriendRequest)
            )
        ]
    }

    func registerCell() {

        let nib = UINib(nibName: "FriendRequestCell", bundle: nil)

        tableView.register(nib, forCellReuseIdentifier: "FriendRequestCell")
    }

    @objc func navAddFriend() {

        if let controller = storyboard?.instantiateViewController(identifier: "AddFriend") as? AddFriendViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @objc func navFriendRequest() {

        if let controller = storyboard?.instantiateViewController(identifier: "FriendRequest") as? FriendRequestViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension FriendViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        friendsInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath)

        guard let cell = cell as? FriendRequestCell else {
            return cell
        }

        if friendsInfo.count > 0 {
            
            cell.setupCell(friendName: friendsInfo[indexPath.row].name)
        }

        cell.confirmBtn.isHidden = true

        cell.deleteBtn.isHidden = true

        return cell
    }
}

extension FriendViewController {

    func fetchFriendList(userUID: String) {

        UserManager.shared.searchUser(uid: userUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("fetchFriendList success")
                
                self?.friendsInfo.removeAll()

                for user in users {

                    let friends = user.friendList
                    self?.friendsList = friends

                    for friend in friends {

                        self?.fetchFriendInfo(friendUID: friend)
                    }
                }

            case .failure(let error):

                print("fetchFriendList.failure: \(error)")
            }
        }
    }

    func fetchFriendInfo(friendUID: String) {

        UserManager.shared.searchUser(uid: friendUID) { [weak self] result in

            switch result {

            case .success(let users):
                
                print("fetchFriendInfo success")

                for user in users {
                    self?.friendsInfo.append(user)
                }

            case .failure(let error):

                print("fetchFriendInfo.failure: \(error)")
            }
        }
    }
}
