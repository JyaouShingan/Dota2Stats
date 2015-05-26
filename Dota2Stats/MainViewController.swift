//
//  MainViewController.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-16.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, ApiSessionAccountDelegate {
    
    let apiSession = DotaApiSession()
    
    var currentPlayer:PlayerInfo?
    
    @IBOutlet weak var playerIdTextField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text!.toInt() == nil {
            let alert = UIAlertController(title: "Invalid ID", message: "ID cannot contain non-numerical character", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {[unowned self] (UIAlertAction) -> Void in
                self.playerIdTextField.text = ""
            }
            alert.addAction(alertAction)
            presentViewController(alert, animated: true){}
            
            return true
        }
        apiSession.getPlayerInfo(textField.text!)
        textField.resignFirstResponder()
        return true
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? PlayerViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "ShowPlayerStat":
                    if currentPlayer != nil {
                        dvc.player = currentPlayer!
                    }
                default: break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        
        title = "Dota2 Stats"
        apiSession.accountDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func accountIdDoesNotExist() {
        let alert = UIAlertController(title: "Invalid ID", message: "Player does not exist", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {[unowned self] (UIAlertAction) -> Void in
             self.playerIdTextField.text = ""
        }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true){}

    }
    
    func accountInfoHasReach(player:PlayerInfo) {
        currentPlayer = player
        performSegueWithIdentifier("ShowPlayerStat", sender: self)
    }
}
