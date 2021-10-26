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
    var tier, tankId: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        tier <- map["tier"]
        tankId <- map["tank_id"]
    }
}
