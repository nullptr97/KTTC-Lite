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
    
    func setBlurBackground(style: UIBlurEffect.Style, frame: CGRect = .zero, withAlpha alpha: CGFloat = 1) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = frame == .zero ? bounds : frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = alpha
        insertSubview(blurView, at: 0)
    }
}

/// MARK: UIButton
extension UIButton {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        next?.touchesBegan(touches, with: event)
    }
   
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        next?.touchesMoved(touches, with: event)
    }
   
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        next?.touchesEnded(touches, with: event)
    }
   
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        next?.touchesCancelled(touches, with: event)
    }
   
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        next?.touchesEstimatedPropertiesUpdated(touches)
    }

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
    var coreImage: CIImage? { return CIImage(image: self) }

    var grayScale: UIImage {
        let imageRect:CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = size.width
        let height = size.height

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }

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
    open class func xwmColor(from state: StatType, with value: Int) -> UIColor {
        switch state {
        case .wn6, .wn7:
            if Range(0...469).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(470...859).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(860...1224).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1225...1634).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1635...1989).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .wn8:
            if Range(0...314).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(315...754).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(755...1314).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1315...1964).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1965...2524).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .eff:
            if Range(0...629).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(630...859).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(860...1139).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1140...1459).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1460...1734).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .winrate:
            if Range(0...46).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(47...48).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(49...51).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(52...56).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(57...64).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .xte:
            if Range(0...314).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(315...754).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(755...1314).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1315...1964).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1965...2524).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .battles:
            if Range(0...1500).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(1001...4000).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(4001...10000).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(10001...15000).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(15001...20000).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .damage:
            if Range(0...500).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(501...750).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(751...1000).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(1001...1800).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(1801...2500).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        case .frags:
            if Range(1...2).contains(value) {
                return .color(from: 0xff2901)
            } else if Range(2...3).contains(value) {
                return .color(from: 0xff8e00)
            } else if Range(3...4).contains(value) {
                return .color(from: 0xffe704)
            } else if Range(4...5).contains(value) {
                return .color(from: 0x59e500)
            } else if Range(5...6).contains(value) {
                return .color(from: 0x06a7a7)
            } else {
                return .color(from: 0xb14cc2)
            }
        }
    }

    open class var systemBorder: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x222222 : 0xdddddd)
            }
        } else {
            return .color(from: 0x252a32)
        }
    }
    
    open class var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x060506 : 0xFFFFFF)
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
    
    open class var dividerColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return .color(from: traitCollection.userInterfaceStyle == .dark ? 0x03071c : 0xfcf8e3)
            }
        } else {
            return .color(from: 0xFCF8E3)
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

/// MARK: CIImage
extension CIImage {
    func applying(saturation value: NSNumber) -> CIImage? {
        return applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: value])
    }
    var grayscale: CIImage? { return applying(saturation: 0) }
    var colored: CIImage? { return applying(saturation: 1) }
    
    var uiImage: UIImage? { return UIImage(ciImage: self) }

    func applying(contrast value: NSNumber) -> CIImage? {
        return applyingFilter("CIColorControls", parameters: [kCIInputContrastKey: value])
    }

    func renderedImage() -> UIImage? {
        guard let image = uiImage else { return nil }
        return UIGraphicsImageRenderer(size: image.size, format: image.imageRendererFormat).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}

/// MARK: UIGestureRecognizer
extension UIGestureRecognizer {
    func add(toViews views: UIView...) {
        views.forEach { $0.addGestureRecognizer(self) }
    }
}

/// MARK: UITableViewCell
extension UITableViewCell {
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    static var nib: UINib? {
        return UINib(nibName: UITableViewCell.reuseIdentifier, bundle: nil)
    }
    
    static var `class`: AnyClass {
        return Self.self
    }
}

/// MARK: UIConfigurable
public protocol UIConfigurable {
    func setUI()
}
