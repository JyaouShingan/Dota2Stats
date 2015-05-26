//
//  MatchHistoryView.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

@IBDesignable class MatchHistoryView: UIView, UITableViewDelegate, UITableViewDataSource {

    var view: UIView!
    @IBOutlet weak var matchesTableView: UITableView!
    
    let apiSession = DotaApiSession()
    var currentSelectedMatchID = Int64(0)
    
    weak var matchesHistory: MatchHistory? {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                self.matchesTableView.reloadData()
            })
        }
    }
    
    
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
        let nib = UINib(nibName: "MatchHistoryView", bundle: bundle)
        
        view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let reuseIdentifer = "MatchHistoryCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifer) as? MatchHistoryCell
        
        if cell == nil {
            var cellNib = UINib(nibName: "MatchHistoryCell", bundle: nil)
            tableView.registerNib(cellNib, forCellReuseIdentifier: reuseIdentifer)
            
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifer) as? MatchHistoryCell
        }
        cell!.result == "    "
        cell!.kdaLabel == "KDA:"
        
        if matchesHistory != nil {
            let defaults = NSUserDefaults.standardUserDefaults()
            let heroList = defaults.dictionaryForKey("HeroList")!
            
            var heroID = 1
            var match = matchesHistory!.matchesShort[indexPath.row]
            for player in match.players {
                if player.account_id == matchesHistory!.account_id {
                    heroID = player.hero_id
                }
            }
            
            let heroes = heroList["\(heroID)"] as NSDictionary
            let heroLocalName = heroes["localName"] as String
            let heroName = heroes["name"] as String
            
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0), { () -> Void in
                let realName = heroName.stringByReplacingOccurrencesOfString("npc_dota_hero_", withString: "", options: nil, range: nil)
                let heroImagePath = "http://cdn.dota2.com/apps/dota2/images/heroes/\(realName)_lg.png"
                let imageURL = NSURL(string: heroImagePath)
                let data = NSData(contentsOfURL: imageURL!)
                dispatch_async(dispatch_get_main_queue()){
                    cell!.heroImageView.image = UIImage(data: data!)
                }
            })
            
            if match.player_kda == nil || match.player_won == nil {
                apiSession.getPlayerResultAndKDA(match.match_id, playerID: matchesHistory!.account_id, inRadiant: match.user_team, completion: { (kda, result) -> Void in
                    self.matchesHistory!.matchesShort[indexPath.row].player_kda = kda
                    self.matchesHistory!.matchesShort[indexPath.row].player_won = result

                    let computedKda = Float(kda.0)+Float(kda.2)/Float(kda.1)
                    cell!.kdaLabel.text = String(format: "KDA:%.1f(%d / %d / %d)", computedKda, kda.0, kda.1, kda.2)
                    "\(computedKda)(\(kda.0) / \(kda.1) / \(kda.2))"
                    cell!.result = result ? "Won" : "Lost"
                })
            } else {
                let computedKda = (Float(match.player_kda!.0)+Float(match.player_kda!.2)/Float(match.player_kda!.1))
                cell!.kdaLabel.text = String(format: "KDA:%.1f(%d / %d / %d)", computedKda, match.player_kda!.0,match.player_kda!.1, match.player_kda!.2)
                cell!.result = match.player_won! ? "Won" : "Lost"
            }
            
            let currTime:Double = NSDate().timeIntervalSince1970
            let timeInterval = NSNumber(double: (currTime - Double(match.start_time))).unsignedLongLongValue
            println(timeInterval)
            
            cell!.timeLabel.text = StaticFunc.convertTimeIntervalToString(timeInterval)
            cell!.heroNameLabel.text = heroLocalName
            
        }
        return cell!
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentSelectedMatchID = matchesHistory!.matchesShort[indexPath.row].match_id
        (self.window?.rootViewController? as UINavigationController).topViewController.performSegueWithIdentifier("ShowMatchDetail", sender: self)
    }
    
    @IBAction func showMoreMatches(sender: UIButton) {
        (self.window?.rootViewController? as UINavigationController).topViewController.performSegueWithIdentifier("ShowMatchList", sender: self)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
