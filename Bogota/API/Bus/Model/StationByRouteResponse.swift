//
//  StationByRouteResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/01/28.
//

import Foundation

struct StationByRouteResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: RouteItemList?
}

struct RouteItemList: Codable {
    var itemList: [RouteInfo]?              // 노선별 경유 정류소
}

struct RouteInfo: Codable {
    var busRouteId: String?                 // 노선ID
    var busRouteNm: String?                 // 노선명
    var seq: String?                        // 순번
    var section: String?                    // 구간ID
    var station: String?                    // 정류소ID
    var arsId: String?                      // 정류소번호
    var stationNm: String?                  // 정류소명
    var gpsX: String?                       // 좌표X (WGS84)
    var gpsY: String?                       // 좌표Y (WGS84)
    var posX: String?                       // 좌표X (GRS80)
    var posY: String?                       // 좌표Y (GRS80)
    var fullSectDist: String?               // 구간거리
    var direction: String?                  // 진행방향
    var stationNo: String?                  // 정류소고유번호
    var routeType: String?                  // 노선유형
    var beginTm: String?                    // 첫차시간
    var lastTm: String?                     // 막차시간
    var trnstnid: String?                   // 회차지 ID
    var sectSpd: String?                    // 구간속도
    var transYn: String?                    // 회차지여부
}

extension RouteInfo: Equatable {
    static func == (route1: RouteInfo, route2: RouteInfo?) -> Bool {
        guard let route2 = route2 else { return false }

        return route1.arsId == route2.arsId
    }
}
