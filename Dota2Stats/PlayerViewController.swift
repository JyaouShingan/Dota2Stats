//
//  PlayerViewController.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-18.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, UIScrollViewDelegate, ApiSessionMatchDelegate {
    
    var player:PlayerInfo?
    var matchesHistory: MatchHistory?
    
    var loaded = false
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    
    let apiSession = DotaApiSession()
    
    var heroDetailView: HeroDetailView?
    var matchHistoryView: MatchHistoryView?
    var ratesDetailView: UIView?
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiSession.matchDelegate = self
        playerNameLabel.text = self.player!.player_name
        
        //Load Player Avatar
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0), {[unowned self] () -> Void in
            let url = self.player!.avatar
            let imageURL = NSURL(string: url)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                    self.avatarView.image = UIImage(data: imageData)
                })
            }		
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !loaded {
            //Setup ScrollView Contents
            let svFrame = detailsScrollView.bounds
            
            //println(svFrame.size.width)
            //println(svFrame.size.height)
            
            
            detailsScrollView.contentSize = CGSize(width: svFrame.size.width * CGFloat(3),
                height: svFrame.size.height)
            
            if heroDetailView == nil {
                heroDetailView = HeroDetailView(frame: svFrame)
                detailsScrollView.addSubview(heroDetailView!)
            }
            
            if matchHistoryView == nil {
                matchHistoryView = MatchHistoryView(frame: CGRect(x: svFrame.size.width, y: 0.0, width: svFrame.size.width, height: svFrame.size.height))
                detailsScrollView.addSubview(matchHistoryView!)
            }
            
            apiSession.getShortMatchHistory(player!.account_id_32)
            loaded = true
        }
    }
    
    
    // MARK: ScrollView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth)/(pageWidth * 2.0)))
        pageController.currentPage = page
    }
    
    //MARK: Api Session Delegate
    
    func matchShortInfoHasReach(matches: MatchHistory) {
        heroDetailView!.heroesModel = matches
        matchHistoryView!.matchesHistory = matches
        matchesHistory = matches
    }
    
    func matchUserNotAllowed() {
        let alert = UIAlertController(title: "Permission Error", message: "User does not allow public access to records", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            //self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true){}

    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifer = segue.identifier {
            switch identifer {
            case "ShowMatchList" :
                if let vc = segue.destinationViewController as? MatchListController {
                    vc.title = "Match History"
                    vc.matchesHistory = matchesHistory
                }
            case "ShowMatchDetail" :
                if let vc = segue.destinationViewController as? MatchDetailController {
                    vc.title = "Match Detail"
                    apiSession.getSpecificMatchDetail((sender as! MatchHistoryView).currentSelectedMatchID, completion: { (matchDetail) -> Void in
                        vc.matchInfo = matchDetail
                        println(matchDetail)
                    })
                    
                }
            default:break
            }
        }
    }
}
