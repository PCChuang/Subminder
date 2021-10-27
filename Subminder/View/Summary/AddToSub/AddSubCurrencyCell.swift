//
//  AddSubCurrencyCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/19.
//

import UIKit

protocol CurrencyCellDelegate: AnyObject {

    func currencyRateDidChange(_ activeRate: Double, _ cell: AddSubCurrencyCell)
}

class AddSubCurrencyCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var currencyTextField: UITextField!

    weak var delegate: CurrencyCellDelegate?

    let currencyManager = CurrencyManager()

    let currencyPicker = UIPickerView()

    var currencies: [String] = []

    var values: [Double] = []

    var activeRate: Double = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        currencyTextField.inputView = currencyPicker

        currencyManager.delegate = self
        currencyManager.getConversionRate()

        currencyPicker.selectRow(10, inComponent: 0, animated: false)
        currencyTextField.text = pickerView(currencyPicker, titleForRow: currencyPicker.selectedRow(inComponent: 0), forComponent: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

        activeRate = values[row]

        delegate?.currencyRateDidChange(activeRate, self)
    }
}

extension AddSubCurrencyCell: CurrencyManagerDelegate {

    func manager(_ manager: CurrencyManager, didGet currencies: [String]) {

        self.currencies = currencies
    }

    func manager(_ manager: CurrencyManager, didGet values: [Double]) {

        self.values = values
    }
}
