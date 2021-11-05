//
//  AddToSubViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class AddToSubViewController: SUBaseViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.dataSource = self

            tableView.delegate = self
        }
    }

    @IBAction func onTapPublish(_ sender: UIButton) {

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

//        self.publish(with: &subscription)

        setReminder()

    }

    @IBAction func onTapGoBack(_ sender: UIButton) {

        showDiscardAlert()
    }

    var currenyManager = CurrencyManager()

    var subColor: UIColor?

    var subColorOld: UIColor?

    var colorIsSelected: Bool?

    var category: String? {

        didSet {

            tableView.reloadData()
        }
    }

    var reminderDayComp = DateComponents()

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
        note: ""
    )

    let reminderManager = LocalNotificationManager()

    var subscriptionsInEdit: [Subscription] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        currenyManager.delegate = self

        setupBarItems()

        print(subscriptionsInEdit)

//        self.onPublished = { [weak self] () in
//            self?.onPublished?()
//            self?.dismiss(animated: true, completion: nil)
//        }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    }

    func setupBarItems() {

        self.navigationItem.title = "新增訂閱項目"
    }

    func publish(with subscription: inout Subscription) {

        guard let userUID = KeyChainManager.shared.userUID else { return }

        subscription.userUID = userUID

        SubsManager.shared.publishSub(subscription: &subscription) { result in

            switch result {

            case .success:

                print("onTapPublish, success")
//                self.onPublished?()

            case .failure(let error):

                print("publishSub.failure: \(error)")
            }
        }
    }

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
        subSettings.count
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // editing subscription
        if subscriptionsInEdit.count > 0 {

            switch indexPath.row {

            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.textField.text = subscriptionsInEdit.first?.name
                subscription.name = cell.textField.text ?? ""
                cell.textField.addTarget(self, action: #selector(onNameChanged), for: .editingDidEnd)
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

            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCategoryCell", for: indexPath)
                guard let cell = cell as? AddSubCategoryCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.category.text = subscriptionsInEdit.first?.category

                cell.category.text = category

                return cell

            case 7:
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
                
            case 8:
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

            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.textField.text = subscriptionsInEdit.first?.note
                subscription.note = cell.textField.text ?? ""
                cell.textField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
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
                cell.title.text = subSettings[indexPath.row]
                cell.textField.placeholder = "輸入名稱"
                cell.textField.addTarget(self, action: #selector(onNameChanged), for: .editingDidEnd)
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
                
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCategoryCell", for: indexPath)
                guard let cell = cell as? AddSubCategoryCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                
                cell.category.text = category
                
                return cell
                
            case 7:
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
                
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubReminderCell", for: indexPath)
                guard let cell = cell as? AddSubReminderCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.reminderTextField.addTarget(self, action: #selector(onReminderChanged), for: .editingDidEnd)
                cell.delegate = self
                
                return cell
                
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
                guard let cell = cell as? AddSubTextCell else {
                    return cell
                }
                cell.title.text = subSettings[indexPath.row]
                cell.textField.placeholder = "輸入備註"
                cell.textField.addTarget(self, action: #selector(onNoteChanged), for: .editingDidEnd)
                return cell
                
            default:
                return UITableViewCell()
            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {

        case 6:
            if let controller = storyboard?.instantiateViewController(identifier: "Category") as? CategoryViewController {
                self.navigationController?.pushViewController(controller, animated: true)
                controller.delegate = self
            }

        case 7:

            let colorPicker = UIColorPickerViewController()

            colorPicker.delegate = self

            present(colorPicker, animated: true)

        default:

            tableView.deselectRow(at: indexPath, animated: true)
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
        guard let day = dateComponent.day else { return }
        let dateComp = DateComponents(day: -day)
        guard let reminderDay = Calendar.current.date(byAdding: dateComp, to: subscription.dueDate) else { return }
        reminderDayComp = Calendar.current.dateComponents([.day, .month, .year], from: reminderDay as Date)
    }

    func setReminder() {

        reminderManager.notifications = [Notification(id: "reminder - \(subscription.id)",
                                                      title: "\(subscription.name) 付款時間到囉!",
                                                      dateTime: DateComponents(calendar: Calendar.current,
                                                                               year: reminderDayComp.year,
                                                                               month: reminderDayComp.month,
                                                                               day: reminderDayComp.day,
                                                                               hour: 12,
                                                                               minute: 00))]
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
