//
//  GroupInviteCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import UIKit
import BEMCheckBox

class GroupInviteCell: UITableViewCell {

    @IBOutlet weak var friendImg: UIImageView!
    
    @IBOutlet weak var friendNameLbl: UILabel!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendImg.layer.cornerRadius = friendImg.frame.width / 2
        
        setupCheckBox()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(friendName: String) {
        
        friendNameLbl.text = friendName
    }
    
    func setupCheckBox() {
        
        checkBox.onTintColor = UIColor.hexStringToUIColor(hex: "#F6DF4F")
        checkBox.onFillColor = UIColor.hexStringToUIColor(hex: "#F6DF4F")
        checkBox.onCheckColor = UIColor.hexStringToUIColor(hex: "#FFFFFF")
    }
    
}
