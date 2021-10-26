//
//  UserInfo.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 11.10.2021.
//

import Foundation
import ObjectMapper

struct UserInfo<T>: Mappable where T: Mappable {
    var status: String?
    var meta: Meta?
    var data: T?

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        status <- map["status"]
        meta <- map["meta"]
        data <- map["data"]
    }
}

struct UserInfoWithArray<T>: Mappable where T: Mappable {
    var status: String?
    var meta: Meta?
    var data: [T]?

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        status <- map["status"]
        meta <- map["meta"]
        data <- map["data"]
    }
}

struct UsersList: Mappable {
    var nickname: String?
    var accountId: Int?
    
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        nickname <- map["nickname"]
        accountId <- map["account_id"]
    }
}

struct AnyData<T: Mappable>: Mappable {
    var dataArray: [T]?
    var data: T?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        dataArray <- map[map.JSON.keys.first ?? ""]
        data <- map[map.JSON.keys.first ?? ""]
    }
}

// MARK: - The120893754
struct AnyUserData: Mappable {
    var statistics: Statistics?
    var accountId, createdAt, updatedAt: Int?
    var lastBattleTime: Int?
    var nickname: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        statistics <- map["statistics"]
        accountId <- map["account_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        lastBattleTime <- map["last_battle_time"]
        nickname <- map["nickname"]
    }
}

protocol AllStatistics {
    var all: [String: Double]? { get set }
    var tankId: Int? { get set }
}

struct AnyTanksStats: Mappable, AllStatistics {
    var clan: [String: Int]?
    var strongholdSkirmish: [String: Double]?
    var regularTeam: [String: Int]?
    var accountId, maxXP: Int?
    var company: [String: Int]?
    var all: [String: Double]?
    var strongholdDefense: [String: Double]?
    var maxFrags: Int?
    var team: [String: Int]?
    var globalmap: [String: Double]?
    var markOfMastery: Int?
    var tankId: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        clan <- map["clan"]
        strongholdSkirmish <- map["stronghold_skirmish"]
        regularTeam <- map["regular_team"]
        accountId <- map["account_id"]
        maxXP <- map["max_xp"]
        company <- map["company"]
        all <- map["all"]
        strongholdDefense <- map["stronghold_defense"]
        maxFrags <- map["max_frags"]
        team <- map["team"]
        globalmap <- map["globalmap"]
        markOfMastery <- map["mark_of_mastery"]
        tankId <- map["tank_id"]
    }
}

struct AnyBlitzTanksStats: Mappable, AllStatistics {
    var all: [String: Double]?
    var lastBattleTime, accountId, maxXP, inGarageUpdated: Int?
    var maxFrags: Int?
    var markOfMastery, battleLifeTime: Int?
    var tankId: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        all <- map["all"]
        lastBattleTime <- map["last_battle_time"]
        accountId <- map["account_id"]
        maxXP <- map["max_xp"]
        inGarageUpdated <- map["in_garage_updated"]
        maxFrags <- map["max_frags"]
        markOfMastery <- map["mark_of_mastery"]
        battleLifeTime <- map["battle_life_time"]
        tankId <- map["tank_id"]
    }
}

struct Data<T>: Mappable where T: Mappable {
    var data: T?
    var dataArray: [T]? = []

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        map.JSON.keys.forEach { key in
            data <- map[key]
            if let data = data {
                dataArray?.append(data)
            }
        }
    }
}

struct UserData: Mappable {
    var array: [User]?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        array <- map[map.JSON.keys.first ?? ""]
    }
}

struct User: Mappable {
    var nickname: String?
    var accountId: Int?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        nickname <- map["nickname"]
        accountId <- map["account_id"]
    }
}

struct Meta: Mappable {
    var count: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        count <- map["count"]
    }
}

struct UserStatisticData: Mappable {
    var clientLanguage: String?
    var lastBattleTime, accountId, createdAt, updatedAt: Int?
    var globalRating, clanId: Int?
    var statistics: Statistics?
    var nickname: String?
    var logoutAt: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        clientLanguage <- map["client_language"]
        lastBattleTime <- map["last_battle_time"]
        accountId <- map["account_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        globalRating <- map["global_rating"]
        clanId <- map["clan_id"]
        statistics <- map["statistics"]
        nickname <- map["nickname"]
        logoutAt <- map["logout_at"]
    }
}

struct Statistics: Mappable {
    var clan, all, regularTeam: [String: Double?]?
    var treesCut: Int?
    var company, strongholdSkirmish, strongholdDefense, historical: [String: Double?]?
    var team: [String: Double?]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        clan <- map["clan"]
        all <- map["all"]
        regularTeam <- map["regular_team"]
        treesCut <- map["trees_cut"]
        company <- map["company"]
        strongholdSkirmish <- map["stronghold_skirmish"]
        strongholdDefense <- map["stronghold_defense"]
        historical <- map["historical"]
        team <- map["team"]
    }
}

struct TanksData: Mappable {
    var statistics: TanksStatistics?
    var markOfMastery, tankId: Int?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        statistics <- map["statistics"]
        markOfMastery <- map["mark_of_mastery"]
        tankId <- map["tank_id"]
    }
}

// MARK: - Statistics
struct TanksStatistics: Mappable {
    var wins, battles: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        wins <- map["wins"]
        battles <- map["battles"]
    }
}

struct TanksStatisticsData: Mappable {
    var clan: [String: Int]?
    var strongholdSkirmish: [String: Double]?
    var regularTeam: [String: Int]?
    var accountId, maxXp: Int?
    var company: [String: Int]?
    var all, strongholdDefense: [String: Double]?
    var maxFrags: Int?
    var team: [String: Int]?
    var globalmap: [String: Double]?
    var markOfMastery: Int?
    var tankId: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        clan <- map["clan"]
        strongholdSkirmish <- map["stronghold_skirmish"]
        regularTeam <- map["regular_team"]
        accountId <- map["account_id"]
        maxXp <- map["max_xp"]
        company <- map["company"]
        all <- map["all"]
        strongholdDefense <- map["stronghold_defense"]
        maxFrags <- map["max_frags"]
        team <- map["team"]
        globalmap <- map["globalmap"]
        markOfMastery <- map["mark_of_mastery"]
        tankId <- map["tank_id"]
    }
}
