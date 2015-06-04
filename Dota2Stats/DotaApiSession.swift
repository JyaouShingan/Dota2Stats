//
//  DotaApiSession.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-17.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import Foundation

struct PlayerInfo {
    var account_id: UInt64
    var account_id_32: UInt32
    var player_name: String
    var avatar: String
    var steam_id: String
    var community_visiblity_state: Int
    var personal_state: Int
    var profile_url: String
    var last_logoff:Int64?
    
    var real_name:String?
    var game_id:Int?
    var game_extrainfo:String?
    var loc_country_code:String?
    var loc_state_code:String?
    var loc_city_id:Int?
    
}

class DotaApiSession {
    init () {}
    
    let apiKey = "E074893EC944205F9C839B84955BBC5C"
    let qos = Int(QOS_CLASS_USER_INITIATED.value)
    
    weak var accountDelegate: ApiSessionAccountDelegate?
    weak var matchDelegate: ApiSessionMatchDelegate?
    
    var lastGameID: String?
    
    //MARK: Fetching Dynamic Information
    
    func getPlayerInfo (id:String) {
        if let id_32 = NSNumberFormatter().numberFromString(id)?.unsignedIntValue {
            var id_64 = UInt64(id_32)
            id_64 += 76561197960265728
            
            let playerInfoURL = NSURL(string: "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=\(apiKey)&steamids=\(id_64)")
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let dataTask = session.dataTaskWithURL(playerInfoURL!, completionHandler: { (data, response, error) -> Void in
                var parseError: NSError?
                let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

                if let info = parsedObject as? NSDictionary {
                    if let response = info["response"] as? NSDictionary {
                        if let players = response["players"] as? NSArray {
                            if players.count > 0 {
                                if let player = players[0] as? NSDictionary {
                                    var logoffInfo: AnyObject! = player["lastlogoff"]
                                    var num = logoffInfo as? NSNumber
                                    var logOffTime = num?.longLongValue
                                    
                                    var playerInfo = PlayerInfo(account_id: id_64,
                                        account_id_32: id_32,
                                        player_name: player["personaname"] as! String,
                                        avatar: player["avatarfull"] as! String,
                                        steam_id: player["steamid"] as! String,
                                        community_visiblity_state: player["communityvisibilitystate"] as! Int,
                                        personal_state: player["personastate"] as! Int,
                                        profile_url: player["profileurl"] as! String,
                                        last_logoff: logOffTime,
                                        real_name: nil,
                                        game_id: nil,
                                        game_extrainfo: nil,
                                        loc_country_code: nil,
                                        loc_state_code: nil,
                                        loc_city_id: nil)
                                    
                                    //Load optional data
                                    if let realName = player["realname"] as? String {
                                        playerInfo.real_name = realName
                                    }
                                    if let gameId = player["gameid"] as? Int {
                                        playerInfo.game_id = gameId
                                    }
                                    if let gameInfo = player["gameextrainfo"] as? String {
                                        playerInfo.game_extrainfo = gameInfo
                                    }
                                    if let locCountry = player["loccountrycode"] as? String {
                                        playerInfo.loc_country_code = locCountry
                                    }
                                    if let locState = player["locstatecode"] as? String {
                                        playerInfo.loc_state_code = locState
                                    }
                                    if let locCity = player["loccityid"] as? Int {
                                        playerInfo.loc_city_id = locCity
                                    }
                                    
                                    println(playerInfo.loc_country_code)
                                    
                                    dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                                        self.accountDelegate!.accountInfoHasReach(playerInfo)
                                    })
                                }
                            } else {
                                if self.accountDelegate != nil {
                                    dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                                        self.accountDelegate!.accountIdDoesNotExist()
                                    })
                                }
                            }
                        }
                    }
                }
            })
            
            dataTask.resume()
        }
    }
    
    func getShortPlayerInfo(accountID: UInt32, completion :(String, String) -> Void ) {
        var id_64 = UInt64(accountID)
        id_64 += 76561197960265728
        
        let playerInfoURL = NSURL(string: "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=\(apiKey)&steamids=\(id_64)")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(playerInfoURL!, completionHandler: { (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            if let info = parsedObject as? NSDictionary {
                if let response = info["response"] as? NSDictionary {
                    if let players = response["players"] as? NSArray {
                        if players.count > 0 {
                            if let player = players[0] as? NSDictionary {
                                let playerName = player["personaname"] as! String
                                let playerAvatar = player["avatarfull"] as! String
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    completion(playerName, playerAvatar)
                                })
                            }
                        }
                    }
                }
            }
            
        })
        
        dataTask.resume()
    }
    
    func getShortMatchHistory(id:UInt32) {
        let matchHistoryURL = NSURL(string: "http://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v001/?key=\(apiKey)&account_id=\(id)")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(matchHistoryURL!, completionHandler: { (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

            println(parsedObject!)
            
            if let json = parsedObject as? NSDictionary {
                if let result = json["result"] as? NSDictionary {
                    if (result["status"] as! Int) == 15 {
                        self.matchDelegate?.matchUserNotAllowed()
                        return
                    }
                    var history = MatchHistory(accountID: id,
                        status: result["status"] as! Int,
                        num: result["num_results"] as! Int,
                        remaining: result["results_remaining"] as! Int)
                    if let matches = result["matches"] as? NSArray {
                        for index in 0..<history.num_results {
                            if let match = matches[index] as? NSDictionary {
                                let matchID = ((match["match_id"]) as? NSNumber)?.longLongValue
                                let matchSeq = ((match["match_seq_num"]) as? NSNumber)?.longLongValue
                                let startTime = ((match["start_time"]) as? NSNumber)?.longLongValue
                                var playerTeam = true
                                
                                var playersArray:[ShortPlayerDetail] = []
                                
                                if let players = match["players"] as? NSArray {
                                    for pIndex in 0..<players.count {
                                        if let player = players[pIndex] as? NSDictionary {
                                            let accountId = ((player["account_id"]) as? NSNumber)?.unsignedIntValue
                                            let playerSlot = ((player["player_slot"]) as? NSNumber)?.unsignedCharValue
                                            let heroId = player["hero_id"] as! Int
                                            
                                            if accountId == id {
                                                playerTeam = playerSlot < 100
                                            }
                                            
                                            let shortPlayerDetail = ShortPlayerDetail(account_id: accountId!,
                                                player_slot: playerSlot!,
                                                hero_id: heroId)
                                            
                                            playersArray.append(shortPlayerDetail)
                                            
                                        }
                                    }
                                }
                                
                                let shortMatch = ShortMatchDetail(match_id: matchID!,
                                    match_seq_num: matchSeq!,
                                    start_time: startTime!,
                                    lobby_type: match["lobby_type"] as! Int,
                                    players: playersArray,
                                    user_team: playerTeam,
                                    player_won: nil,
                                    player_kda: nil,
                                    matchLevel: nil)
                                
                                history.matchesShort.append(shortMatch)
                                //println(history.matchesShort.count)
                            }
                        }
                    }
                    self.matchDelegate?.matchShortInfoHasReach(history)
                }
            }
        })
        
        dataTask.resume()

    }
    
    func getPlayerResultAndKDA(forMatchID: Int64, playerID: UInt32, inRadiant:Bool, completion: ((Int, Int, Int), Bool) -> Void ){
        let matchKDAURL = NSURL(string: "http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v001/?key=\(apiKey)&match_id=\(forMatchID)")
        
        var playerResult = true
        var kda = (0,0,0)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(matchKDAURL!, completionHandler: { (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            if let json = parsedObject as? NSDictionary {
                if let result = json["result"] as? NSDictionary {
                    
                    if let matchResult = result["radiant_win"] as? Bool {
                        playerResult = (matchResult && inRadiant) || (!matchResult && !inRadiant)
                    }
                    
                    let humanPlayers = result["human_players"] as! Int
                    let players = result["players"] as! NSArray
                    for index in 0..<humanPlayers {
                        let currPlayer = players[index] as! NSDictionary
                        if (currPlayer["account_id"] as! NSNumber).unsignedIntValue == playerID {
                            let kills = currPlayer["kills"] as! Int
                            let deaths = currPlayer["deaths"] as! Int
                            let assists = currPlayer["assists"] as! Int
                            kda = (kills, deaths, assists)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(kda, playerResult)
                    })
                }
            }
        })
        
        dataTask.resume()
    }
    
    func getSpecificMatchDetail(forMatchID: Int64, completion: (MatchDetail) -> Void ) {
        let matchDetailURL = NSURL(string: "http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v001/?key=\(apiKey)&match_id=\(forMatchID)")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(matchDetailURL!, completionHandler: { (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            if let json = parsedObject as? NSDictionary {
                if let result = json["result"] as? NSDictionary {
                    let radiantWin = result["radiant_win"] as! Bool
                    let duration = result["duration"] as! Int
                    let startTime = (result["start_time"] as! NSNumber).longLongValue
                    let match_id = forMatchID
                    let matchSeqNum = (result["match_seq_num"] as! NSNumber).longLongValue
                    let towerStatusRadiant = (result["tower_status_radiant"] as! NSNumber).unsignedShortValue
                    let towerStatusDire = (result["tower_status_dire"] as! NSNumber).unsignedShortValue
                    let barracksStatusRadiant = (result["barracks_status_radiant"] as! NSNumber).unsignedCharValue
                    let barracksStatusDire = (result["barracks_status_dire"] as! NSNumber).unsignedCharValue
                    let cluster = result["cluster"] as! Int
                    let firstBloodTime = result["first_blood_time"] as! Int
                    let lobbyType = result["lobby_type"] as! Int
                    let humanPlayers = result["human_players"] as! Int
                    let leagueID = result["leagueid"] as! Int
                    let posVote = result["positive_votes"] as! Int
                    let negVote = result["negative_votes"] as! Int
                    let gameMode = result["game_mode"] as! Int
                    var playersDetail: [MatchPlayerDetail] = []
                    
                    if let players = result["players"] as? NSArray {
                        for index in 0..<humanPlayers {
                            let currPlayer = players[index] as! NSDictionary
                            let accountID = (currPlayer["account_id"] as! NSNumber).unsignedIntValue
                            let playerSlot = (currPlayer["player_slot"] as! NSNumber).unsignedCharValue
                            let heroID = currPlayer["hero_id"] as! Int
                            let items = [currPlayer["item_0"] as! Int,
                                         currPlayer["item_1"] as! Int,
                                         currPlayer["item_2"] as! Int,
                                         currPlayer["item_3"] as! Int,
                                         currPlayer["item_4"] as! Int,
                                         currPlayer["item_5"] as! Int]
                            let kills = currPlayer["kills"] as! Int
                            let deaths = currPlayer["deaths"] as! Int
                            let assists = currPlayer["assists"] as! Int
                            let leaverStates = currPlayer["leaver_status"] as! Int
                            let gold = currPlayer["gold"] as! Int
                            let lastHits = currPlayer["last_hits"] as! Int
                            let denies = currPlayer["denies"] as! Int
                            let gpm = currPlayer["gold_per_min"] as! Int
                            let epm = currPlayer["xp_per_min"] as! Int
                            let goldSpent = currPlayer["gold_spent"] as! Int
                            let heroDamage = currPlayer["hero_damage"] as! Int
                            let towerDamage = currPlayer["tower_damage"] as! Int
                            let heroHeal = currPlayer["hero_healing"] as! Int
                            let level = currPlayer["level"] as! Int
                            var abilityUps: [AbilityUpgrade] = []
                            if let abilityUpgrades = currPlayer["ability_upgrades"] as? NSArray {
                                for ability in abilityUpgrades {
                                    let currAbility = ability as! NSDictionary
                                    abilityUps.append(AbilityUpgrade(ability: currAbility["ability"] as! Int, time: currAbility["time"] as! Int, level: currAbility["level"] as! Int))
                                }
                            }
                            
                            let thisPlayer = MatchPlayerDetail(account_id: accountID,
                                player_slot: playerSlot,
                                hero_id: heroID,
                                items: items,
                                kills: kills,
                                deaths: deaths,
                                assists: assists,
                                leaver_states: leaverStates,
                                gold: gold,
                                last_hits: lastHits,
                                denies: denies,
                                gold_per_min: gpm,
                                xp_per_min: epm,
                                gold_spent: goldSpent,
                                hero_damage: heroDamage,
                                tower_damage: towerDamage,
                                hero_healing: heroHeal,
                                level: level,
                                ability_upgrades: abilityUps)
                            playersDetail.append(thisPlayer)
                        }
                        
                    }
                    
                    let matchDetail = MatchDetail(players: playersDetail,
                        radiant_win: radiantWin,
                        duration: duration,
                        start_time: startTime,
                        match_id: match_id,
                        match_seq_num: matchSeqNum,
                        tower_status_radiant: towerStatusRadiant,
                        tower_status_dire: towerStatusDire,
                        barracks_status_radiant: barracksStatusRadiant,
                        barracks_status_dire: barracksStatusDire,
                        cluster: cluster,
                        first_blood_time: firstBloodTime,
                        lobby_type: lobbyType,
                        human_player: humanPlayers,
                        league_id: leagueID,
                        positive_votes: posVote,
                        negative_votes: negVote,
                        game_mode: gameMode,
                        matchLevel: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(matchDetail)
                    })
                }
            }
        })
        
        dataTask.resume()

    }
    
    //MARK: Fetching Static Information
    
    func getHeroList(completionHandler: (result:NSArray)->()) {
        let heroListURL = NSURL(string: "http://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=\(apiKey)&language=EU")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(heroListURL!, completionHandler: { (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

            if let json = parsedObject as? NSDictionary {
                if let result = json["result"] as? NSDictionary {
                    if let heroes = result["heroes"] as? NSArray {
                        completionHandler(result: heroes)
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    func getItemList(completionHandler: (result:NSArray)->() ) {
        let itemListURL = NSURL(string: "http://api.steampowered.com/IEconDOTA2_570/GetGameItems/v001/?key=\(apiKey)&language=EU")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let dataTask = session.dataTaskWithURL(itemListURL!){ (data, response, error) -> Void in
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            if let json = parsedObject as? NSDictionary {
                if let result = json["result"] as? NSDictionary {
                    if let items = result["items"] as? NSArray {
                        completionHandler(result: items)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
}

protocol ApiSessionAccountDelegate:class {
    
    func accountIdDoesNotExist()
    func accountInfoHasReach(player:PlayerInfo)
}

protocol ApiSessionMatchDelegate:class {
    func matchShortInfoHasReach(matches: MatchHistory)
    func matchUserNotAllowed()
}