//
//  AddSubPriceCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/27.
//

import UIKit
import CurrencyTextField

class AddSubPriceCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceTextField: CurrencyTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(title: String, textField: String) {
        
        titleLbl.text = title
        
        priceTextField.text = textField
    }
    
}
