//
//  ExpectedTanks.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 12.10.2021.
//

import Foundation
import ObjectMapper

struct Info: Mappable {
    var data: [Dates]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

// MARK: - Datum
struct Dates: Mappable {
    var idNum: Int?
    var expDef, expFrag, expSpot, expDamage: Double?
    var expWinRate: Double?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        idNum <- map["IDNum"]
        expDef <- map["expDef"]
        expFrag <- map["expFrag"]
        expSpot <- map["expSpot"]
        expDamage <- map["expDamage"]
        expWinRate <- map["expWinRate"]
    }
}

func logc(_ value: Double, _ base: Double) -> Double {
    return log(value) / log(base)
}
