//
//  SearchHistoryModel.swift
//  bogota
//
//  Created by 전현성 on 2022/02/16.
//

import Foundation

struct SearchHistoryModel: Codable {
    var type: SearchType?
    
    // Station
    var stationName: String?
    var arsId: String?
    
    // Bus
    var busRoute: BusRoute?
}
