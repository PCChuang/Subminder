//
//  NameGroupViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/6.
//

import UIKit

class NameGroupViewController: SUBaseViewController {
    
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    var membersInfo: [User] = []
    
    var hostsInfo: [User] = []
    
    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionID: ""
    )

    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userUID = KeyChainManager.shared.userUID else { return }
        
        fetchHostInfo(hostUID: userUID)

        setupCollectionView()
        
        setupBarItems()
    }
    
    func createGroup() {
        
        self.add(with: &group)
    }
    
    private func setupCollectionView() {
        
        let nib = UINib(nibName: "GroupRemoveCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "GroupRemoveCell")
        
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
    
    private func setupBarItems() {
        
        self.navigationItem.title = "群組名稱"

        navigationController?.navigationBar.tintColor = .label

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: "建立",
                style: .done,
                target: self,
                action: #selector(navGroup)
            )
    }
    
    @objc func navGroup() {
        
        createGroup()
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "Group") as? GroupViewController {

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension NameGroupViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        membersInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupRemoveCell", for: indexPath)

        guard let memberCell = cell as? GroupRemoveCell else { return cell }
        
        memberCell.setupCell(friendName: membersInfo[indexPath.item].name, hideRemovalBtn: true)
        
        return memberCell
    }
}

// functions calling APIs
extension NameGroupViewController {
    
    func add(with group: inout Group) {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }
        
        group.hostUID = userUID
        
        group.userUIDs = membersInfo.map { $0.uid }
        
        let userIDs = membersInfo.map { $0.id }
        
        let hostID = hostsInfo.first?.id ?? ""
        
        group.name = groupNameTextField.text ?? ""
        
        // create group collection
        GroupManager.shared.createGroup(group: &group) { result in
            
            switch result {
                
            case .success:
                
                print("onTapAddGroup, success")

            case .failure(let error):

                print("onTapAddGroup.failure: \(error)")
            }
        }
        
        // update groupList users and host
        UserManager.shared.joinGroup(userIDs: userIDs, hostID: hostID, newGroup: group.id) { result in
            
            switch result {
                
            case .success(let userUIDs):

                print(userUIDs)

            case .failure(let error):

                print("joinGroup.failure: \(error)")
            }
        }
    }
    
    func fetchHostInfo(hostUID: String) {
        
        UserManager.shared.searchUser(uid: hostUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):

                print("fetchHostInfo success")

                for user in users {
                    self?.hostsInfo.append(user)
                }

            case .failure(let error):

                print("fetchHostInfo.failure: \(error)")
            }
        }
    }
}
