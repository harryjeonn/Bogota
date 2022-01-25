//
//  Utils.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation
import UIKit

class Utils {
    static let shared = Utils()
    
    // 가장 위에 있는 ViewController 반환
    func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
