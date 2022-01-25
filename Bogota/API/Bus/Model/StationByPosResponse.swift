//
//  StationByPosResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/01/25.
//

import Foundation

struct StationByPosResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: ItemList?
}

struct ComMsgHeader: Codable {
    var errMsg: String?
    var requestMsgID: String?
    var responseMsgID: String?
    var responseTime: String?
    var returnCode: String?
    var successYN: String?
}
        
struct MsgHeader: Codable {
    var headerCd: String?
    var headerMsg: String?
    var itemCount: Int?
}

struct ItemList: Codable {
    var itemList: [Station]?     // 정류장 리스트
}

struct Station: Codable {
    var arsId: String?              // 정류장 고유번호
    var posX: String?            // 정류장 좌표X (GRS80)
    var posY: String?            // 정류장 좌표Y (GRS80)
    var dist: String?            // 거리
    var gpsX: String?            // 정류장 좌표X (WGS84)
    var gpsY: String?            // 정류장 좌표Y (WGS84)
    var stationTp: String?       // 정류장 타입  (0:공용, 1:일반형 시내/농어촌버스, 2:좌석형 시내/농어촌버스, 3:직행좌석형 시내/농어촌버스, 4:일반형 시외버스, 5:좌석형 시외버스, 6:고속형 시외버스, 7:마을버스)
    var stationNm: String?       // 정류장 이름
    var stationId: String?       // 정류장 번호
}
