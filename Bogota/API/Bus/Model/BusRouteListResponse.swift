//
//  BusRouteListResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/02/11.
//

import Foundation

struct BusRouteListResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: BusRouteList?
}

struct BusRouteList: Codable {
    var itemList: [BusRoute]?                 // 노선ID로 차량들의 위치정보
}

struct BusRoute: Codable {
    var busRouteId: String?                     // 노선 ID
    var busRouteNm: String?                     // 노선명
    var length: String?                         // 노선 길이 (km)
    var routeType: String?                      // 노선 유형
    var stStationNm: String?                    // 기점
    var edStationNm: String?                    // 종점
    var term: String?                           // 배차간격(분)
    var lastBusYn: String?                      // 막차 운행여부 (Y,N)
    var lastBusTm: String?                      // 금일막차시간
    var firstBusTm: String?                     // 금일첫차시간
    var lastLowTm: String?                      // 금일 저상막차시간
    var firstLowTm: String?                     // 금일 저상첫차시간
    var corpNm: String?                         // 운수사명
}
