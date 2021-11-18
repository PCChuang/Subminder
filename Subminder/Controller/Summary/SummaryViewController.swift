//
//  SummaryViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class SummaryViewController: SUBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView! {

        didSet {
            
            collectionView.delegate = self
            
            collectionView.dataSource = self
        }
    }

    let userUID = KeyChainManager.shared.userUID

    let currencyManager = CurrencyManager()

    var subscriptions: [Subscription] = [] {

        didSet {
            collectionView.reloadData()
        }
    }

    var subscriptionsToEdit: [Subscription] = []
    
    var groupInfoOfSubs: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

        setupCollectionView()

        fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchData()
    }

    func fetchData() {

        SubsManager.shared.fetchSubs(uid: userUID ?? "") { [weak self] result in

            switch result {

            case .success(let subscriptions):

                print("fetchSubs success")

                self?.subscriptions.removeAll()

                for subscription in subscriptions {
                    self?.subscriptions.append(subscription)
                }

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }

    func setupBarItems() {

        let customView = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        
        customView.text = "訂閱"
        customView.textColor = .white
        customView.font = UIFont(name: "PingFang TC Medium", size: 18)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: customView
        )
        
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

//        cnavigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
//
//        navigationController?.navigationBar.isTranslucent = false

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Drawer"),
                style: .done,
                target: self,
                action: #selector(sortSubscription)
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
    
    @objc func sortSubscription() {
        
        let controller = UIAlertController(title: "訂閱項目排序",
                                           message: "請選擇排序方式",
                                           preferredStyle: .actionSheet)
        
        let orderStyles = ["按付款期限排序", "按付款金額排序"]
        
        for orderStyle in orderStyles {
            
            let action = UIAlertAction(title: orderStyle, style: .default) { action in
                
                switch orderStyle {
                    
                case "按付款期限排序":
                    
                    self.subscriptions.sort { $0.dueDate < $1.dueDate }
                    
                case "按付款金額排序":
                    
                    self.subscriptions.sort { $0.exchangePrice < $1.exchangePrice }
                    
                default:
                    
                    self.subscriptions.sort { $0.dueDate < $1.dueDate }
                }
            }
            
            controller.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }

    private func setupCollectionView() {

        let nib = UINib(nibName: "SummaryCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SummaryCell")

        setupCollectionViewLayout()
    }

    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int(UIScreen.main.bounds.width - 32),
            height: 91
        )

        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 24.0, right: 16.0)

        flowLayout.minimumInteritemSpacing = 0

        flowLayout.minimumLineSpacing = 8.0

        collectionView.collectionViewLayout = flowLayout
    }
}

extension SummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        subscriptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCell", for: indexPath) as? SummaryCell else {
            fatalError()
        }
        cell.name.text = subscriptions[indexPath.item].name
        cell.price.text = "NT$ \(subscriptions[indexPath.item].exchangePrice)"
        cell.cycle.text = subscriptions[indexPath.item].cycle
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: subscriptions[indexPath.item].color)
        cell.layer.cornerRadius = 10

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        cell.dueDate.text = formatter.string(from: subscriptions[indexPath.item].dueDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var selectedSubscription: Subscription?

        selectedSubscription = subscriptions[indexPath.item]

        if let controller = storyboard?.instantiateViewController(identifier: "AddToSub") as? AddToSubViewController {

            controller.subscription.id = selectedSubscription?.id ?? ""
            
            controller.group.id = selectedSubscription?.groupID ?? ""

            fetchSubscriptionToEdit(subscriptionID: selectedSubscription?.id ?? "") {
                
                controller.subscriptionsInEdit = self.subscriptionsToEdit

                DispatchQueue.main.async {

                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }

        }
    }
}

extension SummaryViewController {

    func fetchSubscriptionToEdit(subscriptionID: String, completion: @escaping () -> Void) {

        SubsManager.shared.fetchSubsToEdit(subscriptionID: subscriptionID) { [weak self] result in
            
            switch result {

            case .success(let subscriptions):

                print("fetchSubs success")

                self?.subscriptionsToEdit.removeAll()

                for subscription in subscriptions {
                    self?.subscriptionsToEdit.append(subscription)
                }

                completion()

            case .failure(let error):

                print("fetchData.failure: \(error)")
            }
        }
    }
    
//    func fetchGroupInfo(groupID: String) {
//        
//        GroupManager.shared.searchGroup(id: groupID) { [weak self] result in
//            
//            switch result {
//                
//            case .success(let groups):
//                
//                print("fetchGroup success")
//                
//                for group in groups {
//                    self?.groupInfoOfSubs.append(group)
//                }
//                
//            case .failure(let error):
//                
//                print("fetchGroup.failure: \(error)")
//            }
//        }
//    }
}
