//
//  StaticFunc.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-25.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import Foundation

class StaticFunc {
    class func convertTimeIntervalToString (interval: UInt64) -> String {
        switch interval {
        case 0..<60:
            return "Just Now"
        case 60..<3600:
            let min:Int = Int(interval / 60)
            if min == 1 {
                return "1 minute ago"
            } else {
                return "\(min) minutes ago"
            }
        case 3600..<86400:
            let hour = Int(interval / 3600)
            if hour == 1 {
                return "1 hour ago"
            } else {
                return "\(hour) hours ago"
            }
        case 86400..<2592000:
            let day = Int(interval / 86400)
            if day == 1 {
                return "1 day ago"
            } else {
                return "\(day) days ago"
            }
        case 2592000..<15552000:
            let month = Int(interval / 2592000)
            if month == 1 {
                return "1 month ago"
            } else {
                return "\(month) months ago"
            }
        default:
            return "> Half Year"
        }
    }
    
    class func convertSecToString (time: Int) -> String {
        switch time {
        case 0..<60:
            return "\(time) secs"
        case 60..<120:
            return "1 min"
        default:
            return "\(time/60) mins"
        }
    }
    
    class func convertGameMode(mode: Int) -> String {
        switch mode {
        case 0:
            return "Unknown"
        case 1:
            return "All Pick"
        case 2:
            return "Captains Mode"
        case 3:
            return "Random Draft"
        case 4:
            return "Single Draft"
        case 5:
            return "All Random"
        case 6:
            return "?? INTRO/DEATH ??"
        case 7:
            return "The Diretide"
        case 8:
            return "Reverse CM"
        case 9:
            return "Greeviling"
        case 10:
            return "Tutorial"
        case 11:
            return "Mid Only"
        case 12:
            return "Least Played"
        case 13:
            return "New Player Pool"
        case 14:
            return "Compendium M"
        case 15:
            return "Custom"
        case 16:
            return "Captains Draft"
        case 17:
            return "Balanced Draft"
        case 18:
            return "Ability Draft"
        case 19:
            return "?? EVENT ??"
        case 20:
            return "AR DM"
        case 21:
            return "Solo Mid"
        default:
            return "Unknown"
        }
    }
    
    class func itemNameToURL (name:String) -> NSURL {
        let realName = name.stringByReplacingOccurrencesOfString("item_", withString: "", options: nil, range: nil)
        let itemImagePath = "http://cdn.dota2.com/apps/dota2/images/items/\(realName)_lg.png"
        let imageURL = NSURL(string: itemImagePath)
        
        return imageURL!
    }
}