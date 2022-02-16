//
//  MapViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit
import NMapsMap

class MapViewController: BaseViewController {
    @IBOutlet weak var mapView: NMFMapView!
    
    private var locationManager = LocationManager.shared
    
    private var stations = [NameStation]()
    private var markers = [NMFMarker]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = self.searchBarView
    }
    
    private func setupMapView() {
        guard let lat = locationManager.locManager.location?.coordinate.latitude,
              let lon = locationManager.locManager.location?.coordinate.longitude else {
                  print("Error: Can not load location")
                  return
              }
        
        mapView.latitude = lat
        mapView.longitude = lon
        mapView.zoomLevel = 15
        
        mapView.positionMode = .direction
        
        mapView.touchDelegate = self
    }
    
    private func makeMarker() {
        removeAllMaker()
        
        stations.forEach { station in
            let marker = NMFMarker()
            
            guard let tmY = station.tmY,
                  let tmX = station.tmX else { return }
            
            guard let lat = Double(tmY),
                  let lng = Double(tmX) else { return }
            
            marker.position = NMGLatLng(lat: lat, lng: lng)
            
            if let stNm = station.stNm {
                marker.captionText = stNm
            }
            
            marker.mapView = mapView
            marker.width = 20
            marker.height = 30
            
            makeInfoWindow(marker: marker, station: station)
            
            markers.append(marker)
            
            
        }
    }
    
    // 마커위에 뜨는 정보창
    private func makeInfoWindow(marker: NMFMarker, station: NameStation) {
        guard let arsId = station.arsId,
              let stNm = station.stNm else { return }
        
        let infoWindow = NMFInfoWindow()
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        dataSource.title = "\(stNm):\(arsId)"
        
        infoWindow.dataSource = dataSource
        
        infoWindow.touchHandler = { (overlay: NMFOverlay) -> Bool in
            // TODO: - 화면 전환
            let sb = UIStoryboard(name: "Detail", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return false }
            vc.arsId = arsId
            vc.stationNm = stNm
            self.navigationController?.pushViewController(vc, animated: true)
            return true
        };
        
        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            self.closeAllInfoWindow()
            if let marker = overlay as? NMFMarker {
                if marker.infoWindow == nil {
                    // 현재 마커에 정보 창이 열려있지 않을 경우 엶
                    infoWindow.open(with: marker)
                } else {
                    // 이미 현재 마커에 정보 창이 열려있을 경우 닫음
                    infoWindow.close()
                }
            }
            return true
        };
    }
    
    private func removeAllMaker() {
        markers.forEach { marker in
            marker.mapView = nil
        }
    }
    
    private func closeAllInfoWindow() {
        markers.forEach { marker in
            marker.infoWindow?.close()
        }
    }
    
    func searchStationByName(_ keyword: String) {
        self.showLoading()
        Task {
            do {
                let response = try await BusAPI.shared.getStationByNameList(keyword)
                print(response)
                self.hideLoading()
                if let items = response.msgBody?.itemList {
                    self.stations = items
                    self.makeMarker()
                    self.setupMapView()
                } else {
                    self.showCommonPopupView(title: "검색결과", desc: "검색 결과가 없습니다.")
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
        }
    }
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        closeAllInfoWindow()
    }
}
