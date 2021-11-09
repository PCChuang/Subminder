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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(friendName: String) {
        
        friendImg.image = UIImage(named: "Icons_36px_Profile_Selected")
        
        friendNameLbl.text = friendName
    }
    
}
