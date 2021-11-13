//
//  SendBillingRequestViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/13.
//

import UIKit

class SendBillingRequestViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    var paymentInputFields = [
        
        "付款日期",
        "付款金額",
        "備註"
    ]
    
    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionName: ""
    )
    
    var billingRequest: BillingRequest = BillingRequest(
        
        id: "",
        groupID: "",
        userUID: "",
        hostUID: "",
        paymentDate: Date(),
        paymentAmount: 0,
        note: ""
    )
    
    var billingHistory: BillingHistory = BillingHistory(
        
        id: "",
        groupID: "",
        userUID: "",
        hostUID: "",
        paymentDate: Date(),
        paymentAmount: 0,
        note: ""
    )
    
    let userUID = KeyChainManager.shared.userUID
    
    var requestsFetched: [BillingRequest] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var senderUIDs: [String] = []
    
    var sendersInfo: [User] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if userUID == group.hostUID {
            
            fetchRequest()
        }
        
        registerCell()
        
        setupBarItems()
    }
    
    func setupBarItems() {
        
        self.navigationItem.title = "付款回報"
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

        if userUID != group.hostUID {
            
            navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: "保存",
                style: .done,
                target: self,
                action: #selector(sendBillingRequest)
            )
        }
    }
    
    @objc func sendBillingRequest() {
        
        self.createRequest(with: &billingRequest)
        
        DispatchQueue.main.async {
            
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SendBillingRequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userUID == group.hostUID {
            
            return requestsFetched.count
        }
        
        return paymentInputFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if userUID == group.hostUID {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentInfoTableViewCell", for: indexPath)
            guard let cell = cell as? PaymentInfoTableViewCell else {
                return cell
            }
            
            if sendersInfo.count > 0 {
                
                // convert Date to String
                let date = requestsFetched[indexPath.row].paymentDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                let dateString = dateFormatter.string(from: date)
                
                cell.setupCell(
                    name: sendersInfo[indexPath.row].name,
                    amount: "\(requestsFetched[indexPath.row].paymentAmount)",
                    date: dateString,
                    note: requestsFetched[indexPath.row].note)
                
                
                return cell
            }
            
        } else {
            
            switch indexPath.row {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubDateCell", for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                
                cell.title.text = paymentInputFields[indexPath.row]
                cell.dateTextField.addTarget(self, action: #selector(onPaymentDateChanged), for: .editingDidEnd)
                
                return cell
                
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubPriceCell", for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                cell.title.text = paymentInputFields[indexPath.row]
                
                cell.priceTextField.addTarget(self, action: #selector(onAmountChanged), for: .editingDidEnd)
                
                return cell
                
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.titleLbl.text = paymentInputFields[indexPath.row]
                
                cell.nameTextField.placeholder = "輸入備註"
                
                cell.nameTextField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
                
                return cell
                
            default:
                return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    @objc func onPaymentDateChanged(_ sender: UITextField) {
        
        guard let dateString = sender.text else { return }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
        
        dateFormatter.dateFormat = "MMMM dd yyyy"
        
        guard let date = dateFormatter.date(from: dateString) else { return }
        
        billingRequest.paymentDate = date
    }
    
    @objc func onAmountChanged(_ sender: UITextField) {
        
        guard let priceString = sender.text else { return }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let number = formatter.number(from: priceString) {
            let price = number.decimalValue
            billingRequest.paymentAmount = price
        }
    }
    
    @objc func onNoteChanged(_ sender: UITextField) {
        
        guard let note = sender.text else { return }
        
        billingRequest.note = note
    }
}

extension SendBillingRequestViewController {
    
    func createRequest(with billingRequest: inout BillingRequest) {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }

        billingRequest.userUID = userUID
        billingRequest.groupID = group.id
        billingRequest.hostUID = group.hostUID

        BillingRequestManager.shared.create(billingRequest: &billingRequest) { result in

            switch result {

            case .success:

                print("onTapCreateRequest, success")

            case .failure(let error):

                print("CreateRequest.failure: \(error)")
            }
        }
    }
    
    func fetchRequest() {
        
        BillingRequestManager.shared.fetch(uid: group.hostUID, groupID: group.id) { [weak self] result in
            
            switch result {
                
            case .success(let billingRequests):
                
                print("fetchBillingRequests success")
                
                for billingRequest in billingRequests {
                    
                    self?.requestsFetched.append(billingRequest)
                    let senderUID = billingRequest.userUID
                    self?.senderUIDs.append(senderUID)
                    self?.fetchSenderInfo(senderUID: senderUID)
                }
                
            case .failure(let error):
                
                print("fetchBillingRequests.failure: \(error)")
            }
        }
    }
    
    func fetchSenderInfo(senderUID: String) {
        
        UserManager.shared.searchUser(uid: senderUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchSenderInfo success")
                
                for user in users {
                    self?.sendersInfo.append(user)
                }
                
            case .failure(let error):
                
                print("fetchSenderInfo.failure: \(error)")
            }
        }
    }
    
    func createHistory(with billingHistory: inout BillingHistory) {
        
        billingHistory.userUID = userUID ?? ""
        billingHistory.groupID = group.id
        billingHistory.hostUID = group.hostUID
        
        BillingHistoryManager.shared.create(billingHistory: &billingHistory) { result in
            
            switch result {
                
            case .success:
                
                print("CreateHistory success")
                
            case .failure(let error):
                
                print("CreateHistory.failure: \(error)")
            }
        }
    }
}

extension SendBillingRequestViewController {
    
    func registerCell() {
        
        let amountNib = UINib(nibName: "AddSubPriceCell", bundle: nil)
        tableView.register(amountNib, forCellReuseIdentifier: "AddSubPriceCell")
        
        let dateNib = UINib(nibName: "AddSubDateCell", bundle: nil)
        tableView.register(dateNib, forCellReuseIdentifier: "AddSubDateCell")
        
        let noteNib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(noteNib, forCellReuseIdentifier: "AddSubTextCell")
        
        let requestNib = UINib(nibName: "PaymentInfoTableViewCell", bundle: nil)
        tableView.register(requestNib, forCellReuseIdentifier: "PaymentInfoTableViewCell")
    }
}
