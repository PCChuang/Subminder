//
//  AddToSubViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class AddToSubViewController: STBaseViewController {

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }

    @IBAction func onTapPublish(_ sender: UIButton) {

        publishAfterValidation()

//        self.publish(with: &subscription)
        _ = navigationController?.popViewController(animated: true)

        setReminder()

    }

    @IBAction func onTapGoBack(_ sender: UIButton) {

        showDiscardAlert()
    }
    
    var subColor: UIColor?
    var category: String? {

        didSet {

            tableView.reloadData()
        }
    }

    var reminderDayComp = DateComponents()

    var currencies: [String] = []

    var currencyValue: Double = 0

    var exchangePrice: Double = 0

    var subscription: Subscription = Subscription(
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
        note: ""
    )

    let reminderManager = LocalNotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

//        self.onPublished = { [weak self] () in
//            self?.onPublished?()
//            self?.dismiss(animated: true, completion: nil)
//        }

        let nib = UINib(nibName: "AddSubCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubCell")

        let textNib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "AddSubTextCell")
        
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

}

extension AddToSubViewController: UITableViewDataSource, UITableViewDelegate, UIColorPickerViewControllerDelegate, DateComponentDelegate, ReminderDelegate, CurrencyCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subSettings.count
    }

    // swiftlint:disable:next cyclomatic_complexity
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
            guard let cell = cell as? AddSubTextCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            cell.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            cell.textField.keyboardType = .numberPad

            cell.textField.placeholder = "$0.00"
            cell.textField.addTarget(self, action: #selector(onPriceChanged), for: .editingDidEnd)
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
        tableView.reloadData()
    }

    @objc func textFieldDidChange(_ sender: UITextField) {

        if let amountString = sender.text?.currencyInputFormatting() {

            sender.text = amountString
        }
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

    func publishAfterValidation() {

        if subscription.name == "" {

            let controller = UIAlertController(title: "Oops!", message: "請輸入訂閱名稱", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

            controller.addAction(okAction)

            present(controller, animated: true, completion: nil)
        } else {

            self.publish(with: &subscription)
        }
    }

    func showDiscardAlert() -> Void {

        DispatchQueue.main.async {

            let alertController = UIAlertController(title: "放棄編輯", message: "即將退出頁面，確認要放棄新增項目嗎?", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確認", style: .default) { _ in

                _ = self.navigationController?.popViewController(animated: true)
            }

            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

            alertController.addAction(okAction)

            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func currencyRateDidChange(_ activeRate: Double, _ cell: AddSubCurrencyCell) {

        currencyValue = activeRate

        exchangePrice = (subscription.price).doubleValue / currencyValue

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

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        if let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) {
            print("regex is \(regex))")
            amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        } else {
            print("fail")
        }

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
    }
}
