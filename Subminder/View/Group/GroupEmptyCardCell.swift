//
//  GroupEmptyCardCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/17.
//

import UIKit
import Lottie

class GroupEmptyCardCell: UICollectionViewCell {
    
    @IBOutlet weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        
        animationView.animationSpeed = 0.5
        
        animationView.play()
    }

}
