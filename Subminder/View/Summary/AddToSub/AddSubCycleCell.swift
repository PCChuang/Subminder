//
//  AddSubCycleCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/19.
//

import UIKit

protocol DateComponentDelegate: AnyObject {

    func dateComponentDidChange(_ dateComponent: DateComponents, _ cell: AddSubCycleCell)
}

class AddSubCycleCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cycleTextField: UITextField!

    weak var delegate: DateComponentDelegate?

    let cyclePicker = UIPickerView()

    let cycleList = ["每"]

    let cycleListNumber = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"]
        
    let cycleListPeriod = ["天", "週", "月", "年"]
    
    let date = Date()
    var dateComponent = DateComponents()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cyclePicker.delegate = self
        cyclePicker.dataSource = self
        cycleTextField.inputView = cyclePicker
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return cycleList.count
            
        case 1:
            return cycleListNumber.count
            
        default:
            return cycleListPeriod.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(cycleList[row])"
            
        case 1:
            return "\(cycleListNumber[row])"
            
        default:
            return "\(cycleListPeriod[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cycle = pickerView.selectedRow(inComponent: 0)
        let number = pickerView.selectedRow(inComponent: 1)
        let time = pickerView.selectedRow(inComponent: 2)
        
        cycleTextField.text = "\(cycleList[cycle]) \(cycleListNumber[number]) \(cycleListPeriod[time])"

        guard let cycleNumber = Int(cycleListNumber[number]) else { return }

        switch time {

        case 0:
            dateComponent.day = Int(cycleNumber)
            dateComponent.month = 0
            dateComponent.year = 0

        case 1:
            dateComponent.day = Int(cycleNumber) * 7
            dateComponent.month = 0
            dateComponent.year = 0

        case 2:
            dateComponent.day = 0
            dateComponent.month = Int(cycleNumber)
            dateComponent.year = 0

        default:
            dateComponent.day = 0
            dateComponent.month = 0
            dateComponent.year = Int(cycleNumber)
        }

        delegate?.dateComponentDidChange(dateComponent, self)
    }

}
