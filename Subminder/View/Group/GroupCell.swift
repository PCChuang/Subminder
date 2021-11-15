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
    
    @IBOutlet weak var payableLbl: UILabel!
    
    @IBOutlet weak var payableAmountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        groupImg.layer.cornerRadius = groupImg.frame.width / 2
        
        payableLbl.layer.masksToBounds = true
        payableLbl.layer.cornerRadius = 6
        payableLbl.textColor = .white
        
        payableAmountLbl.layer.masksToBounds = true
        payableAmountLbl.layer.cornerRadius = 6
        payableAmountLbl.textColor = .white
        payableAmountLbl.backgroundColor = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(subscriptionName: String, groupName: String, numberOfMember: Int) {
        
        subscriptionLbl.text = subscriptionName
        
        groupNameLbl.text = groupName
        
        memberCountLbl.text = "(\(numberOfMember))"
    }
    
}
