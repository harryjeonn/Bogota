//
//  LocationManager.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    var locManager = CLLocationManager()
    
    func getCurrentLocation() {
        // delegate
        locManager.delegate = self
        // 거리 정확도 설정
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        // 권한 허용 팝업
        locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // 위치 서비스 On
            
            // 위치 업데이트 시작
            locManager.startUpdatingLocation()
        } else {
            // 위치 서비스 Off
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // 위치 정보 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
