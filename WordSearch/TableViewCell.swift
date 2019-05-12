//
//  TableViewCell.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-12.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
	
	@IBOutlet var scoreLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
