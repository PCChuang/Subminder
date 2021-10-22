//
//  AddSubCurrencyCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/19.
//

import UIKit

class AddSubCurrencyCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var currencyTextField: UITextField!

    let currencyPicker = UIPickerView()

    var currencies = [
        "USD ($)",
        "EUR (€)",
        "AUD (A$)",
        "BRL (R$)",
        "GBP (£)",
        "BGN (лв)",
        "CAD (C$)",
        "CNY (¥)",
        "HRK (kn)",
        "CZK (Kč)",
        "DKK (kr)",
        "HKD (HK$)",
        "HUF (Ft)",
        "ISK (kr)",
        "INR (₹)",
        "IDR (Rp)",
        "ILS (₪)",
        "JPY (¥)",
        "MYR (M$)",
        "TWD (NT$)",
        "NZD (NZ$)",
        "NOK (kr)",
        "PHP (₱)",
        "PLN (zł)",
        "RON (lei)",
        "RUB (₽)",
        "SGD (S$)",
        "ZAR (R)",
        "KRW (₩)",
        "SEK (kr)",
        "CHF (Fr.)",
        "THB (฿)",
        "TRY (₺)"
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        currencyTextField.inputView = currencyPicker

        let defaultCurrency = NSLocale.current.currencySymbol
        currencyTextField.placeholder = defaultCurrency
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
    }
}
