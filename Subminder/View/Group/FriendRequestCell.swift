//
//  FriendRequestCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/30.
//

import UIKit

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var friendImg: UIImageView!

    @IBOutlet weak var friendNameLbl: UILabel!

    @IBOutlet weak var confirmBtn: UIButton!

    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//
//        confirmBtn.titleLabel?.font =  UIFont(name: "PingFang TC", size: 13)
//
//        deleteBtn.titleLabel?.font =  UIFont(name: "PingFang TC", size: 13)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(friendName: String) {

        friendImg.layer.cornerRadius = friendImg.frame.width / 2

        friendNameLbl.text = friendName

        confirmBtn.layer.cornerRadius = 6
        
        confirmBtn.titleLabel?.font =  UIFont(name: "PingFang TC", size: 13)
        deleteBtn.layer.cornerRadius = 6
        

        deleteBtn.titleLabel?.font =  UIFont(name: "PingFang TC", size: 13)
    }
}
