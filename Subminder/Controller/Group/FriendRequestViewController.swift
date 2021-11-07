//
//  FriendRequestViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/30.
//

import UIKit

class FriendRequestViewController: SUBaseViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.dataSource = self

            tableView.delegate = self
        }
    }

    let userUID = KeyChainManager.shared.userUID

    var requestsFetched: [Request] = [] {

        didSet {

            tableView.reloadData()
        }
    }

    var senderUIDs: [String] = []

    var sendersInfo: [User] = [] {

        didSet {

            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchFriendRequest()

        setupBarItems()

        registerCell()
    }

    func setupBarItems() {

        self.navigationItem.title = "好友邀請"
    }

    func registerCell() {

        let nib = UINib(nibName: "FriendRequestCell", bundle: nil)

        tableView.register(nib, forCellReuseIdentifier: "FriendRequestCell")
    }

}

extension FriendRequestViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        requestsFetched.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath)

        guard let cell = cell as? FriendRequestCell else {
            return cell
        }

        if sendersInfo.count > 0 {
            
            cell.setupCell(friendName: sendersInfo[indexPath.row].name)
        }

        cell.confirmBtn.tag = indexPath.row

        cell.confirmBtn.addTarget(self, action: #selector(acceptRequest), for: .touchUpInside)

        cell.deleteBtn.tag = indexPath.row

        cell.deleteBtn.addTarget(self, action: #selector(rejectRequest), for: .touchUpInside)

        return cell
    }

    // update friend lists of sender and receiver
    @objc func acceptRequest(_ sender: UIButton) {

        UserManager.shared.addFriend(userID: sendersInfo[sender.tag].id, newFreind: senderUIDs[sender.tag]) { result in

            switch result {

            case .success(let senderUID):

                print(senderUID)

            case .failure(let error):

                print("acceptFriend.failure: \(error)")
            }

        }

        UserManager.shared.addFriend(userID: senderUIDs[sender.tag], newFreind: userUID ?? "") { result in

            switch result {

            case .success(let userUID):

                print(userUID)

            case .failure(let error):

                print("acceptFriend.failure: \(error)")
            }

        }

        closeFriendRequest(userUID: userUID ?? "", senderUID: senderUIDs[sender.tag])

        // delete indexPath.row
        deleteRow(sender: sender)
    }

    @objc func rejectRequest(_ sender: UIButton) {

        closeFriendRequest(userUID: userUID ?? "", senderUID: senderUIDs[sender.tag])

        deleteRow(sender: sender)
    }

    func closeFriendRequest(userUID: String, senderUID: String) {

        RequestManager.shared.closeRequest(userUID: userUID, senderUID: senderUID) { result in

            switch result {

            case .success(let userUID):

                print(userUID)

            case .failure(let error):

                print("closeRequest.failure: \(error)")
            }
        }
    }

    func deleteRow(sender: UIButton) {

        let hitPoint = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: hitPoint) {
            
            requestsFetched.remove(at: indexPath.row)
        }
    }
}

extension FriendRequestViewController {

    // fetch received friend request
    func fetchFriendRequest() {

        RequestManager.shared.fetchRequest(id: userUID ?? "") { [weak self] result in

            switch result {

            case .success(let requests):

                print("fetchRequests success")

                for request in requests {
                    self?.requestsFetched.append(request)
                    let senderUID = request.from
                    self?.senderUIDs.append(senderUID)
                    self?.fetchSenderInfo(senderUID: senderUID)
                }

                print(self?.requestsFetched)

            case .failure(let error):

                print("fetchRequests.failure: \(error)")
            }
        }
    }

    // get sender's name and image with user ID
    func fetchSenderInfo(senderUID: String) {
        
        UserManager.shared.searchUser(uid: senderUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("fetchSenderInfo success")

                for user in users {
                    self?.sendersInfo.append(user)
                }

                print(self?.sendersInfo)

            case .failure(let error):

                print("fetchSenderInfo.failure: \(error)")
            }
        }
    }
    
    func fetchReceiverInfo() {
        
        User
    }
}
