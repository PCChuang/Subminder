//
//  NameGroupViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/6.
//

import UIKit

class NameGroupViewController: SUBaseViewController {
    
    @IBOutlet weak var groupImg: UIImageView!
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var subscriptionNameTextField: UITextField!
    
    @IBAction func subscriptionName(_ sender: UITextField) {
        
        groupSubscriptionName = sender.text
    }
    var membersInfo: [User] = []
    
    var hostsInfo: [User] = []
    
    var groupSubscriptionName: String?
    
    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionName: ""
    )
    
    var groupSubscription: Subscription = Subscription(
        
        userUID: "",
        id: "",
        name: "",
        price: 0,
        currency: "",
        exchangePrice: 0,
        startDate: Date(),
        dueDate: Date(),
        cycle: "",
        duration: "",
        category: "",
        color: "",
        reminder: "",
        note: "",
        groupID: "",
        groupName: "",
        groupPriceTotal: 0,
        groupMemberCount: 0
    )
    
    var payable: Payable = Payable(
        
        id: "",
        groupID: "",
        userUID: "",
        amount: 0,
        nextPaymentDate: Date(),
        startDate: Date(),
        cycleAmount: 0
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
        
        groupImg.layer.cornerRadius = groupImg.frame.width / 2
        
        fetchHostInfo(hostUID: userUID)
        
        setupTextField()

        setupCollectionView()
        
        setupBarItems()
    }
    
    func createGroup() {
        
        self.add(with: &group)
    }
    
    func setupTextField() {
        
        groupNameTextField.attributedPlaceholder = NSAttributedString(
            string: "請輸入群組名稱",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        subscriptionNameTextField.attributedPlaceholder = NSAttributedString(
            string: "請輸入訂閱項目名稱",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
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

        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.tintColor = .white

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: "建立",
                style: .done,
                target: self,
                action: #selector(navAddToSub)
            )
    }
    
    @objc func navAddToSub() {
        
        if groupNameTextField.text == "" {
            
            showAlert(title: "Oops!", message: "請輸入訂閱項目名稱")
        } else {
            
            createGroup()
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        
//        if groupNameTextField.text == "" {
//
//            showAlert(title: "Oops!", message: "請輸入訂閱項目名稱")
//        } else if groupSubscriptionName == "" {
//
//            showAlert(title: "Oops!", message: "請輸入群組名稱")
//        } else {
//
//            createGroup()
//
////            let summaryStoryboard = UIStoryboard(name: "Summary", bundle: nil)
////
////            if let controller = summaryStoryboard.instantiateViewController(withIdentifier: "AddToSub") as? AddToSubViewController {
////
////                controller.group = self.group
////
////                controller.groupSubscriptionName = self.groupSubscriptionName
////
////                self.navigationController?.pushViewController(controller, animated: true)
////            }
//
//            _ = self.navigationController?.popToRootViewController(animated: true)
//        }
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
        
//        group.subscriptionName = groupSubscriptionName ?? ""
        
        // create group collection
        GroupManager.shared.createGroup(group: &group) { result in
            
            switch result {
                
            case .success:
                
                print("onTapAddGroup, success")

            case .failure(let error):

                print("onTapAddGroup.failure: \(error)")
            }
        }
        
        // update groupList of users and host
        UserManager.shared.joinGroup(userIDs: userIDs, hostID: hostID, newGroup: group.id) { result in
            
            switch result {
                
            case .success(let userUIDs):

                print(userUIDs)

            case .failure(let error):

                print("joinGroup.failure: \(error)")
            }
        }
        
        // create payable for all members
            payable.groupID = group.id
            
            PayableManager.shared.createPayableInBatch(
                totalAmount: 0,
                amount: 0,
                nextPaymentDate: Date(),
                userUIDs: group.userUIDs,
                hostUID: group.hostUID,
                startDate: Date(),
                cycleAmount: 0,
                payable: &payable
            ) { result in
                
                switch result {
                    
                case .success:
                    
                    print("createNewPayable, success")
                    
                case .failure(let error):
                    
                    print("createNewPayable.failure: \(error)")
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
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
