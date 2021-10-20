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

    var subColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()

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
    }

    func setupBarItems() {

        self.navigationItem.title = "新增訂閱項目"
    }
    
    //
    
}

extension AddToSubViewController: UITableViewDataSource, UITableViewDelegate, UIColorPickerViewControllerDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCurrencyCell", for: indexPath)
            guard let cell = cell as? AddSubCurrencyCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubDateCell", for: indexPath)
            guard let cell = cell as? AddSubDateCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell

        case 4, 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCycleCell", for: indexPath)
            guard let cell = cell as? AddSubCycleCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell

        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
            guard let cell = cell as? AddSubCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            cell.colorView.isHidden = true

            return cell

        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
            guard let cell = cell as? AddSubCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            cell.colorView.backgroundColor = subColor
            return cell
            
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubCell", for: indexPath)
            guard let cell = cell as? AddSubCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            cell.colorView.isHidden = true
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
            guard let cell = cell as? AddSubTextCell else {
                return cell
            }
            cell.title.text = subSettings[indexPath.row]
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {

        case 6:
            if let controller = storyboard?.instantiateViewController(identifier: "Category") as? CategoryViewController {
                self.navigationController?.pushViewController(controller, animated: true)
            }

        case 7:

            let colorPicker = UIColorPickerViewController()

            colorPicker.delegate = self

            present(colorPicker, animated: true)

        default:

            return
        }
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {

        let color = viewController.selectedColor
        subColor = color
        tableView.reloadData()
    }
}
