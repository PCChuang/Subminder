//
//  SummaryViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class SummaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()
        
    }

    func setupBarItems() {
        
        let customView = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        customView.text = "訂閱"
        customView.font = UIFont(name: "PingFang TC Medium", size: 18)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: customView
        )
        
        navigationController?.navigationBar.tintColor = .label
        
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
                action: #selector(navAdd)
            )
        ]
        
    }
    
    @objc func navAdd() {
        
        if let controller = storyboard?.instantiateViewController(identifier: "AddToSub") as? AddToSubViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }

}
