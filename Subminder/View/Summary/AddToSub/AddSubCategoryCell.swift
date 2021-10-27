//
//  AddSubCategoryCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/23.
//

import UIKit

class AddSubCategoryCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var nextPageBtn: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
