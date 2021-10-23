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

struct BSCalculateData {
    var DAMAGE_DEAULT: Double
    var SPOTTED: Double
    var FRAGS: Double
    var DROPPED_CAPTURE_POINTS: Double
    var WIN_RATE: Double
    var CAP: Double
    var XP: Double
    var BATTLES: Double = 0
}

struct WN6CalculateData {
    var DAMAGE_DEAULT: Double
    var SPOTTED: Double
    var FRAGS: Double
    var DROPPED_CAPTURE_POINTS: Double
    var WIN_RATE: Double
    var AVERAGE_LEVEL: Double
    var BATTLES: Double = 0
}

struct WN8CalculateData {
    var DAMAGE_DEAULT: Double
    var SPOTTED: Double
    var FRAGS: Double
    var DROPPED_CAPTURE_POINTS: Double
    var WIN_RATE: Double
    var WINS: Double = 0
    var BATTLES: Double = 0
    var ID: Int
}

struct EFFCalculateData {
    var AVERAGE_LEVEL: Double
    var DAMAGE_DEAULT: Double
    var SPOTTED: Double
    var FRAGS: Double
    var DROPPED_CAPTURE_POINTS: Double
    var CAP: Double
}

struct XTECalculateData {
    var DAMAGE_DEAULT: Double
    var FRAGS: Double
    var BATTLES: Double = 0
}

public enum StatType {
    case wn6
    case wn7
    case wn8
    case eff
    case winrate
    case xte
    case battles
    case damage
    case frags
}

public typealias WN6 = Double
public typealias WN7 = Double
public typealias WN8 = Double
public typealias EFF = Double
public typealias xTE = Double

open class KTTCCalculator {
    var currentTankData: [WN8CalculateData] = []
    var expectedTankData: [WN8CalculateData] = []
    var averageData: WN8CalculateData?
    
    var effData: EFFCalculateData?
    var xTEData: XTECalculateData?
    
    var wn6Data: WN6CalculateData?
    
    var bsData: BSCalculateData?

    init(_ first: [WN8CalculateData], _ second: [WN8CalculateData], _ averageData: WN8CalculateData) {
        self.currentTankData = first.sorted(by: { $0.ID < $1.ID })
        self.expectedTankData = second.sorted(by: { $0.ID < $1.ID })
        self.averageData = averageData
    }
    
    init(_ effata: EFFCalculateData) {
        self.effData = effata
    }
    
    init(_ xteData: XTECalculateData) {
        self.xTEData = xteData
    }
    
    init(_ wn6Data: WN6CalculateData) {
        self.wn6Data = wn6Data
    }
    
    open func calculate(state: StatType) -> Any {
        switch state {
        case .wn6:
            /*
             (1240-1040/pow($avg_level, 0.164))*$avg_frags
             +$avg_dmg*530/(184*exp(0.24*$avg_level)+130)
             +$avg_spots*125
             +$avg_def*100
             +((185/(0.17+exp(($wr-35)*-0.134)))-500)*0.45
             +(6-$avg_level)*-60
             */
            if let wn6Data = wn6Data {
                var wn6 = (1240 - 1040 / pow(min(wn6Data.AVERAGE_LEVEL, 6), 0.164)) * wn6Data.FRAGS
                wn6 += wn6Data.DAMAGE_DEAULT * 530 / (184 * exp(0.24 * wn6Data.AVERAGE_LEVEL) + 130)
                wn6 += wn6Data.SPOTTED * 125
                wn6 += min(wn6Data.DROPPED_CAPTURE_POINTS, 2.2) * 100
                wn6 += ((185 / (0.17 + exp((wn6Data.WIN_RATE - 35) * -0.134))) - 500) * 0.45
                wn6 += (6 - min(wn6Data.AVERAGE_LEVEL, 6)) * -60
                return wn6
            } else { return 0 }
        case .wn7:
            if let wn6Data = wn6Data {
                var wn7 = (1240 - 1040 / pow(min(wn6Data.AVERAGE_LEVEL, 6), 0.164)) * wn6Data.FRAGS
                wn7 += wn6Data.DAMAGE_DEAULT * 530 / (184 * exp(0.24 * wn6Data.AVERAGE_LEVEL) + 130)
                wn7 += wn6Data.SPOTTED * 125 * min(wn6Data.AVERAGE_LEVEL, 3) / 3
                wn7 += min(wn6Data.DROPPED_CAPTURE_POINTS, 2.2) * 100
                wn7 += ((185 / (0.17 + exp((wn6Data.WIN_RATE - 35) * -0.134))) - 500) * 0.45
                wn7 += (-1 * (((5 - min(wn6Data.AVERAGE_LEVEL, 5)) * 125) / (1 + exp((wn6Data.AVERAGE_LEVEL - (wn6Data.BATTLES / pow(220, (3 / wn6Data.AVERAGE_LEVEL))) * 1.5)))))
                return wn7
            } else { return 0 }
        case .wn8:
            if let averageData = averageData {
                var expDamage: Double = 0
                var expSpotted: Double = 0
                var expFrags: Double = 0
                var expDef: Double = 0
                var expWin: Double = 0
                
                _ = expectedTankData.enumerated().compactMap { index, data in
                    print(data.WIN_RATE, averageData.WIN_RATE, currentTankData[index].WIN_RATE)
                    expDamage += (data.DAMAGE_DEAULT * currentTankData[index].BATTLES)
                    expSpotted += (data.SPOTTED * currentTankData[index].BATTLES)
                    expFrags += (data.FRAGS * currentTankData[index].BATTLES)
                    expDef += (data.DROPPED_CAPTURE_POINTS * currentTankData[index].BATTLES)
                    expWin += (0.01 * data.WIN_RATE * currentTankData[index].BATTLES)
                }

                let rDamage = averageData.DAMAGE_DEAULT / expDamage
                let rSpot = averageData.SPOTTED / expSpotted
                let rFrag = averageData.FRAGS / expFrags
                let rDef = averageData.DROPPED_CAPTURE_POINTS / expDef
                let rWin = averageData.WINS / expWin
                
                let rDamageC = max(0, (rDamage - 0.22) / (1 - 0.22))
                let rSpotC = max(0, min(rDamageC + 0.1, (rSpot - 0.38) / (1 - 0.38)))
                let rFragC = max(0, min(rDamageC + 0.2, (rFrag - 0.12) / (1 - 0.12)))
                let rDefC = max(0, min(rDamageC + 0.1, (rDef - 0.10) / (1 - 0.10)))
                let rWinC = max(0, (rWin - 0.71) / (1 - 0.71))
                
                var wn8 = 980 * rDamageC
                wn8 += 210 * rDamageC * rFragC
                wn8 += 155 * rFragC * rSpotC
                wn8 += 75 * rDefC * rFragC
                wn8 += 145 * min(1.8, rWinC)
                
                return wn8
            } else { return 0 }
        case .winrate, .battles, .damage, .frags:
            return 0
        case .eff:
            if let effData = effData {
                var eff = effData.DAMAGE_DEAULT * (10 / (effData.AVERAGE_LEVEL + 2)) * (0.204 + 2 * effData.AVERAGE_LEVEL / 100)
                eff += effData.FRAGS * 250
                eff += effData.SPOTTED * 150
                eff += logc(effData.CAP + 1, 1.732) * 150
                eff += effData.DROPPED_CAPTURE_POINTS * 150

                return eff
            } else { return 0 }
        case .xte:
            if let xTEData = xTEData {
                return (250 * (3 * xTEData.DAMAGE_DEAULT + xTEData.FRAGS)) / xTEData.BATTLES
            } else { return 0 }
        }
    }
}

func logc(_ value: Double, _ base: Double) -> Double {
    return log(value) / log(base)
}
