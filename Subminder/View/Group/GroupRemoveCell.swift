//
//  GroupRemoveCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/6.
//

import UIKit

class GroupRemoveCell: UICollectionViewCell {

    @IBOutlet weak var friendImg: UIImageView!
    
    @IBOutlet weak var friendNameLbl: UILabel!
    
    @IBOutlet weak var removalBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendImg.layer.cornerRadius = friendImg.frame.width / 2

        removalBtn.setTitle(nil, for: .normal)
        removalBtn.tintColor = .white
    }
    
    func setupCell(friendName: String, hideRemovalBtn: Bool) {
        
        friendNameLbl.text = friendName
        
        removalBtn.isHidden = hideRemovalBtn
    }

}
