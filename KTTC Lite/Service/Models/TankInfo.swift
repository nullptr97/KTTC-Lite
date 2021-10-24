//
//  TankInfo.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 19.10.2021.
//

import Foundation
import ObjectMapper

// MARK: - The11777
struct Tank: Mappable {
    var suspensions: [Int]?
    var tankDescription: String?
    var engines: [Int]?
    var nextTanks: [String: Int]?
    var nation: String?
    var isPremium: Bool?
    var tier, tankId: Int?
    var type: String?
    var guns, turrets: [Int]?
    var name: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        suspensions <- map["suspensions"]
        tankDescription <- map["description"]
        engines <- map["engines"]
        nextTanks <- map["next_tanks"]
        nation <- map["nation"]
        isPremium <- map["is_premium"]
        tier <- map["tier"]
        tankId <- map["tank_id"]
        type <- map["type"]
        guns <- map["guns"]
        turrets <- map["turrets"]
        name <- map["name"]
    }
}
