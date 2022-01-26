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
    
    // 좌표기반 근접 정류소 조회
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
    
    // 정류소 명칭 검색
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
}
