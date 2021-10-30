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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath)

        guard let cell = cell as? FriendRequestCell else {
            return cell
        }

        cell.setupCell(friendName: "123")

        return cell
    }
}
