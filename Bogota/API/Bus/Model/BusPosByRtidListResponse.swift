//
//  BusPosByRtidListResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/02/09.
//

import Foundation

struct BusPosByRtidListResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: BusPositionItemList?
}

struct BusPositionItemList: Codable {
    var itemList: [BusPosition]?                 // 노선ID로 차량들의 위치정보
}

struct BusPosition: Codable {
    var sectOrd: String?                        // 구간순번
    var fullSectDist: String?                   // 정류소간 거리
    var sectDist: String?                       // 구간옵셋거리
    var rtDist: String?                         // 노선옵셋거리
    var stopFlag: String?                       // 정류소도착여부
    var sectionId: String?                      // 구간ID
    var dataTm: String?                         // 제공시간
    var tmX: String?
    var tmY: String?
    var gpsX: String?                           // 맵매칭X좌표 (WGS84)
    var gpsY: String?                           // 맵매칭Y좌표 (WGS84)
    var posX: String?                           // 맵매칭X좌표 (GRS80)
    var posY: String?                           // 맵매칭Y좌표 (GRS80)
    var vehId: String?                          // 버스ID
    var plainNo: String?                        // 차량번호
    var busType: String?                        // 차량유형
    var lastStTm: String?                       // 종점도착소요시간
    var nextStTm: String?                       // 다음정류소도착소요시간
    var nextStId: String?                       // 다음정류소아이디
    var lastStnId: String?                      // 최종정류장 ID
    var trnstnid: String?                       // 회차지 정류소ID
    var isrunyn: String?                        // 해당차량 운행여부
    var islastyn: String?                       // 막차여부
    var isFullFlag: String?                     // 만차여부
    var congetion: String?                      // 차량내부 혼잡도
}
