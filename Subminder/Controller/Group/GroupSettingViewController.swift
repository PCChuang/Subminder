//
//  GroupSettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/11.
//

import UIKit

class GroupSettingViewController: UIViewController {

    @IBOutlet weak var paymentConfirmBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    let userUID = KeyChainManager.shared.userUID
    
    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionName: ""
    )
    
    var hostInfo: [User] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var membersInfo: [User] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var memberListTitles = ["主揪", "分母"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        
        setupBarItems()
        
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchHostInfo(hostUID: group.hostUID)
        
        for userUID in group.userUIDs {
            
            fetchMemberInfo(userUID: userUID)
        }
    }
    
    @IBAction func paymentConfirmBtnDidTap(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SendBillingRequest") as? SendBillingRequestViewController {
            
            controller.group = self.group
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func setupButtons() {
        
        paymentConfirmBtn.layer.cornerRadius = 10
        
        paymentConfirmBtn.titleLabel?.font = UIFont(name: "PingFang TC Medium", size: 16)
        
        if userUID == group.hostUID {
            
            paymentConfirmBtn.setTitle("確認分母付款", for: .normal)
        }
    }
    
    private func setupBarItems() {
        
        let memberCount = group.userUIDs.count + 1
        
        self.navigationItem.title = "\(group.name) (\(memberCount))"
        
        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.tintColor = .white
    }
    
}

extension GroupSettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            
            return 1
            
        case 1:
            
            return membersInfo.count
            
        default:
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MemberHeaderView")
        
        guard let headerView = headerView as? MemberHeaderView else {
            
            return headerView
        }
        
        headerView.setupView(title: memberListTitles[section])
        
        headerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#AEAEB2")
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberTableViewCell", for: indexPath)
            
            guard let cell = cell as? GroupMemberTableViewCell else {
                return cell
            }
            
            if hostInfo.count > 0 {
                
                cell.setupCell(name: hostInfo.first?.name ?? "")
            }
            
//            cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#AEADB2")
            
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberTableViewCell", for: indexPath)
            
            guard let cell = cell as? GroupMemberTableViewCell else {
                return cell
            }
            
            if membersInfo.count > 0 {
                
                cell.setupCell(name: membersInfo[indexPath.row].name)
            }
            
//            cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#AEADB2")
            
            return cell
        }
        
    }
}

extension GroupSettingViewController {
    
    func registerCell() {
        
        let titleNib = UINib(nibName: "MemberHeaderView", bundle: nil)
        tableView.register(titleNib, forHeaderFooterViewReuseIdentifier: "MemberHeaderView")
        
        let memberNib = UINib(nibName: "GroupMemberTableViewCell", bundle: nil)
        tableView.register(memberNib, forCellReuseIdentifier: "GroupMemberTableViewCell")
    }
}

extension GroupSettingViewController {
    
    func fetchHostInfo(hostUID: String) {
        
        UserManager.shared.searchUser(uid: hostUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchHostInfo success")
                
                self?.hostInfo.removeAll()
                
                for user in users {
                    
                    self?.hostInfo.append(user)
                    print(self?.hostInfo)
                }
                
            case .failure(let error):
                
                print("fetchHostInfo.failure: \(error)")
            }
        }
    }
    
    func fetchMemberInfo(userUID: String) {
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchMemberInfo success")
                
//                self?.membersInfo.removeAll()
                
                for user in users {
                    
                    self?.membersInfo.append(user)
                    print(self?.membersInfo)
                }
                
            case .failure(let error):
                
                print("fetchMemberInfo.failure: \(error)")
            }
        }
    }
}
