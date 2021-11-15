//
//  GroupMemberTableViewCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/12.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var memberImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        memberImg.layer.cornerRadius = memberImg.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(name: String) {
        
        nameLbl.text = name
    }
}
