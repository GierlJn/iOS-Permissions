//
//  MetaDataTableViewCell.swift
//  PProject
//
//  Created by Julian Gierl on 29.03.20.
//  Copyright © 2020 Julian Gierl. All rights reserved.
//

import UIKit

class MetaDataTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(keyLabel: String, valueLabel: String?){
        if(valueLabel != nil){
            self.valueLabel.text = valueLabel
        }else{
            self.valueLabel.text = "NA"
        }
        
        self.keyLabel.text = keyLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
