//
//  MatchListController.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit
import Haneke

class MatchListController: UITableViewController{
    
    let apiSession = DotaApiSession()
    var currentSelectedMatchID = Int64(0)
    
    
    weak var matchesHistory: MatchHistory? {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
            })
        }
    }
    var currentRowNum = 25
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRowNum
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
            
            let heroes = heroList["\(heroID)"] as! NSDictionary
            let heroLocalName = heroes["localName"] as! String
            let heroName = heroes["name"] as! String
            
            let realName = heroName.stringByReplacingOccurrencesOfString("npc_dota_hero_", withString: "", options: nil, range: nil)
            let heroImagePath = "http://cdn.dota2.com/apps/dota2/images/heroes/\(realName)_lg.png"
            let imageURL = NSURL(string: heroImagePath)
            
            cell!.heroImageView.hnk_setImageFromURL(imageURL!, placeholder: nil, format: nil, failure: nil, success: nil)

            
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
        
        if indexPath.row == self.currentRowNum - 1 {
            reloadMoreData()
        }
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifer = segue.identifier {
            switch identifer {
            case "ShowMatchDetail_List":
                if let vc = segue.destinationViewController as? MatchDetailController {
                    vc.title = "Match Detail"
                    apiSession.getSpecificMatchDetail((sender as! MatchListController).currentSelectedMatchID, completion: { (matchDetail) -> Void in
                        vc.matchInfo = matchDetail
                    })
                }
            default: break
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentSelectedMatchID = matchesHistory!.matchesShort[indexPath.row].match_id
        performSegueWithIdentifier("ShowMatchDetail_List", sender: self)
    }
    
    func reloadMoreData() {
        if currentRowNum < matchesHistory?.matchesShort.count {
            currentRowNum += 25
        }
        tableView.reloadData()
    }
}
