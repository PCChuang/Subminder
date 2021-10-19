//
//  AddToSubViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class AddToSubViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        let nib = UINib(nibName: "AddSubCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubCell")

        let textNib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "AddSubTextCell")
    }

    func setupBarItems() {

        self.navigationItem.title = "新增訂閱項目"
    }
}

extension AddToSubViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 6, 7, 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
            guard let cell = cell as? AddSubCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
            guard let cell = cell as? AddSubTextCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell
        }

    }
}
