//
//  CategoryViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/20.
//

import UIKit

class CategoryViewController: STBaseViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.dataSource = self

            tableView.delegate = self

            tableView.reloadData()
        }
    }

    var categories: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        let nib = UINib(nibName: "AddSubCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubCell")
    }

    func setupBarItems() {

        self.navigationItem.title = "分類"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Drawer"),
                style: .done,
                target: self,
                action: nil
            ),
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Add01"),
                style: .done,
                target: self,
                action: #selector(showInputAlert)
            )
        ]
    }

    @objc func showInputAlert() {

        let controller = UIAlertController(
            title: "新增分類",
            message: "請輸入分類名稱",
            preferredStyle: .alert
        )

        controller.addTextField { textField in
            textField.placeholder = "分類名稱"
        }

        let okAction = UIAlertAction(title: "新增", style: .default) { [unowned controller] _ in
            guard let category = controller.textFields?[0].text else { return }
            self.categories.append(category)
//            self.tableView.reloadData()
            print("\(category) is added")
            print(self.categories)
        }

        controller.addAction(okAction)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        controller.addAction(cancelAction)

        present(controller, animated: true, completion: nil)
    }

}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
        guard let cell = cell as? AddSubCell else {
            return cell
        }
        cell.title.text = categories[indexPath.row]
        cell.nextPageBtn.isHidden = true
        return cell
    }
}
