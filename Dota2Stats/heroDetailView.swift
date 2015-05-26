//
//  HeroDetailView.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-20.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

@IBDesignable class HeroDetailView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var view: UIView!
    @IBOutlet weak var heroesTableView: UITableView!
    
    
    var recentHeroes:[(heroID:Int, count:Int)] = []
    var maxHeroGames = 1
    
    weak var heroesModel:MatchHistory? {
        didSet{
            var heroCount:[Int:Int] = [:]
            for match in heroesModel!.matchesShort {
                for player in match.players {
                    if player.account_id == heroesModel!.account_id {
                        if heroCount[player.hero_id] == nil {
                            heroCount[player.hero_id] = 0
                        } else {
                            heroCount[player.hero_id]! += 1
                        }
                    }
                }
            }
            
            for (heroID, count) in heroCount {
                recentHeroes.append(heroID:heroID, count:count)
            }
            
            recentHeroes.sort { $0.1 > $1.1 }
            
            maxHeroGames = recentHeroes[0].count
            //println(recentHeroes)
            if heroesTableView != nil {
                dispatch_async(dispatch_get_main_queue(),{[unowned self] () -> Void in
                    self.heroesTableView!.reloadData()
                })
            }
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
        let nib = UINib(nibName: "HeroDetailView", bundle: bundle)
        
        view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(10, recentHeroes.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "RecentHeroCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? RecentHeroCell
      
        if cell == nil {
            var cellNib = UINib(nibName: "RecentHeroCell", bundle: nil)
            tableView.registerNib(cellNib, forCellReuseIdentifier: "RecentHeroCell")
            
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? RecentHeroCell
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if recentHeroes.count != 0 {
            
            let heroList = defaults.dictionaryForKey("HeroList")!
            let heroes = heroList["\(recentHeroes[indexPath.row].heroID)"] as NSDictionary
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
            
            cell!.heroNameLabel.text = heroLocalName
            cell!.progressBar.progress = (Float(recentHeroes[indexPath.row].count) / Float(maxHeroGames))
            cell!.gameNumLabel.text = "\(recentHeroes[indexPath.row].count)"
        }
        
        return cell!
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
