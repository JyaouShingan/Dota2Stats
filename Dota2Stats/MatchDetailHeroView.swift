//
//  MatchDetailHeroView.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

@IBDesignable class MatchDetailHeroView: UIView {

    var view: UIView!
    
    @IBOutlet weak var playerAvatarImage: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerHeroImage: UIImageView!
    @IBOutlet weak var heroLevelLabel: UILabel!
    @IBOutlet weak var participationLabel: UILabel!
    @IBOutlet weak var dmgPercentLabel: UILabel!
    @IBOutlet weak var dmgLable: UILabel!
    @IBOutlet weak var kdaLabel: UILabel!
    @IBOutlet weak var lastHitLabel: UILabel!
    @IBOutlet weak var gpmLabel: UILabel!
    @IBOutlet weak var epmLabel: UILabel!
    @IBOutlet weak var heroHealLabel: UILabel!
    @IBOutlet weak var towerDmgLabel: UILabel!
    
    @IBOutlet weak var item1Image: UIImageView!
    @IBOutlet weak var item2Image: UIImageView!
    @IBOutlet weak var item3Image: UIImageView!
    @IBOutlet weak var item4Image: UIImageView!
    @IBOutlet weak var item5Image: UIImageView!
    @IBOutlet weak var item6Image: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUP()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUP()
    }
    
    func setUP() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MatchDetailHeroView", bundle: bundle)
        
        view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
