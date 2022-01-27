//
//  LowStationByUidResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/01/27.
//

import Foundation

struct LowStationByUidResponse: Codable {
    var comMsgHeader: ComMsgHeader?
    var msgHeader: MsgHeader?
    var msgBody: LowBusItemList?
}

struct LowBusItemList: Codable {
    var itemList: [LowBusInfo]?     // 도착 예정 버스
}

struct LowBusInfo: Codable {
    var busRouteId: String?         // 노선아이디
    var stId: String?               // 정류소 ID
    var arsId: String?              // 정류소 고유번호
    var stnNm: String?              // 정류소명
    var adirection: String?         // 방향
    var rtNm: String?               // 노선명
    var sectNm: String?             // 구간명
    var firstTm: String?            // 첫차시간
    var lastTm: String?             // 막차시간
    var term: String?               // 배차간격 (분)
    var routeType: String?          // 노선유형 (1:공항, 2:마을, 3:간선, 4:지선, 5:순환, 6:광역, 7:인천, 8:경기, 9:폐지, 0:공용)
    var nextBus: String?            // 막차운행여부
    var staOrd: String?             // 요청정류소순번
    var vehId1: String?             // 도착예정버스ID
    var plainNo1: String?           // 도착예정차량번호
    var sectOrd1: String?           // 도착예정버스의 현재 구간순번
    var stationNm1: String?         // 도착예정버스의 최종 정류소명
    var traTime1: String?           // 도착예정버스의 여행시간
    var traSpd1: String?            // 도착예정버스의 여행속도
    var isArrive1: String?          // 도착예정버스의 최종 정류소 도착출발여부
    var repTm1: String?             // 도착예정버스의 최종 보고 시간
    var isLast1: String?            // 도착예정버스의 막차여부
    var busType1: String?           // 도착예정버스의 차량유형
    var arrmsg1: String?            // 첫번째도착예정버스의 도착정보메시지    (0:일반버스, 1:저상)
    var busDist1: String?
    var vehId2: String?             // 두번째 도착예정버스ID
    var plainNo2: String?           // 두번째 도착예정차량번호
    var sectOrd2: String?           // 두번째 도착예정버스의 현재 구간순번
    var stationNm2: String?         // 두번째 도착예정버스의 최종 정류소명
    var traTime2: String?           // 두번째 도착예정버스의 여행시간
    var traSpd2: String?            // 두번째 도착예정버스의 여행속도
    var isArrive2: String?          // 두번째 도착예정버스의 최종 정류소 도착출발여부
    var repTm2: String?             // 두번째 도착예정버스 최종 보고 시간
    var isLast2: String?            // 두번째 도착예정버스의 막차여부
    var busType2: String?           // 두번째 도착예정버스의 차량유형     (0:일반버스, 1:저상)
    var arrmsg2: String?            // 두번째도착예정버스의 도착정보메시지
    var posX: String?               // 정류소 좌표X
    var posY: String?               // 정류소 좌표Y
    var gpsX: String?
    var gpsY: String?
    var deTourAt: String?           // 우회여부 (00: 일반, 11: 우회)
}
