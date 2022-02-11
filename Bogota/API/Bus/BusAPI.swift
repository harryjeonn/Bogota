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
    func getStationByPos(tmX: String, tmY: String) async throws -> StationByPosResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getStationByPos"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let radius = 500
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "tmX": "\(tmX)",
            "tmY": "\(tmY)",
            "radius": "\(radius)",
            "resultType": "json"
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getStationByPos response = \(response)")
        
        let res = try JSONDecoder().decode(StationByPosResponse.self, from: data)
        return res
    }
    
    //MARK: - 정류소 명칭 검색
    func getStationByNameList(_ keyword: String) async throws -> StationByNameResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getStationByName"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "resultType": "json",
            "stSrch": keyword
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getStationByName response = \(response)")
        
        let res = try JSONDecoder().decode(StationByNameResponse.self, from: data)
        return res
    }
    
    //MARK: - 고유번호를 입력받은 정류소의 저상버스 도착정보
    func getLowStationByUidList(_ arsId: String) async throws -> LowStationByUidResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/stationinfo/getLowStationByUid"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "resultType": "json",
            "arsId": arsId
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getLowStationByUidList response = \(response)")
        
        let res = try JSONDecoder().decode(LowStationByUidResponse.self, from: data)
        return res
    }
    
    //MARK: - 노선 별 경유 정류소 조회 서비스
    func getStationByRoute(_ busRouteId: String) async throws -> StationByRouteResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "resultType": "json",
            "busRouteId": busRouteId
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getStationByName response = \(response)")
        
        let res = try JSONDecoder().decode(StationByRouteResponse.self, from: data)
        return res
    }
    
    //MARK: - 노선ID로 차량들의 위치정보를 조회
    func getBusPosByRtidList(_ busRouteId: String) async throws -> BusPosByRtidListResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/buspos/getBusPosByRtid"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "resultType": "json",
            "busRouteId": busRouteId
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getBusPosByRtidList response = \(response)")
        
        let res = try JSONDecoder().decode(BusPosByRtidListResponse.self, from: data)
        return res
    }
    
    //MARK: - 노선번호에 해당하는 노선 목록 조회
    func getBusRouteList(_ strSrch: String) async throws -> BusRouteListResponse {
        let urlStr = "http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList"
        guard var urlComponents = URLComponents(string: urlStr) else { throw BusAPIError.invalidURL }
        
        let query: [String: String] = [
            "serviceKey": decodingKey,
            "resultType": "json",
            "strSrch": strSrch
        ]

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        guard let requestURL = urlComponents.url else { throw BusAPIError.invalidURL }
        
        let defaultSession = URLSession(configuration: .default)

        let (data, response) = try await defaultSession.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw BusAPIError.network
              }
        
        print("getBusPosByRtidList response = \(response)")
        
        let res = try JSONDecoder().decode(BusRouteListResponse.self, from: data)
        return res
    }
    
    //MARK: -
    func getStationByUidItem(_ arsId: String) {
        
    }
}
