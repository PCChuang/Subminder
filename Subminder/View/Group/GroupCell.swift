//
//  GroupCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupImg: UIImageView!
    
    @IBOutlet weak var subscriptionLbl: UILabel!
    
    @IBOutlet weak var groupNameLbl: UILabel!
    
    @IBOutlet weak var memberCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(subscriptionName: String, groupName: String, numberOfMember: Int) {
        
        groupImg.image = UIImage(named: "Icons_36px_Profile_Selected")
        
        subscriptionLbl.text = subscriptionName
        
        groupNameLbl.text = groupName
        
        memberCountLbl.text = "(\(numberOfMember))"
    }
    
}
