//
//  SearchType.swift
//  bogota
//
//  Created by 전현성 on 2022/02/11.
//

import Foundation

enum SearchType {
    case bus
    case station
    
    func headerTitle() -> String {
        switch self {
        case .bus:
            return "버스"
        case .station:
            return "정류장"
        }
    }
}
