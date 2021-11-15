//
//  SettingCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(title: String) {
        
        titleLbl.text = title
    }
    
}
