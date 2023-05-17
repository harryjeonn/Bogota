//
//  RouteType.swift
//  bogota
//
//  Created by 전현성 on 2022/01/27.
//

import Foundation
import UIKit

enum RouteType {
    case common
    case airport
    case village
    case gansun
    case jisun
    case cycle
    case wideArea
    case incheon
    case gyeonggi
    case abolition
    case unknown
    
    func title() -> String {
        switch self {
        case .common:
            return "공용"
        case .airport:
            return "공항"
        case .village:
            return "마을"
        case .gansun:
            return "간선"
        case .jisun:
            return "지선"
        case .cycle:
            return "순환"
        case .wideArea:
            return "광역"
        case .incheon:
            return "인천"
        case .gyeonggi:
            return "경기"
        case .abolition:
            return "폐지"
        case .unknown:
            return ""
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .gansun:
            return .blueColor
        case .jisun, .village:
            return .greenColor
        case .cycle:
            return .yellowColor
        case .wideArea:
            return .redColor
        default:
            return .gray
        }
    }
}

class Route: NSObject {
    static let shared = Route()
    
    func convertRouteType(_ type: String) -> RouteType {
        switch type {
        case "0":
            return .common
        case "1":
            return .airport
        case "2":
            return .village
        case "3":
            return .gansun
        case "4":
            return .jisun
        case "5":
            return .cycle
        case "6":
            return .wideArea
        case "7":
            return .incheon
        case "8":
            return .gyeonggi
        case "9":
            return .abolition
        default:
            return .unknown
        }
    }
    
    func convertCongetionToColor(_ congetion: String) -> UIColor {
        switch congetion {
        case "3":
            return .greenColor
        case "4":
            return .yellowColor
        case "5", "6":
            return .redColor
        default:
            return .gray
        }
    }
    
    func convertCongetionToState(_ congetion: String) -> String {
        switch congetion {
        case "3":
            return "여유"
        case "4":
            return "보통"
        case "5", "6":
            return "혼잡"
        default:
            return "알수없음"
        }
    }
}
