//
//  GroupCardEmptyCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/17.
//

import UIKit
import Lottie

class GroupCardEmptyCell: UITableViewCell {

    @IBOutlet weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        
        animationView.animationSpeed = 0.5
        
        animationView.play()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
