//
//  Foundation.swift
//  KTTC Lite
//
//  Created by Ярослав Стрельников on 26.10.2021.
//

import Foundation
import UIKit
import ObjectMapper

/// MARK: Array where UIViewController
extension Array where Element == UIViewController {
    func controller(byIndex index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else { return nil }
    }
}

/// MARK: Array
extension Array: Mappable {
    public init?(map: Map) { self.init() }
    public mutating func mapping(map: Map) { }

    func split() -> (left: [Element], right: [Element]) {
        let ct = count
        let leftSplit: ArraySlice<Element>
        let rightSplit: ArraySlice<Element>
        if ct > 100 {
            leftSplit = self[0 ..< 99]
            rightSplit = self[100 ..< ct]
        } else {
            let half = ct / 2
            leftSplit = self[0 ..< half]
            rightSplit = self[half ..< ct]
        }
        return (left: Array(leftSplit), right: Array(rightSplit))
    }

    mutating func erase() {
        removeAll()
    }
}

/// MARK: NSAttributedString
extension NSAttributedString {
    func replacingCharacters(in range: NSRange, with attributedString: NSAttributedString) -> NSMutableAttributedString {
        let ns = NSMutableAttributedString(attributedString: self)
        ns.replaceCharacters(in: range, with: attributedString)
        return ns
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        lhs = ns
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        return NSAttributedString(attributedString: ns)
    }
    
    func with(lineSpacing spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.count))
        return NSAttributedString(attributedString: attributedString)
    }
    
    class var attributedSpace: NSAttributedString {
        return NSAttributedString(string: " ")
    }

    class var attributedNewLine: NSAttributedString {
        return NSAttributedString(string: "\n")
    }
}

/// MARK: Double
extension Double {
    func round(to places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func checkToNaN() -> Double {
        isNaN || isInfinite ? 0 : self
    }
    
    var int: Int {
        Int(self)
    }
}
