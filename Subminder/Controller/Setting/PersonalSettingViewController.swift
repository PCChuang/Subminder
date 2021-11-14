//
//  PersonalSettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import UIKit

class PersonalSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()
    }

    func setupBarItems() {
        
        self.navigationItem.title = "個人資料"
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }

}
