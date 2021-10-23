//
//  UIKit.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 19.10.2021.
//

import Foundation
import UIKit

enum CornersMask {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    case allTop
    case allBottom
    
    case all
    
    case none
    
    static func mask(to corners: Self...) -> CACornerMask {
        var mask: CACornerMask = CACornerMask()
        _ = corners.map { corner in
            switch corner {
            case .topLeft:
                mask.insert(.layerMinXMinYCorner)
            case .topRight:
                mask.insert(.layerMaxXMinYCorner)
            case .bottomLeft:
                mask.insert(.layerMinXMaxYCorner)
            case .bottomRight:
                mask.insert(.layerMaxXMaxYCorner)
            case .allTop:
                mask.insert(.layerMinXMinYCorner)
                mask.insert(.layerMaxXMinYCorner)
            case .allBottom:
                mask.insert(.layerMinXMaxYCorner)
                mask.insert(.layerMaxXMaxYCorner)
            case .all:
                mask.insert(.layerMinXMinYCorner)
                mask.insert(.layerMaxXMinYCorner)
                mask.insert(.layerMinXMaxYCorner)
                mask.insert(.layerMaxXMaxYCorner)
            case .none:
                mask.remove(.layerMinXMinYCorner)
                mask.remove(.layerMaxXMinYCorner)
                mask.remove(.layerMinXMaxYCorner)
                mask.remove(.layerMaxXMaxYCorner)
            }
        }
        return mask
    }
}

/// MARK: UIView
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    // Задать скругления
    func setCorners(_ radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    // Сделать обводку
    func drawBorder(_ radius: CGFloat, width: CGFloat, color: UIColor = UIColor.clear) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.shouldRasterize = false
        self.layer.rasterizationScale = 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
    
    func drawBorder(_ radius: CGFloat, width: CGFloat, color: UIColor = UIColor.clear, corners: CornersMask = .none) {
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        layer.maskedCorners = CornersMask.mask(to: corners)
        layer.borderWidth = width
        layer.shouldRasterize = false
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }
}

/// MARK: UIButton
extension UIButton {
    func setEnabled(_ state: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = state ? 1 : 0.5
        }) { [weak self] _ in
            self?.isEnabled = state
        }
    }
    
    func setHidden(_ state: Bool, with scaling: Bool = false) {
        if !state {
            isHidden = state
        }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = !state ? 1 : 0
            if scaling {
                self?.transform = !state ? .identity : .init(scaleX: 0.1, y: 0.1)
            }
        }) { [weak self] _ in
            if state {
                self?.isHidden = !state
            }
        }
    }
}

/// MARK: UINib
extension UINib {
    private static func xib(_ aclass: AnyClass) -> String {
        return "\(aclass)"
    }

    static func nib(_ aclass: AnyClass) -> UINib? {
        return UINib(nibName: xib(aclass), bundle: nil)
    }
}

/// MARK: UIImage
extension UIImage {
    typealias Megapixels = Int
    
    var megapixels: Megapixels {
        return (cgImage?.width ?? 0) * (cgImage?.height ?? 0) / 1000000
    }
    
    open func resize(toSize s: CGSize) -> UIImage? {
        internalResize(toWidth: s.width, toHeight: s.height)
    }
    
    open func resize(toWidth w: CGFloat) -> UIImage? {
        internalResize(toWidth: w)
    }
    
    open func resize(toHeight h: CGFloat) -> UIImage? {
        internalResize(toHeight: h)
    }
    
    private func internalResize(toWidth tw: CGFloat = 0, toHeight th: CGFloat = 0) -> UIImage? {
        var w: CGFloat?
        var h: CGFloat?
        
        if 0 < tw {
            h = size.height * tw / size.width
        } else if 0 < th {
            w = size.width * th / size.height
        }
        
        let image: UIImage?
        let rect: CGRect = CGRect(x: 0, y: 0, width: w ?? tw, height: h ?? th)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        draw(in: rect, blendMode: .normal, alpha: 1)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func named(_ name: String, with tintColor: UIColor = .clear) -> UIImage? {
        if tintColor != .clear {
            return .init(named: name)?.withTintColor(tintColor)
        } else {
            return .init(named: name)
        }
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func withTintColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
    
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(image, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

/// MARK: CGFloat
extension CGFloat {
    var int: Int {
        return Int(self)
    }
}

/// MARK: UIColor
extension UIColor {
    open class var systemBorder: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x252a32 : 0x252a32).withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 1 : 0.15)
            }
        } else {
            return .color(from: 0x252a32).withAlphaComponent(0.15)
        }
    }
    
    open class var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x100f15 : 0xFFFFFF)
            }
        } else {
            return .color(from: 0xFFFFFF)
        }
    }
    
    open class var secondarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x16151b : 0xFFFFFF)
            }
        } else {
            return .color(from: 0xFFFFFF)
        }
    }
    
    open class var systemPlaceholder: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x202020 : 0xf8f9fb)
            }
        } else {
            return .color(from: 0xf8f9fb)
        }
    }
    
    open class var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0xEBEBF5 : 0x3C3C43).withAlphaComponent(0.6)
            }
        } else {
            return .color(from: 0x3C3C43).withAlphaComponent(0.6)
        }
    }
    
    open class var label: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0xFFFFFF : 0x000000)
            }
        } else {
            return .color(from: 0x000000)
        }
    }
    
    class func color(from hex: UInt32) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(hex & 0xFF) / 256.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

/// MARK: CGColor
extension CGColor {
    class func color(from hex: UInt32) -> CGColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(hex & 0xFF) / 256.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
    }
}
