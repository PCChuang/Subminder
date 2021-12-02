//
//  AddSubCurrencyCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/19.
//

import UIKit

protocol CurrencyCellDelegate: AnyObject {

    func currencyRateDidChange(_ cell: AddSubCurrencyCell, _ index: Int)
}

class AddSubCurrencyCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var currencyTextField: UITextField!

    weak var delegate: CurrencyCellDelegate?

    let currencyPicker = UIPickerView()

    var currencies = ["TWD",
                      "USD",
                      "EUR",
                      "JPY",
                      "GBP",
                      "AUD",
                      "CAD",
                      "CHF",
                      "CNY",
                      "HKD",
                      "NZD"
    ]
    
    var selectedIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        currencyPicker.dataSource = self

        currencyPicker.delegate = self

        currencyTextField.inputView = currencyPicker

        currencyPicker.selectRow(0, inComponent: 0, animated: false)

        currencyTextField.text = pickerView(currencyPicker, titleForRow: currencyPicker.selectedRow(inComponent: 0), forComponent: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(title: String, textField: String) {
        
        titleLbl.text = title
        
        currencyTextField.text = textField
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return currencies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return "\(currencies[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        currencyTextField.text = "\(currencies[row])"

        // pass data of selected row
        selectedIndex = pickerView.selectedRow(inComponent: 0)

        delegate?.currencyRateDidChange(self, selectedIndex)
    }
}
