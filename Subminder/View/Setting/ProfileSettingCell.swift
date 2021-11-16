//
//  ProfileSettingCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/15.
//

import UIKit

class ProfileSettingCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var idLbl: UILabel!
    
    @IBOutlet weak var copyImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(title: String, id: String) {
        
        titleLbl.text = title
        
        idLbl.text = id
    }
}
