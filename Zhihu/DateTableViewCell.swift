//
//  DateTableViewCell.swift
//  Zhihu
//
//  Created by Lisong Xu on 2/21/16.
//  Copyright © 2016 Lisong Xu. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
