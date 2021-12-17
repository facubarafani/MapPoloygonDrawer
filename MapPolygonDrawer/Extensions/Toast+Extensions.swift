//
//  Toast+Extensions.swift
//  MapPolygonDrawer
//
//  Created by Facundo Muni on 17/12/2021.
//

import Foundation
import Toast_Swift

protocol Toastable {
    var title: String? { get }
    var message: String { get }
    var image: UIImage? { get }
}

extension UIView {
    func getToastPoint() -> CGPoint {
        return CGPoint(x: center.x, y: frame.height - 50)
    }
    
    func makeToast(content: Toastable, position: ToastPosition = .bottom, duration: TimeInterval = ToastManager.shared.duration, completion: ((_ didTap: Bool) -> Void)? = nil) {
        var style = ToastStyle()
        style.displayShadow = true
        style.titleColor = .white
        style.messageColor = .white
        
        let toastPoint: CGPoint
        switch position {
        case .top:
            toastPoint = CGPoint(x: center.x, y: frame.minY + 40)
        case .bottom:
            toastPoint = CGPoint(x: center.x, y: frame.height - 80)
        }
        makeToast(content.message, duration: duration, point: toastPoint, title: content.title, image: content.image, style: style, completion: completion)
    }
    
    func makeToast(message: String, position: ToastPosition = .bottom, duration: TimeInterval = ToastManager.shared.duration, completion: ((_ didTap: Bool) -> Void)? = nil) {
        var style = ToastStyle()
        style.displayShadow = true
        style.titleColor = .white
        style.messageColor = .white
        
        let toastPoint: CGPoint
        switch position {
        case .top:
            toastPoint = CGPoint(x: center.x, y: frame.minY + 40)
        case .bottom:
            toastPoint = CGPoint(x: center.x, y: frame.height - 80)
        }
        makeToast(message, duration: duration, point: toastPoint, title: nil, image: nil, style: style, completion: completion)
    }
}

enum ToastPosition {
    case top
    case bottom
}
