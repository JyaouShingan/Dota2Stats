//
//  MatchHistory.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-20.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import Foundation

struct AbilityUpgrade {
    let ability:Int
    let time:Int
    let level:Int
}

struct MatchPlayerDetail {
    let account_id: UInt32
    let player_slot: UInt8
    let hero_id: Int
    let items: [Int]
    let kills: Int
    let deaths: Int
    let assists: Int
    let leaver_states: Int
    let gold: Int
    let last_hits: Int
    let denies: Int
    let gold_per_min: Int
    let xp_per_min: Int
    let gold_spent: Int
    let hero_damage: Int
    let tower_damage: Int
    let hero_healing :Int
    let level: Int
    let ability_upgrades:[AbilityUpgrade]
}

struct ShortPlayerDetail {
    let account_id: UInt32
    let player_slot: UInt8
    let hero_id: Int
}

struct MatchDetail {
    let players:[MatchPlayerDetail]
    let radiant_win: Bool
    let duration: Int
    let start_time: Int64
    let match_id: Int64
    let match_seq_num: Int64
    let tower_status_radiant: UInt16
    let tower_status_dire: UInt16
    let barracks_status_radiant: UInt8
    let barracks_status_dire: UInt8
    let cluster: Int
    let first_blood_time: Int
    let lobby_type: Int
    let human_player: Int
    let league_id: Int
    let positive_votes: Int
    let negative_votes: Int
    let game_mode: Int
    
    var matchLevel: String?
}

struct ShortMatchDetail {
    let match_id: Int64
    let match_seq_num: Int64
    let start_time: Int64
    let lobby_type: Int
    let players:[ShortPlayerDetail]
    let user_team: Bool //True for radiant , False for dire
    
    var player_won: Bool?
    var player_kda: (k:Int, d:Int, a:Int)?
    var matchLevel: String?
}

class MatchHistory {
    var account_id: UInt32
    
    var matches = Array<MatchDetail>()
    var matchesShort = Array<ShortMatchDetail>()
    
    var status: Int
    var num_results: Int
    var results_remaining: Int
    
    init (accountID: UInt32, status: Int, num: Int, remaining: Int) {
        self.account_id = accountID
        self.status = status
        self.num_results = num
        self.results_remaining = remaining
    }
}