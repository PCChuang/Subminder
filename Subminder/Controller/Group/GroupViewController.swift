//
//  GroupViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class GroupViewController: SUBaseViewController {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var addGroupBtn: UIButton!

    @IBOutlet weak var tableView: UITableView! {

        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }

    @IBOutlet weak var profileCollection: UICollectionView! {

        didSet {

            profileCollection.delegate = self

            profileCollection.dataSource = self
        }
    }

    let userUID = KeyChainManager.shared.userUID
    
    let manager = ProfileManager()
    
    var usersInfo: [User] = []
    
    var groupsList: [String] = []
    
    var groupsInfo: [Group] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }

    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionName: ""
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2.0

        setupCollectionView()

        setupAddGroupBtn()

        registerCell()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserGroupList(userUID: userUID ?? "")
    }

    @IBAction func navSelectGroupMember(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SelectGroupMember") as? SelectGroupMemberViewController {

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func setupAddGroupBtn() {

        addGroupBtn.setTitle(nil, for: .normal)
    }

    private func registerCell() {

        let nib = UINib(nibName: "GroupCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GroupCell")
        
    }

    private func setupCollectionView() {

        let nib = UINib(nibName: "ProfileCell", bundle: nil)

        profileCollection.register(nib, forCellWithReuseIdentifier: "ProfileCell")

        setupCollectionViewLayout()
    }

    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int(UIScreen.main.bounds.width - 156) / 3,
            height: 60
        )

        flowLayout.minimumInteritemSpacing = 0

        flowLayout.minimumLineSpacing = 0

        profileCollection.collectionViewLayout = flowLayout
    }
    
    private func setupBarItems() {
        
        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        navigationController?.navigationBar.isTranslucent = false
    }

}

extension GroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return manager.profileItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath)

        guard let profileCell = cell as? ProfileCell else { return cell }

        let title = manager.profileItems[indexPath.row].title

        profileCell.itemLbl.text = title

        return profileCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.item {

        case 0:
            _ = navigationController?.popViewController(animated: true)

        default:

            if let controller = storyboard?.instantiateViewController(withIdentifier: "Friend") as? FriendViewController {

                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension GroupViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        groupsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        guard let cell = cell as? GroupCell else {
            return cell
        }
        
        cell.setupCell(
            subscriptionName: groupsInfo[indexPath.row].subscriptionName,
            groupName: groupsInfo[indexPath.row].name,
            numberOfMember: groupsInfo[indexPath.row].userUIDs.count + 1)
        
        return cell
    }
}

// functions calling APIs
extension GroupViewController {
    
    func addGroup(with group: inout Group) {

        GroupManager.shared.createGroup(group: &group) { result in
            
            switch result {
                
            case .success:
                
                print("Add New Group, Success")
                
            case .failure(let error):
                
                print("Add New Group, failure: \(error)")
            }
        }
    }
    
    func fetchUserGroupList(userUID: String) {
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("fetchGroupList success")
                
                self?.groupsInfo.removeAll()
                
                for user in users {
                    
                    self?.usersInfo.append(user)
                    
                    let groups = user.groupList
                    self?.groupsList = groups
                    print(self?.groupsList)
                    for group in groups {
                        
                        self?.fetchGroupInfo(groupID: group)
                    }
                }
                
            case .failure(let error):

                print("fetchFriendList.failure: \(error)")
            }
        }
    }
    
    func fetchGroupInfo(groupID: String) {
        
        GroupManager.shared.searchGroup(id: groupID) { [weak self] result in
            
            switch result {
                
            case .success(let groups):
                
                print("fetchGroupInfo success")

                for group in groups {
                    self?.groupsInfo.append(group)
                    print(self?.groupsInfo)
                }

            case .failure(let error):

                print("fetchGroupInfo.failure: \(error)")
            }
        }
    }
}
