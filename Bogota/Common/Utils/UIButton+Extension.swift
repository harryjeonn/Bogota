//
//  UIButton+Extension.swift
//  bogota
//
//  Created by 전현성 on 2022/02/21.
//

import Foundation
import UIKit

extension UIButton {
    func addShadow(radius: Double, opacity: Float, width: Double, height: Double) {
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
    }
}
