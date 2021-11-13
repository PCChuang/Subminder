//
//  PaymentInfoTableViewCell.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/13.
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var friendImg: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var amountLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var noteLbl: UILabel!
    
    @IBOutlet weak var amountTitleLbl: UILabel!
    
    @IBOutlet weak var dateTitleLbl: UILabel!
    
    @IBOutlet weak var noteTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupLayer()
        
        setupBtn()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(name: String, amount: String, date: String, note: String) {
        
        nameLbl.text = name
        
        amountLbl.text = amount
        
        dateLbl.text = date
        
        noteLbl.text = note
    }
    
    func setupLayer() {
        
        amountTitleLbl.layer.masksToBounds = true
        amountTitleLbl.layer.cornerRadius = 6
        
        dateTitleLbl.layer.masksToBounds = true
        dateTitleLbl.layer.cornerRadius = 6
        
        noteTitleLbl.layer.masksToBounds = true
        noteTitleLbl.layer.cornerRadius = 6
        
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.cornerRadius = 6
        
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.cornerRadius = 6
    }
    
    func setupBtn() {
        
        confirmBtn.titleLabel?.font =  UIFont(name: "PingFang TC Medium", size: 13)

        cancelBtn.titleLabel?.font =  UIFont(name: "PingFang TC Medium", size: 13)
    }
    
}
