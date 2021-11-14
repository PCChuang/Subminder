//
//  SettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit
import FirebaseAuth

class SettingViewController: SUBaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    func logOut() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("logout btn did tap")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authNavController = storyboard.instantiateViewController(identifier: "AuthNavController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(authNavController)
    }
    
    var settingTitles = [
    
        "個人資料",
        "登出"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        
        setupBarItems()
    }

    func setupBarItems() {
        
        self.navigationItem.title = "設定"
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        settingTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        guard let cell = cell as? SettingCell else { return cell }
        
        cell.setupCell(title: settingTitles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: "PersonalSetting") as? PersonalSettingViewController {
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        case 1:
            
            logOut()
            
        default:
            
            return
        }
    }
}

extension SettingViewController {
    
    func registerCell() {
        
        let settingNib = UINib(nibName: "SettingCell", bundle: nil)
        tableView.register(settingNib, forCellReuseIdentifier: "SettingCell")
    }
}
