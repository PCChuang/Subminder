//
//  GroupViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class GroupViewController: SUBaseViewController {

    @IBOutlet weak var profileImage: UIImageView!

//    @IBOutlet weak var addGroupBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var addGroupImage: UIImageView!
    
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
            
            setupProfileInfoView()
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
    
    var payables: [Payable] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var totalSubscriptions: [Subscription] = [] {
        
        didSet {
            profileCollection.reloadData()
        }
    }
    
    var subscriptions: [Subscription] = []
    
    var newGroupIDs = Set<String>() {

        didSet {

            for groupID in newGroupIDs {

                PayableManager.shared.fetch(uid: userUID ?? "", groupID: groupID) { [weak self] result in

                    guard let self = self else { return }

                    switch result {

                    case .success(let payable):
                        self.payableCache[groupID] = payable.first?.amount

                    case .failure(let error):
                        print("fetchPayable.failure: \(error)")
                    }
                }
            }
        }
    }
    
    var groupIDsSet = Set<String>() {
        
        didSet {
            
            if groupIDsSet != oldValue {
                
                newGroupIDs = groupIDsSet.subtracting(oldValue)
            }
        }
    }
    
    var payableCache: [String: Decimal] = [:] {
        
        didSet {
            
            tableView.reloadData()
            print("here is the cache========= \(payableCache)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("here is the cache========= \(payableCache)")

        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2.0

        setupCollectionView()

//        setupAddGroupBtn()
        
        setupAddGroupImage()

        registerCell()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserGroupList(userUID: userUID ?? "")
        
        fetchSubscriptions()
    }
    
    func setupProfileInfoView() {
        
        guard let user = usersInfo.first else { return }
        
        nameLbl.text = user.name
        
        if let url = URL(string: user.image),
           let data = try? Data(contentsOf: url) {
            
            self.profileImage.image = UIImage(data: data)
        }
    }

    func setupAddGroupImage() {
        
        addGroupImage.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddGroup))
        
        addGroupImage.addGestureRecognizer(gesture)
    }
    
    @objc func didTapAddGroup() {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SelectGroupMember") as? SelectGroupMemberViewController {

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
//    @IBAction func navSelectGroupMember(_ sender: UIButton) {
//
//        if let controller = storyboard?.instantiateViewController(withIdentifier: "SelectGroupMember") as? SelectGroupMemberViewController {
//
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
    
//    func updateUserPayable(groupID: String) {
//
//        // check payable cycle and amount/cycle
//        SubsManager.shared.fetchSubsForPayable(uid: userUID ?? "", groupID: groupID) { [weak self] result in
//
//            switch result {
//
//            case .success(let subscriptions):
//
//                print("fetchSubscriptions success")
//
//                self?.subscriptions.removeAll()
//
//                for subscription in subscriptions {
//                    self?.subscriptions.append(subscription)
//                }
//
//            case .failure(let error):
//
//                print("fetchSubscriptions.failure \(error)")
//            }
//        }
//    }
    
//    private func setupAddGroupBtn() {
//
//        addGroupBtn.setTitle(nil, for: .normal)
//    }

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
//
//        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
//
//        navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "群組"

        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
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
        
        profileCell.totalLbl.textAlignment = .center
        
        switch indexPath.item {
            
        case 0:
            
            profileCell.totalLbl.text = "\(totalSubscriptions.count)"
            
        case 1:
            
            let userInfo = usersInfo.first
            
            profileCell.totalLbl.text = "\(userInfo?.friendList.count ?? 0)"
            
        case 2:
            
            let userInfo = usersInfo.first
            
            profileCell.totalLbl.text = "\(userInfo?.groupList.count ?? 0)"
            
        default:
            
            return UICollectionViewCell()
        }

        return profileCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.item {

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
            numberOfMember: groupsInfo[indexPath.row].userUIDs.count + 1
        )
        
        if payableCache.count != 0 {
            
            if payableCache[groupsInfo[indexPath.row].id] ?? 0 < 0 {
                
                cell.payableLbl.backgroundColor = UIColor.hexStringToUIColor(hex: "#00896C")
                cell.payableLbl.text = " 應收 "
                cell.payableAmountLbl.text = " NT$ \(-(payableCache[groupsInfo[indexPath.row].id] ?? 0)) "
            } else if payableCache[groupsInfo[indexPath.row].id] == 0 {
                
                cell.payableLbl.backgroundColor = UIColor.hexStringToUIColor(hex: "#00896C")
                cell.payableLbl.text = " 結清 "
            } else {
                
                cell.payableLbl.backgroundColor = UIColor.hexStringToUIColor(hex: "#FFC408")
                cell.payableLbl.text = " 應付 "
                cell.payableAmountLbl.text = " NT$ \(payableCache[groupsInfo[indexPath.row].id] ?? 0) "
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedGroup: Group?
        
        selectedGroup = groupsInfo[indexPath.row]
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "GroupSetting") as? GroupSettingViewController {
            
            guard let selectedGroup = selectedGroup else {
                return
            }
            
            controller.group = selectedGroup
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
        
        self.groupsInfo.removeAll()
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("fetchGroupList success")
                
                for user in users {
                    
                    self?.usersInfo.append(user)
                    
                    let groups = user.groupList
                    self?.groupsList = groups
                    for group in groups {
                        
                        self?.fetchGroupInfo(groupID: group)
//
                        self?.fetchPayable(userUID: userUID, groupID: group)
                        
                        self?.groupIDsSet.insert(group)
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
                
                self?.groupsInfo.sort { $0.id > $1.id }

            case .failure(let error):

                print("fetchGroupInfo.failure: \(error)")
            }
        }
    }
    
    func fetchPayable(userUID: String, groupID: String) {
            
            PayableManager.shared.fetch(uid: userUID, groupID: groupID) { [weak self] result in
                
                switch result {
                    
                case .success(let payables):
                    
                    print("fetchPayable success")
                    
                    for payable in payables {
                        
                        self?.payables.append(payable)
                        
                        // update user's payable automatically
                        if payable.nextPaymentDate < Date() {
                            
                            var cycle: DateComponents?
                            cycle = Calendar.current.dateComponents([.year, .month, .day], from: payable.startDate, to: payable.nextPaymentDate)
                            
                            PayableManager.shared.update(
                                payableID: payable.id,
                                groupID: payable.groupID,
                                userUID: self?.userUID ?? "",
                                nextPaymentDate: Calendar.current.date(byAdding: cycle ?? DateComponents(), to: payable.nextPaymentDate) ?? Date(),
                                startDate: Calendar.current.date(byAdding: cycle ?? DateComponents(), to: payable.startDate) ?? Date(),
                                cycleAmount: payable.cycleAmount,
                                amount: payable.amount - payable.cycleAmount) { result in
                                    
                                    switch result {
                                        
                                    case .success:
                                        
                                        print("updatePayable, success")
                                        
                                    case .failure(let error):
                                        
                                        print("updatePayable.failure: \(error)")
                                    }
                                }
                        }
                    }
                    
                    print(self?.payables)
                    
                case .failure(let error):
                    
                    print("fetchPayable.failure: \(error)")
                }
            }
    }
    
    func fetchSubscriptions() {
        
        SubsManager.shared.fetchSubs(uid: userUID ?? "") { [weak self] result in

            switch result {

            case .success(let subscriptions):

                print("fetchSubs success")

                self?.totalSubscriptions.removeAll()

                for subscription in subscriptions {
                    self?.totalSubscriptions.append(subscription)
                }

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
}
