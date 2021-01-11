//
//  CG+Extensions.swift
//  SalamTime
//
//  Created by Alexander on 12.07.17.
//
//

import UIKit

extension CGPoint {
    func distance() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    func add(_ p: CGPoint) -> CGPoint {
        return CGPoint(x: x + p.x, y: y + p.y)
    }
    func substract(_ p: CGPoint) -> CGPoint {
        return CGPoint(x: x - p.x, y: y - p.y)
    }
    func mulitply(_ val: CGFloat) -> CGPoint {
        return CGPoint(x: x * val, y: y * val)
    }
}

extension CGSize {
    var point: CGPoint {
        return CGPoint(x: width, y: height)
    }
    
    func add(_ other: CGSize) -> CGSize {
        return CGSize(width: width + other.width, height: height + other.height)
    }
    
    func substract(_ other: CGSize) -> CGSize {
        return CGSize(width: width - other.width, height: height - other.height)
    }
    
    func mulitply(_ val: CGFloat) -> CGSize {
        return CGSize(width: width * val, height: height * val)
    }
    
    func integral() -> CGSize {
        return CGSize(width: round(width), height: round(height))
    }
    
    func aspectFit(maxSize: CGSize, maxScale: CGFloat = 0) -> CGSize {
        let scale = max(self.width / maxSize.width,
                        self.height / maxSize.height)
        if scale < maxScale { return self }
        return CGSize(width: width / scale, height: height / scale)
    }
    
    func aspectFill(maxSize: CGSize, maxScale: CGFloat = 0) -> CGSize {
        let scale = min(self.width / maxSize.width,
                        self.height / maxSize.height)
        if scale < maxScale { return self }
        return CGSize(width: width / scale, height: height / scale)
    }
}

extension CGPoint {
    var size: CGSize {
        return CGSize(width: x, height: y)
    }
}

extension CGRect {
    init(mid: CGPoint, size: CGSize) {
        let origin = mid.substract(size.point.mulitply(0.5))
        self.init(origin: origin, size: size)
    }
    
    var mid: CGPoint {
        set { origin = CGPoint(x: newValue.x - size.width / 2.0, y: newValue.y - size.height / 2.0) }
        get { return CGPoint(x: midX, y: midY) }
    }
    
    func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> CGRect {
        return self.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    
    func getAspectFit(viewSize size: CGSize) -> CGRect {
        let scale = min(self.width / size.width, self.height / size.height)
        let scaledSize = CGSize(width: scale * size.width, height: scale * size.height)
        return CGRect(x: self.midX - scaledSize.width / 2.0,
                      y: self.midY - scaledSize.height / 2.0,
                      width: scaledSize.width,
                      height: scaledSize.height)
    }
}



// MARK: - UI

extension UITableView {
    func deselectRows(animated: Bool = true) {
        if let idx = indexPathForSelectedRow {
            deselectRow(at: idx, animated: animated)
        }
    }
}

extension UIDevice {
    
    static let isSimulator: Bool = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    static let isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    static let isIPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension UIImage {
    
    func resizing(top: CGFloat, left: CGFloat, bott: CGFloat, right: CGFloat) -> UIImage {
        return self.resizableImage(withCapInsets: UIEdgeInsets(top: top, left: left, bottom: bott, right: right))
    }
    
    func resizing(all: CGFloat) -> UIImage {
        return self.resizableImage(withCapInsets: UIEdgeInsets(top: all, left: all, bottom: all, right: all))
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    
    mutating func remove(objects: [Element]) {
        for obj in objects {
            remove(object: obj)
        }
    }
}


extension Array {
    
    mutating func remove(filter: (Element)->(Bool)) {
        var indexes: [Int] = []
        for (idx, val) in self.enumerated() {
            if filter(val) {
                indexes.append(idx)
            }
        }
        for idx in indexes.reversed() {
            self.remove(at: idx)
        }
    }
}

extension String {
    var urlEscaped: String? {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    func addPath(_ component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
}

