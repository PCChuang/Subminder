//
//  SelectGroupMemberViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import UIKit

class SelectGroupMemberViewController: SUBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()
    }
    
    private func setupBarItems() {
        
        self.navigationItem.title = "邀請好友"

        navigationController?.navigationBar.tintColor = .label

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Add01"),
                style: .done,
                target: self,
                action: nil
            )
    }
}
