//
//  MemberHeaderView.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/12.
//

import UIKit

class MemberHeaderView: UITableViewHeaderFooterView {

    
    @IBOutlet weak var titleLbl: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setupView(title: String) {
        
        titleLbl.text = title
    }
}
