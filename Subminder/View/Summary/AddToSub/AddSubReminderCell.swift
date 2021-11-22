//
//  AddSubReminderCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/24.
//

import UIKit

protocol ReminderDelegate: AnyObject {

    func reminderDidSet(_ dateComponent: DateComponents, _ cell: AddSubReminderCell)
}

class AddSubReminderCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reminderTextField: UITextField!

    weak var delegate: ReminderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reminderPicker.delegate = self
        reminderPicker.dataSource = self
        reminderTextField.inputView = reminderPicker
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    let reminderPicker = UIPickerView()

    let date = Date()
    var dateComponent = DateComponents()

    let reminderDay = ["永不", "付款當天", "1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"]

    let reminderCycle = ["", "天"]
    
    let reminderSuffix = ["", "前"]
}

extension AddSubReminderCell: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch component {

        case 0:
            return reminderDay.count

        case 1:
            return reminderCycle.count

        case 2:
            return reminderSuffix.count

        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch component {

        case 0 :
            return "\(reminderDay[row])"

        case 1:
            return "\(reminderCycle[row])"

        default:
            return "\(reminderSuffix[row])"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        switch component {

            // pickerview layout and set dateComponent
        case 0:
            if pickerView.selectedRow(inComponent: 0) == 0 {
                pickerView.selectRow(0, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                dateComponent.day = nil
            } else if pickerView.selectedRow(inComponent: 0) == 1 {
                pickerView.selectRow(0, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                dateComponent.day = 0 // due date
            } else {
                pickerView.selectRow(1, inComponent: 1, animated: true)
                pickerView.selectRow(1, inComponent: 2, animated: true)
                dateComponent.day = row - 1
            }

        case 1:
            if pickerView.selectedRow(inComponent: 1) == 0 {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
            } else {
                pickerView.selectRow(2, inComponent: 0, animated: true)
                pickerView.selectRow(1, inComponent: 2, animated: true)
            }

        case 2:
            if pickerView.selectedRow(inComponent: 2) == 0 {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.selectRow(0, inComponent: 1, animated: true)
            } else {
                pickerView.selectRow(2, inComponent: 0, animated: true)
                pickerView.selectRow(1, inComponent: 1, animated: true)
            }

        default:
            break
        }

        let day = pickerView.selectedRow(inComponent: 0)
        let cycle = pickerView.selectedRow(inComponent: 1)
        let suffix = pickerView.selectedRow(inComponent: 2)

        reminderTextField.text = "\(reminderDay[day]) \(reminderCycle[cycle])\(reminderSuffix[suffix])"

        delegate?.reminderDidSet(dateComponent, self)
    }
}
