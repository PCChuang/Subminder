//
//  AddToSubViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

// swiftlint:disable file_length

import UIKit

class AddToSubViewController: SUBaseViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.dataSource = self

            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var publishBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func onTapPublish(_ sender: UIButton) {

        self.subscription.groupID = self.group.id
        self.subscription.groupMemberCount = self.group.userUIDs.count + 1
        
        switch group.id {
        case "":
            
            // validate name textfield
            if subscription.name == "" {
                
                let controller = UIAlertController(title: "Oops!", message: "請輸入訂閱名稱", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                controller.addAction(okAction)
                
                present(controller, animated: true, completion: nil)
            } else {
                
                // call currency API when clicking publish
                currenyManager.getConversionRate(currencies: currencies, values: values) {
                    
                    self.calculateRate(index: self.selectedCurrencyIndex)
                    
                    if self.subscriptionsInEdit.count > 0 {
                        
                        self.saveSubscription()
                    } else {
                        
                        self.publishSubscription()
                    }
                    
                    DispatchQueue.main.async {
                        
                        _ = self.navigationController?.popViewController(animated: true)
                        //                    if let controller = self.storyboard?.instantiateViewController(identifier: "Summary") as? SummaryViewController {
                        //                        self.navigationController?.pushViewController(controller, animated: true)
                        //                    }
                    }
                }
            }
            
        default:
            
            if subscription.name == "" {
                
                let controller = UIAlertController(title: "Oops!", message: "請輸入訂閱名稱", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                controller.addAction(okAction)
                
                present(controller, animated: true, completion: nil)
            } else if subscription.cycle == "" {
                
                let controller = UIAlertController(title: "Oops!", message: "請輸入付款週期", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                controller.addAction(okAction)
                
                present(controller, animated: true, completion: nil)
            } else {
                
                // call currency API when clicking publish
                currenyManager.getConversionRate(currencies: currencies, values: values) {
                    
                    self.calculateRate(index: self.selectedCurrencyIndex)
                    
                    if self.subscriptionsInEdit.count > 0 {
                        
                        self.saveSubscription()
                    } else {
                        
                        self.publishInBatch(
                            userUIDs: self.group.userUIDs,
                            hostUID: self.userUID ?? "",
                            with: &self.subscription)
                        
                        self.payable.amount = self.subscription.price
                        self.payable.nextPaymentDate = self.subscription.dueDate
                        self.payable.startDate = self.subscription.startDate
                        self.payable.cycleAmount = self.subscription.price
                        
                        self.group.subscriptionName = self.subscription.name
                        
                        // update subscriptionName in groups
                        GroupManager.shared.updateGroupSubName(groupID: self.group.id, subscriptionName: self.group.subscriptionName) { result in
                            
                            switch result {
                                
                            case .success:
                                
                                print("updateGroup, success")
                                
                            case .failure(let error):
                                
                                print("updateGroup.failure: \(error)")
                            }
                        }
                        
                        for userUID in self.group.userUIDs {
                            
                            self.fectchAndUpdatePayable(userUID: userUID, groupID: self.group.id)
                        }
                        
                        self.fectchAndUpdatePayable(userUID: self.group.hostUID, groupID: self.group.id)
                        
//                        self.createNewPayableInBatch(
//                            totalAmount: self.subscription.groupPriceTotal,
//                            amount: self.payable.amount,
//                            nextPaymentDate: self.payable.nextPaymentDate,
//                            userUIDs: self.group.userUIDs,
//                            hostUID: self.userUID ?? "",
//                            startDate: self.payable.startDate,
//                            cycleAmount: self.payable.cycleAmount,
//                            with: &self.payable)
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }

        if reminderDayComp != nil {
            
            setReminder()
        }

    }

    @IBAction func onTapGoBack(_ sender: UIButton) {

        showDiscardAlert()
    }
    
    let userUID = KeyChainManager.shared.userUID

    var currenyManager = CurrencyManager()

    var subColor: UIColor?

    var subColorOld: UIColor?

    var colorIsSelected: Bool?

    var category: String? {

        didSet {

            tableView.reloadData()
        }
    }

    var reminderDayComp: DateComponents?

    var currencies: [String] = []

    var values: [Double] = []

    var selectedCurrencyIndex: Int = 0

    var currencyValue: Double = 0

    var exchangePrice: Double = 0

    var subscription: Subscription = Subscription(

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
    
    var group: Group = Group(
        
        id: "",
        name: "",
        image: "",
        hostUID: "",
        userUIDs: [],
        subscriptionName: ""
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

    var groupSubscriptionName: String?
    
    var groupTotalAmount: Decimal = 0

    let reminderManager = LocalNotificationManager()

    var subscriptionsInEdit: [Subscription] = []
    
    var groupSubSettings: [String] = [
        
        "名稱",
        "群組",
        "總金額",
        "幣別",
        "平攤金額",
        "第一次付款日",
        "約定付款週期",
        "訂閱週期",
        "付款提醒",
        "顏色",
        "備註"
    ]
    
    var payables: [Payable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
 
        currenyManager.delegate = self

        setupBarItems()
        
        setupButtons()

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    func setupButtons() {
        
        publishBtn.layer.cornerRadius = 10
        
        publishBtn.titleLabel?.font = UIFont(name: "PingFang TC Medium", size: 16)
        
        deleteBtn.layer.cornerRadius = 10
        
        deleteBtn.titleLabel?.font = UIFont(name: "PingFang TC Medium", size: 16)
    }

    func setupBarItems() {

        self.navigationItem.title = "新增訂閱項目"
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
    }

    func publish(with subscription: inout Subscription) {

        guard let userUID = KeyChainManager.shared.userUID else { return }

        subscription.userUID = userUID

        SubsManager.shared.publishSub(subscription: &subscription) { result in

            switch result {

            case .success:

                print("onTapPublish, success")

            case .failure(let error):

                print("publishSub.failure: \(error)")
            }
        }
    }
    
    func publishInBatch(userUIDs: [String], hostUID: String, with subscription: inout Subscription) {
        
        subscription.groupID = group.id
        
        SubsManager.shared.publishInBatch(userUIDs: userUIDs, hostUID: hostUID, subscription: &subscription) { result in

            switch result {

            case .success:

                print("onTapPublish, success")

            case .failure(let error):

                print("publishSub.failure: \(error)")
            }
        }
    }
    
    // fetch and update user's payable
    func fectchAndUpdatePayable(userUID: String, groupID: String) {
        
        PayableManager.shared.fetch(uid: userUID, groupID: groupID) { [weak self] result in
            
            switch result {
                
            case .success(let payables):
                
                print("fetchPayable success")
                
                for payable in payables {
                    
                    self?.payables.append(payable)
                    
                    if userUID == self?.group.hostUID {
                        
                        PayableManager.shared.update(
                            payableID: payable.id,
                            groupID: payable.groupID,
                            userUID: userUID,
                            nextPaymentDate: self?.subscription.dueDate ?? Date(),
                            startDate: self?.subscription.startDate ?? Date(),
                            cycleAmount: self?.subscription.groupPriceTotal ?? 0,
                            amount: -(self?.subscription.groupPriceTotal ?? 0) + (self?.subscription.price ?? 0)) { result in
                                
                                switch result {
                                    
                                case .success:
                                    
                                    print("updatePayable, success")
                                    
                                case .failure(let error):
                                    
                                    print("updatePayable.failure: \(error)")
                                }
                            }
                    } else {
                        
                        PayableManager.shared.update(
                            payableID: payable.id,
                            groupID: payable.groupID,
                            userUID: userUID,
                            nextPaymentDate: self?.subscription.dueDate ?? Date(),
                            startDate: self?.subscription.startDate ?? Date(),
                            cycleAmount: self?.subscription.price ?? 0,
                            amount: self?.subscription.price ?? 0) { result in
                                
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

//    func createNewPayableInBatch(
//        totalAmount: Decimal,
//        amount: Decimal,
//        nextPaymentDate: Date,
//        userUIDs: [String],
//        hostUID: String,
//        startDate: Date,
//        cycleAmount: Decimal,
//        with payable: inout Payable
//    ) {
//        payable.groupID = group.id
//
//        PayableManager.shared.createPayableInBatch(
//            totalAmount: totalAmount,
//            amount: amount,
//            nextPaymentDate: nextPaymentDate,
//            userUIDs: userUIDs,
//            hostUID: hostUID,
//            startDate: startDate,
//            cycleAmount: cycleAmount,
//            payable: &payable
//        ) { result in
//
//            switch result {
//
//            case .success:
//
//                print("createNewPayable, success")
//
//            case .failure(let error):
//
//                print("createNewPayable.failure: \(error)")
//            }
//        }
//    }

    func save(with subscription: inout Subscription) {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }

        subscription.userUID = userUID

        SubsManager.shared.saveEditedSub(subscription: &subscription, subscriptionID: subscription.id) { result in

            switch result {

            case .success:

                print("onTapSave, success")

            case .failure(let error):

                print("saveSub.failure: \(error)")
            }
        }
    }

    func delete() {

        SubsManager.shared.deleteSub(subscription: subscription) { result in
            
            switch result {

            case .success:

                print("onTapDelete, success")

            case .failure(let error):

                print("deleteSub.failure: \(error)")
            }
        }
    }
}

extension AddToSubViewController: UITableViewDataSource, UITableViewDelegate, UIColorPickerViewControllerDelegate, DateComponentDelegate, ReminderDelegate, CurrencyCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if group.id != "" {
            
            return groupSubSettings.count
        } else {
            
            return subSettings.count
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // editing subscription
        if subscriptionsInEdit.count > 0 && group.id == "" {

            switch indexPath.row {

            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.titleLbl.text = subSettings[indexPath.row]
                cell.nameTextField.text = subscriptionsInEdit.first?.name
                subscription.name = cell.nameTextField.text ?? ""
                cell.nameTextField.addTarget(self, action: #selector(onNameChanged), for: .editingDidEnd)
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubPriceCell", for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                
                let subPrice = subscriptionsInEdit.first?.price
                cell.priceTextField.text = "$\(subPrice ?? 0.00)"
                
                subscription.price = subPrice ?? 0
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCurrencyCell", for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }

                cell.delegate = self

                cell.title.text = subSettings[indexPath.row]
                cell.currencyTextField.text = subscriptionsInEdit.first?.currency
                subscription.currency = cell.currencyTextField.text ?? ""

                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                return cell

            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubDateCell", for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]

                // convert date to String to render in cell
                let date = subscriptionsInEdit.first?.startDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                let dateString = dateFormatter.string(from: date ?? Date())

                cell.dateTextField.text = dateString

                // convert String to date to upload to db
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
                let dateToUpload = dateFormatter.date(from: dateString)
                subscription.startDate = dateToUpload ?? Date()

                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                return cell

            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.cycleTextField.text = subscriptionsInEdit.first?.cycle
                subscription.cycle = cell.cycleTextField.text ?? ""
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)

                cell.delegate = self

                return cell

            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.cycleTextField.text = subscriptionsInEdit.first?.duration
                subscription.duration = cell.cycleTextField.text ?? ""
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                return cell

//            case 6:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCategoryCell", for: indexPath)
//                guard let cell = cell as? AddSubCategoryCell else {
//                    return cell
//                }
//                cell.title.text = subSettings[indexPath.row]
//                cell.category.text = subscriptionsInEdit.first?.category
//
//                cell.category.text = category
//
//                return cell

            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.colorView.isHidden = false
                subColorOld = UIColor.hexStringToUIColor(hex: subscriptionsInEdit.first?.color ?? "")

                // check if color is selected
                var subColorHex: String?

                if colorIsSelected == true {

                    cell.colorView.backgroundColor = subColor
                    subColorHex = subColor?.toHexString()
                    subscription.color = subColorHex ?? ""
                } else {

                    cell.colorView.backgroundColor = subColorOld
                    subColorHex = subColorOld?.toHexString()
                    subscription.color = subColorHex ?? ""
                }
                return cell
                
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubReminderCell", for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.reminderTextField.text = subscriptionsInEdit.first?.reminder
                subscription.reminder = cell.reminderTextField.text ?? ""
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                cell.delegate = self

                return cell

            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.titleLbl.text = subSettings[indexPath.row]
                cell.nameTextField.text = subscriptionsInEdit.first?.note
                subscription.note = cell.nameTextField.text ?? ""
                cell.nameTextField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
                return cell

            default:
                return UITableViewCell()
            }
        } else if group.id != "" {
            
            switch indexPath.row {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.nameTextField.text = subscriptionsInEdit.first?.name
                }
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(string: "請輸入訂閱項目名稱",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                subscription.name = cell.nameTextField.text ?? ""
                
                cell.nameTextField.addTarget(self, action: #selector(onNameChanged), for: .editingDidEnd)
                
                return cell
                
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.nameTextField.isEnabled = false
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.setupCell(title: groupSubSettings[indexPath.row], textField: subscriptionsInEdit.first?.groupName ?? "")
                } else {
                    
                    cell.setupCell(title: groupSubSettings[indexPath.row], textField: group.name)
                }
                
                subscription.groupName = cell.nameTextField.text ?? ""
                
                return cell
                
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubPriceCell", for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.priceTextField.isEnabled = false
                    
                    let groupPrice = subscriptionsInEdit.first?.groupPriceTotal ?? 0
                    cell.priceTextField.text = "$\(groupPrice)"
                    
                    subscription.groupPriceTotal = groupPrice
                }
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)

                return cell
                
            case 3:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCurrencyCell", for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }

                cell.delegate = self

                cell.title.text = groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.currencyTextField.text = subscriptionsInEdit.first?.currency
//                    
//                    cell.currencyTextField.isEnabled = false
                }
                
                subscription.currency = cell.currencyTextField.text ?? ""

                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                
                return cell
                
            case 4:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                    
                cell.nameTextField.isEnabled = false
                
                let totalAmount = groupTotalAmount
                let numberOfMember = Decimal(group.userUIDs.count + 1)
                
                let priceSplited = totalAmount / numberOfMember
                
                if subscriptionsInEdit.count > 0 {

//                    let memberCount = Decimal(subscriptionsInEdit.first?.groupMemberCount ?? 0)
//                    let groupTotal = subscriptionsInEdit.first?.groupPriceTotal ?? 0
                    cell.titleLbl.text = groupSubSettings[indexPath.row]
                    cell.nameTextField.text = "\(subscriptionsInEdit.first?.price ?? 0)"
//                    subscription.price = groupTotal / memberCount
                    subscription.price = subscriptionsInEdit.first?.price ?? 0
                } else {
                    
                    cell.setupCell(title: groupSubSettings[indexPath.row], textField: "\(priceSplited)")
                    
                    subscription.price = priceSplited
                }
                
                return cell
                
            case 5:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubDateCell", for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.dateTextField.isEnabled = false
                    
                    // convert date to String to render in cell
                    let date = subscriptionsInEdit.first?.startDate
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM dd yyyy"
                    let dateString = dateFormatter.string(from: date ?? Date())
                    
                    cell.dateTextField.text = dateString
                    
                    // convert String to date to upload to db
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
                    let dateToUpload = dateFormatter.date(from: dateString)
                    subscription.startDate = dateToUpload ?? Date()
                }
                
                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                
                return cell
                
            case 6:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                cell.delegate = self
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.cycleTextField.isEnabled = false
                    
                    cell.cycleTextField.text = subscriptionsInEdit.first?.cycle
                    
                    subscription.cycle = cell.cycleTextField.text ?? ""
                }
                
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)
                
                return cell
                
            case 7:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.cycleTextField.isEnabled = false
                    
                    cell.cycleTextField.text = subscriptionsInEdit.first?.duration
                    
                    subscription.duration = cell.cycleTextField.text ?? ""
                }
                
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                
                return cell
                
            case 8:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubReminderCell", for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                
                cell.delegate = self
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                
                return cell
                
            case 9:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                
                cell.title.text = groupSubSettings[indexPath.row]
                
                cell.colorView.isHidden = false
                
                if subscriptionsInEdit.count > 0 {
                    
                    subColorOld = UIColor.hexStringToUIColor(hex: subscriptionsInEdit.first?.color ?? "")

                    // check if color is selected
                    var subColorHex: String?

                    if colorIsSelected == true {

                        cell.colorView.backgroundColor = subColor
                        subColorHex = subColor?.toHexString()
                        subscription.color = subColorHex ?? ""
                    } else {

                        cell.colorView.backgroundColor = subColorOld
                        subColorHex = subColorOld?.toHexString()
                        subscription.color = subColorHex ?? ""
                    }
                } else {
                    
                    cell.colorView.backgroundColor = subColor
                    
                    let subColorHex = subColor?.toHexString()
                    subscription.color = subColorHex ?? ""
                }
                
                return cell
                
            case 10:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = groupSubSettings[indexPath.row]
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(string: "請輸入備註",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.nameTextField.text = subscriptionsInEdit.first?.note
//                    subscription.note = cell.nameTextField.text ?? ""
                }
                
                cell.nameTextField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
                
                return cell
                
            default:
                return UITableViewCell()
            }
        } else {
            
            switch indexPath.row {
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.titleLbl.text = subSettings[indexPath.row]
                cell.nameTextField.attributedPlaceholder = NSAttributedString(string: "請輸入訂閱項目名稱",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                cell.nameTextField.addTarget(self, action: #selector(onNameChanged), for: .editingDidEnd)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubPriceCell", for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCurrencyCell", for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }
                
                cell.delegate = self
                
                cell.title.text = subSettings[indexPath.row]
                
                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubDateCell", for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)
                
                cell.delegate = self
                
                return cell
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                return cell
                
//            case 6:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCategoryCell", for: indexPath)
//                guard let cell = cell as? AddSubCategoryCell else {
//                    return cell
//                }
//                cell.title.text = subSettings[indexPath.row]
//
//                cell.category.text = category
//
//                return cell
                
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.colorView.isHidden = false
                cell.colorView.backgroundColor = subColor
                
                let subColorHex = subColor?.toHexString()
                subscription.color = subColorHex ?? ""
                return cell
                
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubReminderCell", for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                cell.delegate = self
                
                return cell
                
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.titleLbl.text = subSettings[indexPath.row]
                cell.nameTextField.attributedPlaceholder = NSAttributedString(string: "請輸入備註",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                cell.nameTextField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
                return cell
                
            default:
                return UITableViewCell()
            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if group.id != "" {
            
            switch indexPath.row {
                
            case 9:
                
                let colorPicker = UIColorPickerViewController()
                
                colorPicker.delegate = self
                
                present(colorPicker, animated: true)
                
            default:
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            
            switch indexPath.row {
                
//            case 6:
//                if let controller = storyboard?.instantiateViewController(identifier: "Category") as? CategoryViewController {
//                    self.navigationController?.pushViewController(controller, animated: true)
//                    controller.delegate = self
//                }
                
            case 6:
                
                let colorPicker = UIColorPickerViewController()
                
                colorPicker.delegate = self
                
                present(colorPicker, animated: true)
                
            default:
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {

        let color = viewController.selectedColor
        subColor = color
        colorIsSelected = true
        tableView.reloadData()
    }

    @objc func onNameChanged(_ sender: UITextField) {
        subscription.name = sender.text ?? ""
    }

    @objc func onPriceChanged(_ sender: UITextField) {
        guard let priceString = sender.text else {
            return
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let number = formatter.number(from: priceString) {
            let price = number.decimalValue
            subscription.price = price
            groupTotalAmount = price
            
            if group.id != "" {
                subscription.groupPriceTotal = price
            }
        }
        
        if group.id != "" {
            
            tableView.reloadData()
        }
    }

    @objc func onCurrencyChanged(_ sender: UITextField) {
        subscription.currency = sender.text ?? ""
    }

    @objc func onStartDateChanged(_ sender: UITextField) {
        guard let dateString = sender.text else {
            return
        }

        let dateFormatter = DateFormatter()

        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")

        dateFormatter.dateFormat = "MMMM dd yyyy"

        let date = dateFormatter.date(from: dateString)

        subscription.startDate = date ?? Date()
    }

    @objc func onCycleChanged(_ sender: UITextField, _ cell: AddSubCycleCell) {
        subscription.cycle = sender.text ?? ""
    }

    @objc func onDurationChanged(_ sender: UITextField) {
        subscription.duration = sender.text ?? ""
    }

    @objc func onNoteChanged(_ sender: UITextField) {
        subscription.note = sender.text ?? ""
    }

    @objc func onReminderChanged(_ sender: UITextField) {
        subscription.reminder = sender.text ?? ""
    }

    func dateComponentDidChange(_ dateComponent: DateComponents, _ cell: AddSubCycleCell) {
        let dueDate = Calendar.current.date(byAdding: cell.dateComponent, to: subscription.startDate)
        subscription.dueDate = dueDate ?? Date()
    }

    // set up reminder
    func reminderDidSet(_ dateComponent: DateComponents, _ cell: AddSubReminderCell) {
        let day = dateComponent.day
        let dateComp = DateComponents(day: -(day ?? 0))
        guard let reminderDay = Calendar.current.date(byAdding: dateComp, to: subscription.dueDate) else { return }
        
        if day == nil {
            
            reminderDayComp = nil
        } else {
            
            reminderDayComp = Calendar.current.dateComponents([.day, .month, .year], from: reminderDay as Date)
        }
        
        print("reminder === \(day)")
        print("reminderDayComp === \(reminderDayComp)")
    }

    func setReminder() {

        reminderManager.notifications = [Notification(id: "reminder - \(userUID ?? ""), \(subscription.name)",
                                                      title: "\(subscription.name) 付款時間到囉!",
                                                      dateTime: DateComponents(calendar: Calendar.current,
                                                                               year: reminderDayComp?.year,
                                                                               month: reminderDayComp?.month,
                                                                               day: reminderDayComp?.day,
                                                                               hour: 14,
                                                                               minute: 37))]
        
        reminderManager.schedule()
    }

    func publishSubscription() {

        self.publish(with: &subscription)
    }

    func saveSubscription() {
        
        self.save(with: &subscription)
    }

    func deleteSubscription(completion: @escaping () -> Void) {

        self.delete()
        completion()
    }

    func showDiscardAlert() {

        DispatchQueue.main.async {

            let alertController = UIAlertController(title: "刪除項目", message: "即將刪除項目，確認要刪除嗎?", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確認", style: .default) { _ in

                if self.subscriptionsInEdit.count > 0 {

                    self.deleteSubscription {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {

                    _ = self.navigationController?.popViewController(animated: true)
                }
            }

            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

            alertController.addAction(okAction)

            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func currencyRateDidChange(_ cell: AddSubCurrencyCell, _ index: Int) {

        selectedCurrencyIndex = index
    }

    func calculateRate(index: Int) {

        currencyValue = values[index]

        exchangePrice = (subscription.price).doubleValue / currencyValue
        
        print(currencyValue, exchangePrice)

        subscription.exchangePrice = exchangePrice.rounded(toPlaces: 2)
    }
}

extension AddToSubViewController {
    
    func registerCell() {
        
        let nib = UINib(nibName: "AddSubCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubCell")

        let textNib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "AddSubTextCell")

        let priceNib = UINib(nibName: "AddSubPriceCell", bundle: nil)
        tableView.register(priceNib, forCellReuseIdentifier: "AddSubPriceCell")
        
        let pickerNib = UINib(nibName: "AddSubCycleCell", bundle: nil)
        tableView.register(pickerNib, forCellReuseIdentifier: "AddSubCycleCell")

        let dateNib = UINib(nibName: "AddSubDateCell", bundle: nil)
        tableView.register(dateNib, forCellReuseIdentifier: "AddSubDateCell")

        let currencyNib = UINib(nibName: "AddSubCurrencyCell", bundle: nil)
        tableView.register(currencyNib, forCellReuseIdentifier: "AddSubCurrencyCell")

        let categoryNib = UINib(nibName: "AddSubCategoryCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "AddSubCategoryCell")

        let reminderNib = UINib(nibName: "AddSubReminderCell", bundle: nil)
        tableView.register(reminderNib, forCellReuseIdentifier: "AddSubReminderCell")
    }
}

// Get data for category page
extension AddToSubViewController: CategoryDelegate {

    func didSelectCategory(_ contentOfText: String) {

        category = contentOfText

        subscription.category = category ?? ""
    }
}

extension AddToSubViewController: CurrencyManagerDelegate {

    func manager(_ manager: CurrencyManager, didGet currencies: [String]) {

        self.currencies = currencies
    }

    func manager(_ manager: CurrencyManager, didGet values: [Double]) {

        self.values = values
    }
}
