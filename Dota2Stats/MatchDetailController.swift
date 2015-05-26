//
//  MatchDetailController.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class MatchDetailController: UIViewController {
    
    let apiSession = DotaApiSession()
    
    var matchInfo: MatchDetail? {
        didSet{
            updateContent()
        }
    }
    
    var totalKill = 0
    var totalDMG = 0
    
    @IBOutlet weak var masterScrollView: UIScrollView!
    @IBOutlet weak var radiantScrollView: UIScrollView!
    @IBOutlet weak var direScrollView: UIScrollView!
    @IBOutlet weak var matchStatView: UIView!
    
    @IBOutlet weak var matchIDLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var fbTimeLabel: UILabel!
    @IBOutlet weak var gameModeLabel: UILabel!
    
    @IBOutlet weak var radiant1View: MatchDetailHeroView!
    @IBOutlet weak var radiant2View: MatchDetailHeroView!
    @IBOutlet weak var radiant3View: MatchDetailHeroView!
    @IBOutlet weak var radiant4View: MatchDetailHeroView!
    @IBOutlet weak var radiant5View: MatchDetailHeroView!
    
    @IBOutlet weak var dire1View: MatchDetailHeroView!
    @IBOutlet weak var dire2View: MatchDetailHeroView!
    @IBOutlet weak var dire3View: MatchDetailHeroView!
    @IBOutlet weak var dire4View: MatchDetailHeroView!
    @IBOutlet weak var dire5View: MatchDetailHeroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        masterScrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 1200)
        radiantScrollView.contentSize = CGSize(width: 589, height: 319)
        direScrollView.contentSize = CGSize(width: 589, height: 319)
    }
    
    func updateContent() {
        
        matchIDLabel.text = "\(matchInfo!.match_id)"
        if matchInfo!.radiant_win {
            resultLabel.textColor = UIColor.greenColor()
            resultLabel.text = "Radiant Won"
        } else {
            resultLabel.textColor = UIColor.redColor()
            resultLabel.text = "Dire Won"
        }
        
        let currTime:Double = NSDate().timeIntervalSince1970
        let timeInterval = NSNumber(double: (currTime - Double(matchInfo!.start_time))).unsignedLongLongValue
        endTimeLabel.text = StaticFunc.convertTimeIntervalToString(timeInterval)
        lastTimeLabel.text = StaticFunc.convertSecToString(matchInfo!.duration)
        fbTimeLabel.text = StaticFunc.convertSecToString(matchInfo!.first_blood_time)
        gameModeLabel.text = StaticFunc.convertGameMode(matchInfo!.game_mode)
        
        for player in matchInfo!.players {
            totalKill += player.kills
            totalDMG += player.hero_damage
        }
        
        for player in matchInfo!.players {
            loadPlayerInfo(player)
        }
    }
    
    func loadPlayerInfo(player: MatchPlayerDetail) {
        switch player.player_slot{
        case 0:
            fillHeroView(radiant1View, player: player)
        case 1:
            fillHeroView(radiant2View, player: player)
        case 2:
            fillHeroView(radiant3View, player: player)
        case 3:
            fillHeroView(radiant4View, player: player)
        case 4:
            fillHeroView(radiant5View, player: player)
        case 128:
            fillHeroView(dire1View, player: player)
        case 129:
            fillHeroView(dire2View, player: player)
        case 130:
            fillHeroView(dire3View, player: player)
        case 131:
            fillHeroView(dire4View, player: player)
        case 132:
            fillHeroView(dire5View, player: player)
        default: break
        }
    }
    
    func fillHeroView(view: MatchDetailHeroView, player: MatchPlayerDetail) {
        if player.account_id == 4294967295 {
            view.playerNameLabel.text = "Annoymous"
        } else {
            apiSession.getShortPlayerInfo(player.account_id, completion: { (name, avatar) -> Void in
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0), { () -> Void in
                    let image = UIImage(data: NSData(contentsOfURL: NSURL(string: avatar)!)!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        view.playerAvatarImage.image = image
                    })
                })
                view.playerNameLabel.text = name
            })
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let heroList = defaults.dictionaryForKey("HeroList")!
        let heroes = heroList["\(player.hero_id)"] as NSDictionary
        let heroName = heroes["name"] as String
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0), { () -> Void in
            let realName = heroName.stringByReplacingOccurrencesOfString("npc_dota_hero_", withString: "", options: nil, range: nil)
            let heroImagePath = "http://cdn.dota2.com/apps/dota2/images/heroes/\(realName)_lg.png"
            let imageURL = NSURL(string: heroImagePath)
            let data = NSData(contentsOfURL: imageURL!)
            dispatch_async(dispatch_get_main_queue()){
                view.playerHeroImage.image = UIImage(data: data!)
            }
        })
        
        view.heroLevelLabel.text = "\(player.level)"
        let partPercent = String(format: "%.1f%%", 100*(Float(player.kills + player.assists)/Float(totalKill)))
        view.participationLabel.text = partPercent
        let dmgPercent = String(format: "%.1f%%", 100*(Float(player.hero_damage)/Float(totalDMG)))
        view.dmgPercentLabel.text = dmgPercent
        
        view.dmgLable.text = "\(player.hero_damage)"
        view.kdaLabel.text = "\(player.kills)/\(player.deaths)/\(player.assists)"
        view.lastHitLabel.text = "\(player.last_hits)/\(player.denies)"
        view.gpmLabel.text = "\(player.gold_per_min)"
        view.epmLabel.text = "\(player.xp_per_min)"
        view.heroHealLabel.text = "\(player.hero_healing)"
        view.towerDmgLabel.text = "\(player.tower_damage)"
    }
}
