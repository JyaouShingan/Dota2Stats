//
//  MatchHistoryCell.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class MatchHistoryCell: UITableViewCell {
    

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var matchLevelLabel: UILabel! {
        didSet{
            if matchLevelLabel.text == "Normal" {
                matchLevelLabel.textColor = UIColor.grayColor()
            } else if matchLevelLabel.text == "High" {
                matchLevelLabel.textColor = UIColor.whiteColor()
            } else if matchLevelLabel.text == "Very High" {
                matchLevelLabel.textColor = UIColor.yellowColor()
            }
        }
    }
    @IBOutlet weak var kdaLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var result: String? {
        didSet {
            if result! == "Won" {
                resultLabel.textColor = UIColor.greenColor()
            } else if result! == "Lost" {
                resultLabel.textColor = UIColor.redColor()
            }
            resultLabel.text = result
        }
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        heroImageView.image = nil
        heroNameLabel.text = nil
        resultLabel.text = nil
        matchLevelLabel.text = nil
        kdaLabel.text = nil
        timeLabel.text = nil
    }
    
}

