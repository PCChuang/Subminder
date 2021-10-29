//
//  FriendViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/28.
//

import UIKit

class FriendViewController: SUBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()
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
                action: nil
            )
        ]
    }

    @objc func navAddFriend() {

        if let controller = storyboard?.instantiateViewController(identifier: "AddFriend") as? AddFriendViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
