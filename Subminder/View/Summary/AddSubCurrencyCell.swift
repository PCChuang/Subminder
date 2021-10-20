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
    
    var countries: [Country] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        currencyTextField.inputView = currencyPicker

        let localeList = NSLocale.isoCountryCodes

        for localeListItem in localeList {
            
            let localeIdentifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: localeListItem])
            
            let locale = NSLocale(localeIdentifier: localeIdentifier)

            guard let countryName = locale.displayName(forKey: NSLocale.Key.identifier, value: localeIdentifier) else {
                return
            }

//            guard let currencyName = locale.currencyCode else {
//                return
//            }
            
            let currencyName = locale.currencyCode ?? ""

            let currencySymbol = locale.currencySymbol

            countries.append(Country(countryName: countryName, currencyName: currencyName, currencySymbol: currencySymbol))
        }
        
        currencyPicker.reloadAllComponents()
    }

    struct Country {

        let countryName: String
        let currencyName: String
        let currencySymbol: String
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = "\(countries[row].countryName) \(countries[row].currencyName): \(countries[row].currencySymbol)"
        return item
    }
}
