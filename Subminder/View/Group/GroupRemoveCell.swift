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

        removalBtn.setTitle(nil, for: .normal)
        removalBtn.tintColor = .white
    }
    
    func setupCell(friendName: String, hideRemovalBtn: Bool) {
        
        friendImg.image = UIImage(named: "Icons_36px_Profile_Selected")
        
        friendNameLbl.text = friendName
        
        removalBtn.isHidden = hideRemovalBtn
    }

}
