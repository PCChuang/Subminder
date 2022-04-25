//
//  AddToSubViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

// swiftlint:disable file_length

import UIKit

class AddToSubViewController: SUBaseViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var publishBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    let userUID = KeyChainManager.shared.userUID

    var currenyManager = CurrencyManager()
    
    var dateManager = DateManager()

    var subColor: UIColor?

    var subColorOld: UIColor?

    var colorIsSelected: Bool = false

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

    let reminderManager = LocalNotificationManager()

    var subscriptionsInEdit: [Subscription] = []
    
    var subscriptionProvider: SubscriptionProvider! {
        
        didSet {
            
            guard subscriptionProvider != nil else {
                
                tableView.dataSource = nil
                
                tableView.delegate = nil
                
                return
            }
            
            setupTableView()
        }
    }
    
    var payables: [Payable] = []
    
    var totalPriceAmount: Decimal = 0
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
 
        currenyManager.delegate = self

        setupBarItems()
        
        setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    // MARK: - Private Implementation
    
    @IBAction func onTapPublish(_ sender: UIButton) {

        self.subscription.groupID = self.group.id
        self.subscription.groupMemberCount = self.group.userUIDs.count + 1
        
        if group.id == "" {
            
            // validate name textfield
            if subscription.name == "" {
                
                showAlert(message: "請輸入訂閱項目名稱")
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
                    }
                }
            }
        } else {

                if subscription.name == "" {
                    
                    showAlert(message: "請輸入訂閱項目名稱")
                } else if subscription.cycle == "" {
                    
                    showAlert(message: "請輸入付款週期")
                } else {
                    
                    currenyManager.getConversionRate(currencies: currencies, values: values) {
                        
                        self.calculateRate(index: self.selectedCurrencyIndex)
                        
                        if self.subscriptionsInEdit.count > 0 {
                            
                            self.saveSubscription()
                        } else {
                            
                            self.subscriptionProvider.publishInBatch(userUIDs: self.group.userUIDs,
                                                                     hostUID: self.userUID ?? "",
                                                                     with: &self.subscription)
                            
                            self.setupPayable()
                            
                            self.group.subscriptionName = self.subscription.name
                            
                            self.updateGroupSubscriptionName()
                            
                            for userUID in self.group.userUIDs {
                                
                                self.fectchAndUpdatePayable(userUID: userUID, groupID: self.group.id)
                            }
                            
                            self.fectchAndUpdatePayable(userUID: self.group.hostUID, groupID: self.group.id)
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
    
    func setupButtons() {
        
        publishBtn.layer.cornerRadius = 10
        
        deleteBtn.layer.cornerRadius = 10
        
        let font = "PingFang TC Medium"
        
        let aTextPublish = NSAttributedString(string: "保存",
                                              attributes: [NSAttributedString.Key.font: UIFont(name: font,
                                                                                               size: 16) as Any])
        
        publishBtn.setAttributedTitle(aTextPublish, for: .normal)
        
        let aTextDelete = NSAttributedString(string: "刪除",
                                             attributes: [NSAttributedString.Key.font: UIFont(name: font,
                                                                                              size: 16) as Any])
        
        deleteBtn.setAttributedTitle(aTextDelete, for: .normal)
    }

    func setupBarItems() {

        self.navigationItem.title = "新增訂閱項目"
    }
    
    private func showAlert(message: String) {
        
        let alert = AlertManager.simpleConfirmAlert(in: self, title: "Oops", message: message, confirmTitle: "OK")
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupPayable() {
        
        payable.amount = subscription.price
        payable.nextPaymentDate = subscription.dueDate
        payable.startDate = subscription.startDate
        payable.cycleAmount = subscription.price
    }
    
    func updateGroupSubscriptionName() {
        
        GroupManager.shared.updateGroupSubName(groupID: self.group.id,
                                               subscriptionName: self.group.subscriptionName) { result in
            
            switch result {
                
            case .success:
                
                print("updateGroup, success")
                
            case .failure(let error):
                
                print("updateGroup.failure: \(error)")
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
                
            case .failure(let error):
                
                print("fetchPayable.failure: \(error)")
            }
        }
    }
    
    func publishSubscription() {

        subscriptionProvider.publish(with: &subscription)
    }

    func saveSubscription() {
        
        subscriptionProvider.save(with: &subscription)
    }

    func deleteSubscription(completion: @escaping () -> Void) {

        subscriptionProvider.delete()
        completion()
    }

    func showDiscardAlert() {

        DispatchQueue.main.async {
            
            let alert = AlertManager.submitConfirmAlert(in: self,
                                                        title: "刪除項目",
                                                        message: "即將刪除項目，確認要刪除嗎?",
                                                        confirmTitle: "確認",
                                                        confirmHandler: {
                
                if self.subscriptionsInEdit.count > 0 {
                    
                    self.deleteSubscription {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
            },
                                                        cancelTitle: "取消")
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    func calculateRate(index: Int) {

        currencyValue = values[index]

        exchangePrice = (subscription.price).doubleValue / currencyValue
        
        print(currencyValue, exchangePrice)

        subscription.exchangePrice = exchangePrice.rounded(toPlaces: 2)
    }
}

// MARK: - UITableViewDataSource

extension AddToSubViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if group.id != "" {
            
            return subscriptionProvider.groupSubSettings.count
        } else {
            
            return subscriptionProvider.subSettings.count
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // individual - editing subscription
        if subscriptionsInEdit.count > 0 && group.id == "" {
            
            guard let subscriptionInEdit = subscriptionsInEdit.first else { return UITableViewCell() }
            
            switch subscriptionProvider.subscriptionConstructor[indexPath.row] {

            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.name)

                subscription.name = cell.nameTextField.text ?? ""
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell

            case .price:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubPriceCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                
                let subPrice = subscriptionInEdit.price
                
                let subPriceString = "$\(subPrice)"
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subPriceString)
                
                subscription.price = subPrice
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)
                
                return cell

            case .currency:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCurrencyCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }

                cell.delegate = self

                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.currency)
                
                subscription.currency = cell.currencyTextField.text ?? ""

                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                
                return cell

            case .firstPaymentDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubDateCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }

                // convert date to String to render in cell
                let dateString = dateManager.convertDateToString(date: subscriptionInEdit.startDate)
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: dateString)

                // convert String to date to upload to db
                subscription.startDate = dateManager.convertStringToDate(dateString: dateString)

                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                
                return cell

            case .cycle:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.cycle)
                
                subscription.cycle = cell.cycleTextField.text ?? ""
                
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)

                cell.delegate = self

                return cell

            case .duration:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.duration)
                
                subscription.duration = cell.cycleTextField.text ?? ""
                
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                
                return cell

            case .color:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                cell.colorView.isHidden = false
                subColorOld = UIColor.hexStringToUIColor(hex: subscriptionInEdit.color)

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
                
            case .reminder:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubReminderCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.reminder)
                
                subscription.reminder = cell.reminderTextField.text ?? ""
                
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                
                cell.delegate = self

                return cell

            case .note:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.setupCell(title: subscriptionProvider.subSettings[indexPath.row],
                               textField: subscriptionInEdit.note)
                
                subscription.note = cell.nameTextField.text ?? ""
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell
            }
            
            // create and edit group subscriptions
        } else if group.id != "" {
            
            let subscriptionInEdit = subscriptionsInEdit.first
            
            switch subscriptionProvider.groupSubscriptionConstructor[indexPath.row] {
                
            case .name:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.nameTextField.text = subscriptionInEdit?.name
                    subscription.name = cell.nameTextField.text ?? ""
                }
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(
                    string: "請輸入訂閱項目名稱",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell
                
            case .groupName:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.nameTextField.isEnabled = false
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.setupCell(title: subscriptionProvider.groupSubSettings[indexPath.row],
                                   textField: subscriptionInEdit?.groupName ?? "")
                } else {
                    
                    cell.setupCell(title: subscriptionProvider.groupSubSettings[indexPath.row],
                                   textField: group.name)
                }
                
                subscription.groupName = cell.nameTextField.text ?? ""
                
                return cell
                
            case .price:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubPriceCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.priceTextField.isEnabled = false
                    
                    let groupPrice = subscriptionInEdit?.groupPriceTotal
                    
                    cell.priceTextField.text = "$\(groupPrice ?? 0)"
                    
                    subscription.groupPriceTotal = groupPrice ?? 0
                }
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)

                return cell
                
            case .currency:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCurrencyCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }

                cell.delegate = self

                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.currencyTextField.text = subscriptionInEdit?.currency
                    cell.currencyTextField.isEnabled = false
                }
                
                subscription.currency = cell.currencyTextField.text ?? ""

                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                
                return cell
                
            case .sharedAmount:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                    
                cell.nameTextField.isEnabled = false
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                // calculate shared cost per member
                let totalAmount = self.totalPriceAmount
                
                let numberOfMember = Decimal(group.userUIDs.count + 1)
                
                let priceSplited = totalAmount / numberOfMember
                
                // render shared cost
                if subscriptionsInEdit.count > 0 {

                    cell.nameTextField.text = "\(subscriptionInEdit?.price ?? 0)"
                    subscription.price = subscriptionInEdit?.price ?? 0
                } else {
                    
                    cell.nameTextField.text = "\(priceSplited)"
                    subscription.price = priceSplited
                }
                
                return cell
                
            case .firstPaymentDate:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubDateCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.dateTextField.isEnabled = false
                    
                    let dateString = dateManager.convertDateToString(date: subscriptionInEdit?.startDate ?? Date())
                    
                    cell.dateTextField.text = dateString
                    
                    subscription.startDate = dateManager.convertStringToDate(dateString: dateString)
                }
                
                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                
                return cell
                
            case .cycle:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                cell.delegate = self
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.cycleTextField.isEnabled = false
                    
                    cell.cycleTextField.text = subscriptionInEdit?.cycle
                    
                    subscription.cycle = cell.cycleTextField.text ?? ""
                }
                
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)
                
                return cell
                
            case .duration:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.cycleTextField.isEnabled = false
                    
                    cell.cycleTextField.text = subscriptionInEdit?.duration
                    
                    subscription.duration = cell.cycleTextField.text ?? ""
                }
                
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                
                return cell
                
            case .reminder:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubReminderCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                
                cell.delegate = self
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                
                return cell
                
            case .color:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                cell.colorView.isHidden = false
                
                if subscriptionsInEdit.count > 0 {
                    
                    subColorOld = UIColor.hexStringToUIColor(hex: subscriptionInEdit?.color ?? "")

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
                
            case .note:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.groupSubSettings[indexPath.row]
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(
                    string: "請輸入備註",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                if subscriptionsInEdit.count > 0 {
                    
                    cell.nameTextField.text = subscriptionInEdit?.note
                    subscription.note = cell.nameTextField.text ?? ""
                }
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell
            }
            
            // individual - create new subscription
        } else {
            
            switch subscriptionProvider.subscriptionConstructor[indexPath.row] {
                
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(
                    string: "請輸入訂閱項目名稱",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell
                
            case .price:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubPriceCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubPriceCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.priceTextField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)
                
                return cell
                
            case .currency:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCurrencyCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCurrencyCell else {
                    return cell
                }
                
                cell.delegate = self
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.currencyTextField.addTarget(self, action: #selector(onCurrencyChanged), for: .editingDidEnd)
                
                return cell
                
            case .firstPaymentDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubDateCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubDateCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.dateTextField.addTarget(self, action: #selector(onStartDateChanged), for: .editingDidEnd)
                
                return cell
                
            case .cycle:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.cycleTextField.addTarget(self, action: #selector(onCycleChanged), for: .editingDidEnd)
                
                cell.delegate = self
                
                return cell
                
            case .duration:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCycleCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCycleCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.cycleTextField.addTarget(self, action: #selector(onDurationChanged), for: .editingDidEnd)
                
                return cell
                
            case .color:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.colorView.isHidden = false
                cell.colorView.backgroundColor = subColor
                
                let subColorHex = subColor?.toHexString()
                subscription.color = subColorHex ?? ""
                
                return cell
                
            case .reminder:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubReminderCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                
                cell.delegate = self
                
                return cell
                
            case .note:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddSubTextCell.identifier, for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                
                cell.titleLbl.text = subscriptionProvider.subSettings[indexPath.row]
                
                cell.nameTextField.attributedPlaceholder = NSAttributedString(
                    string: "請輸入備註",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
                cell.nameTextField.tag = indexPath.row
                
                cell.nameTextField.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
                
                return cell
            }
        }
    }
    
    // MARK: - UITextField Implementation

    @objc func onTextChanged(_ sender: UITextField) {
        
        switch sender.tag {
            
        case 0:
            
            let name = sender.text
            
            guard let name = name else { return }
            
            subscription.name = name
            
        default:
            
            let note = sender.text
            
            guard let note = note else { return }
            
            subscription.note = note
        }
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
            
            if group.id != "" {
                subscription.groupPriceTotal = price
                self.totalPriceAmount = price
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

    @objc func onReminderChanged(_ sender: UITextField) {
        subscription.reminder = sender.text ?? ""
    }
}

// MARK: - UITableViewDelegate

extension AddToSubViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if group.id != "" {
            
            switch indexPath.row {
                
            case 9:
                
                presentColorPicker()
                
            default:
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            
            switch indexPath.row {
                
            case 7:
                
                presentColorPicker()
                
            default:
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

// MARK: - Reminder Delegate

extension AddToSubViewController: ReminderDelegate {
    
    func reminderDidSet(_ dateComponent: DateComponents, _ cell: AddSubReminderCell) {
        let day = dateComponent.day
        let dateComp = DateComponents(day: -(day ?? 0))
        guard let reminderDay = Calendar.current.date(byAdding: dateComp, to: subscription.dueDate) else { return }
        
        if day == nil {
            
            reminderDayComp = nil
        } else {
            
            reminderDayComp = Calendar.current.dateComponents([.day, .month, .year], from: reminderDay as Date)
        }
    }

    func setReminder() {

        reminderManager.notifications = [Notification(id: "reminder - \(userUID ?? ""), \(subscription.name)",
                                                      title: "\(subscription.name) 付款時間到囉!",
                                                      dateTime: DateComponents(calendar: Calendar.current,
                                                                               year: reminderDayComp?.year,
                                                                               month: reminderDayComp?.month,
                                                                               day: reminderDayComp?.day,
                                                                               hour: 12,
                                                                               minute: 00))]
        
        reminderManager.schedule()
    }
}

// MARK: - DateCompnent Delegate

extension AddToSubViewController: DateComponentDelegate {
    
    func dateComponentDidChange(_ dateComponent: DateComponents, _ cell: AddSubCycleCell) {
        let dueDate = Calendar.current.date(byAdding: cell.dateComponent, to: subscription.startDate)
        subscription.dueDate = dueDate ?? Date()
    }
}

// MARK: - Currency Cell Delegate

extension AddToSubViewController: CurrencyCellDelegate {
    
    func currencyRateDidChange(_ cell: AddSubCurrencyCell, _ index: Int) {

        selectedCurrencyIndex = index
    }
}

// MARK: - UIColorPickerViewControllerDelegate

extension AddToSubViewController: UIColorPickerViewControllerDelegate {
    
    func presentColorPicker() {
        
        let colorPicker = UIColorPickerViewController()
        
        colorPicker.delegate = self
        
        present(colorPicker, animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {

        let color = viewController.selectedColor
        subColor = color
        colorIsSelected = true
        tableView.reloadData()
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

extension AddToSubViewController {
    
    func setupTableView() {
        
        guard subscriptionProvider != nil else { return }
        
        loadViewIfNeeded()
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.registerCellWithNib(identifier: AddSubCell.identifier, bundle: nil)
        
        tableView.registerCellWithNib(identifier: AddSubTextCell.identifier, bundle: nil)
        
        tableView.registerCellWithNib(identifier: AddSubPriceCell.identifier, bundle: nil)

        tableView.registerCellWithNib(identifier: AddSubCycleCell.identifier, bundle: nil)
        
        tableView.registerCellWithNib(identifier: AddSubDateCell.identifier, bundle: nil)

        tableView.registerCellWithNib(identifier: AddSubCurrencyCell.identifier, bundle: nil)

        tableView.registerCellWithNib(identifier: AddSubCategoryCell.identifier, bundle: nil)

        tableView.registerCellWithNib(identifier: AddSubReminderCell.identifier, bundle: nil)
    }
}
