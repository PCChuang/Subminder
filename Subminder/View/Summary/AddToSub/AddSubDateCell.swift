//
//  AddSubDateCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/19.
//

import UIKit

class AddSubDateCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateTextField: UITextField!

    let datePicker = UIDatePicker()

    override func awakeFromNib() {
        super.awakeFromNib()

        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(changeDate), for: UIControl.Event.valueChanged)
        datePicker.preferredDatePickerStyle = .wheels
        
        dateTextField.inputView = datePicker
        dateTextField.text = formateDate(date: Date())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func changeDate() {

        dateTextField.text = formateDate(date: datePicker.date)
    }

    func formateDate(date: Date) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)
    }
    
    func setupCell(title: String, textField: String) {
        
        titleLbl.text = title
        
        dateTextField.text = textField
    }
}
