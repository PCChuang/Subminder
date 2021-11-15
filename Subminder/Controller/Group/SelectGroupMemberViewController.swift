//
//  SelectGroupMemberViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import UIKit

class SelectGroupMemberViewController: SUBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    let userUID = KeyChainManager.shared.userUID
    
    var friendsList: [String] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var friendsInfo: [User] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var selectedFriends: [User] = [] {
        
        didSet {
            
            collectionView.reloadData()
            
//            collectionViewVisibility = true
        }
    }
    
    var selectedIndexPath: IndexPath? = nil
    
    var selectedIndexPathRow: [Int] = []
    
    var selectedIndexPathItem: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.isHidden = true
//
//        tableView.centerYAnchor.constraint(equalTo: tableView.superview!.centerYAnchor).isActive = true
        
        setupCollectionView()
        
        registerCell()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriendList(userUID: userUID ?? "")
    }
    
    private func setupCollectionView() {
        
        let removalNib = UINib(nibName: "GroupRemoveCell", bundle: nil)
        
        collectionView.register(removalNib, forCellWithReuseIdentifier: "GroupRemoveCell")
        
        setupCollectionViewLayout()
    }

    private func setupCollectionViewLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(
            width: 92,
            height: 110.5
        )
        
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.minimumLineSpacing = 0
        
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    private func registerCell() {
        
        let nib = UINib(nibName: "GroupInviteCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "GroupInviteCell")
    }
    
    private func setupBarItems() {
        
        self.navigationItem.title = "邀請好友"

        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Add01"),
                style: .done,
                target: self,
                action: #selector(navNameGroupMember)
            )
    }
    
    @objc func navNameGroupMember() {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "NameGroup") as? NameGroupViewController {
            
            controller.membersInfo = self.selectedFriends

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SelectGroupMemberViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        selectedFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupRemoveCell", for: indexPath)

        guard let removalCell = cell as? GroupRemoveCell else { return cell }
        
        removalCell.setupCell(friendName: selectedFriends[indexPath.item].name, hideRemovalBtn: true)

        return removalCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndexPathItem = indexPath.item
        let tableViewIndexPath = IndexPath(row: selectedIndexPathRow[indexPath.item], section: 0)
        tableView.deselectRow(at: tableViewIndexPath, animated: false)
        tableView.reloadRows(at: [tableViewIndexPath], with: .none)
        
//        tableView.reloadData()
        selectedFriends.remove(at: indexPath.item)
        print("selectedFriend === \(selectedFriends)")
        selectedIndexPathRow.remove(at: indexPath.item)
        print("selectedIndexPathRow === \(selectedIndexPathRow)")
    }
}

extension SelectGroupMemberViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        friendsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInviteCell", for: indexPath)
        guard let cell = cell as? GroupInviteCell else {
            return cell
        }
        
        if friendsInfo.count > 0 {
            
            cell.setupCell(friendName: friendsInfo[indexPath.row].name)
        }
        
        if cell.isSelected == false {
            
            cell.checkBox.on = false
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? GroupInviteCell
        
        let friend = friendsInfo[indexPath.row]
        
        if selectedIndexPath == indexPath || cell?.checkBox.on == true {

            selectedIndexPath = nil

            tableView.deselectRow(at: indexPath, animated: false)

            cell?.checkBox.on = false

            selectedFriends.removeAll { $0.name == "\(friend.name)" }
            
            selectedIndexPathRow.removeAll { $0 == indexPath.row }
        } else {
            
            selectedIndexPath = indexPath
            
            cell?.checkBox.on = true
            
            selectedFriends.append(friend)
            
            selectedIndexPathRow.append(indexPath.row)
        }
    }
}

// functions calling APIs
extension SelectGroupMemberViewController {

    func fetchFriendList(userUID: String) {
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchFriendList success")
                
                self?.friendsInfo.removeAll()
                
                for user in users {
                    
                    let friends = user.friendList
                    self?.friendsList = friends
                    
                    for friend in friends {
                        
                        self?.fetchFriendInfo(friendUID: friend)
                        print(self?.friendsInfo)
                    }
                }
                
            case .failure(let error):
                
                print("fetchFriendList.failure: \(error)")
            }
        }
    }
    
    func fetchFriendInfo(friendUID: String) {

        UserManager.shared.searchUser(uid: friendUID) { [weak self] result in

            switch result {

            case .success(let users):
                
                print("fetchFriendInfo success")

                for user in users {
                    
                    self?.friendsInfo.append(user)
                }

            case .failure(let error):

                print("fetchFriendInfo.failure: \(error)")
            }
        }
    }
}
