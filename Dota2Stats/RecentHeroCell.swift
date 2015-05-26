//
//  RecentHeroCell.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-21.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class RecentHeroCell: UITableViewCell {
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var gameNumLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
