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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        registerCell()
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
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath)

        guard let cell = cell as? FriendRequestCell else {
            return cell
        }

        cell.setupCell(friendName: "123")

        cell.confirmBtn.isHidden = true

        cell.deleteBtn.isHidden = true

        return cell
    }
}
