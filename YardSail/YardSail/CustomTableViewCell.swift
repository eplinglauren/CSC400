//
//  CustomTableViewCell.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/5/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
