//
//  StationByNameResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation

struct StationByNameResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: NameItemList?
}

struct NameItemList: Codable {
    var itemList: [NameStation]?     // 정류장 리스트
}

struct NameStation: Codable {
    var stId: String?               // 정류장 ID
    var stNm: String?               // 정류장 이름
    var tmX: String?                // 정류장 X 좌표
    var tmY: String?                // 정류장 Y 좌표
    var posX: String?               // 정류장 좌표 X (GRS80)
    var posY: String?               // 정류장 좌표 Y (GRS80)
    var arsId: String?              // 정류장 고유번호
}
