//
//  SummaryCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class SummaryCell: UICollectionViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var cycle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
