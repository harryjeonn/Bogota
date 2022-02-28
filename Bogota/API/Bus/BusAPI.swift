//
//  BusAPI.swift
//  bogota
//
//  Created by 전현성 on 2022/01/25.
//

import Foundation

enum BusAPIError: Error {
    case invalidURL
    case network
}

class BusAPI {
    static let shared = BusAPI()
    
    private let encodingKey = "k8TV0tzwFHNJE4z7KzTipafjxxhhC3EFYBxQdW9%2FouXJed3WkRjL8haC7LPgdozPFALzfWx0HwCZ7JjRxPPuzQ%3D%3D"
    private let decodingKey = "k8TV0tzwFHNJE4z7KzTipafjxxhhC3EFYBxQdW9/ouXJed3WkRjL8haC7LPgdozPFALzfWx0HwCZ7JjRxPPuzQ=="
    
    //MARK: - 좌표기반 근접 정류소 조회
    func getStationByPos(tmX: String, tmY: String, radius: String) async throws -> [PosStation]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getStationByPos"
        
        let query: [String: String] = [
            "tmX": tmX,
            "tmY": tmY,
            "radius": radius
        ]
        
        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(StationByPosResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 정류소 명칭 검색
    func getStationByNameList(_ keyword: String) async throws -> [NameStation]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getStationByName"
        
        let query: [String: String] = [
            "stSrch": keyword
        ]

        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(StationByNameResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 고유번호를 입력받은 정류소의 저상버스 도착정보
    func getLowStationByUidList(_ arsId: String) async throws -> [LowBusInfo]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getLowStationByUid"
        
        let query: [String: String] = [
            "arsId": arsId
        ]

        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(LowStationByUidResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 노선 별 경유 정류소 조회 서비스
    func getStationByRoute(_ busRouteId: String) async throws -> [RouteInfo]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute"

        let query: [String: String] = [
            "busRouteId": busRouteId
        ]

        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(StationByRouteResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 노선ID로 차량들의 위치정보를 조회
    func getBusPosByRtidList(_ busRouteId: String) async throws -> [BusPosition]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/buspos/getBusPosByRtid"

        let query: [String: String] = [
            "busRouteId": busRouteId
        ]

        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(BusPosByRtidListResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 노선번호에 해당하는 노선 목록 조회
    func getBusRouteList(_ strSrch: String) async throws -> [BusRoute]? {
        let urlStr = "http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList"
        
        let query: [String: String] = [
            "strSrch": strSrch
        ]
        
        let data = try await request(urlStr: urlStr, query: query)
        let res = try JSONDecoder().decode(BusRouteListResponse.self, from: data)
        
        print("\(urlStr) Response Body = \(res)")
        
        guard let msgBody = res.msgBody,
              let itemList = msgBody.itemList else { return nil }
        
        return itemList
    }
    
    //MARK: - 실제 API 통신하는 부분
    func request(urlStr: String, query: [String: String]) async throws -> Data {
        var query = query
        query.updateValue(decodingKey, forKey: "serviceKey")
        query.updateValue("json", forKey: "resultType")
        
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("\(urlStr) Response Header = \(response)")
        
        return data
    }
}


