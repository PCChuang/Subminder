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

    private let userID = "NrNEOstTuDxTmkTkCVEY"

    var requestsFetched: [Request] = [] {

        didSet {

            tableView.reloadData()
        }
    }

//    var senderID: String = ""

    var senderIDs: [String] = []

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

        return cell
    }

    // update friend lists of sender and receiver
    @objc func acceptRequest(_ sender: UIButton) {

        UserManager.shared.addFriend(userID: userID, newFreind: senderIDs[sender.tag]) { result in

            switch result {

            case .success(let senderID):

                print(senderID)

            case .failure(let error):

                print("acceptFriend.failure: \(error)")
            }

        }

        UserManager.shared.addFriend(userID: senderIDs[sender.tag], newFreind: userID) { result in

            switch result {

            case .success(let userID):

                print(userID)

            case .failure(let error):

                print("acceptFriend.failure: \(error)")
            }

        }

        RequestManager.shared.closeRequest(userID: userID, senderID: senderIDs[sender.tag]) { result in

            switch result {

            case .success(let userID):

                print(userID)

            case .failure(let error):

                print("closeRequest.failure: \(error)")
            }
        }

        // delete indexPath.row
        let hitPoint = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: hitPoint) {
            
            requestsFetched.remove(at: indexPath.row)
        }
    }
}

extension FriendRequestViewController {

    // fetch received friend request
    func fetchFriendRequest() {

        RequestManager.shared.fetchRequest(id: userID) { [weak self] result in

            switch result {

            case .success(let requests):

                print("fetchRequests success")

                for request in requests {
                    self?.requestsFetched.append(request)
                    let senderID = request.from
                    self?.senderIDs.append(senderID)
                    self?.fetchSenderInfo(senderID: senderID)
                }

                print(self?.requestsFetched)

            case .failure(let error):

                print("fetchRequests.failure: \(error)")
            }
        }
    }

    // get sender's name and image with user ID
    func fetchSenderInfo(senderID: String) {
        
        UserManager.shared.searchUser(id: senderID) { [weak self] result in

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
}
