//
//  SummaryViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit
import nanopb

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

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        cell.dueDate.text = formatter.string(from: subscriptions[indexPath.item].dueDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var selectedSubscription = ""

        selectedSubscription = subscriptions[indexPath.item].id

        if let controller = storyboard?.instantiateViewController(identifier: "AddToSub") as? AddToSubViewController {

            controller.subscription.id = selectedSubscription

            fetchSubscriptionToEdit(subscriptionID: selectedSubscription) {

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
}
