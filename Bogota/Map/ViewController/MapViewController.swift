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
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var infoViewTitleLabel: UILabel!
    @IBOutlet weak var infoViewSubTitleLabel: UILabel!
    
    private var locationManager = LocationManager.shared
    
    private var stations = [NameStation]()
    private var selectStation: NameStation?
    private var markers = [NMFMarker]()
    private var selectedMarkerWidth: CGFloat = 30
    private var unselectedMarkerWidth: CGFloat = 20
    
    var stationName: String?
    var arsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupInfoView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        getStationByNameList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = self.searchBarView
    }
    
    // MARK: - Map
    private func setupMapView() {
        guard let lat = locationManager.locManager.location?.coordinate.latitude,
              let lon = locationManager.locManager.location?.coordinate.longitude else {
                  print("Error: Can not load location")
                  return
              }
        
        mapView.latitude = lat
        mapView.longitude = lon
        mapView.zoomLevel = 16
        
        mapView.positionMode = .direction
        
        mapView.touchDelegate = self
    }
    
    private func cameraUpdate(latStr: String, lngStr: String, isAnimation: Bool) {
        guard let lat = Double(latStr),
              let lng = Double(lngStr) else { return }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        if isAnimation {
            cameraUpdate.animation = .easeIn
        } else {
            mapView.zoomLevel = 16
        }
        
        mapView.moveCamera(cameraUpdate)
    }
    
    // MARK: - Marker
    private func setupSelectedMarker() {
        stations.forEach { station in
            if station.arsId != arsId {
                return
            }
            selectStation = station
            
            guard let tmY = station.tmY,
                  let tmX = station.tmX else { return }
            
            self.cameraUpdate(latStr: tmY, lngStr: tmX, isAnimation: false)
        }
    }
    
    private func makeAroundMarker(_ items: [PosStation]) {
        removeAllMarker()
        items.forEach { item in
            guard let gpsY = item.gpsY,
                  let gpsX = item.gpsX,
                  let lat = Double(gpsY),
                  let lng = Double(gpsX),
                  let stationNm = item.stationNm else { return }
            
            var isSelected = false
            if gpsX == selectStation?.tmX && gpsY == selectStation?.tmY {
                isSelected = true
            }
            
            makeMarker(lat: lat, lng: lng, name: stationNm, isSelected: isSelected, stationInfo: item)
        }
    }
    
    private func makeMarker(lat: Double, lng: Double, name: String, isSelected: Bool, stationInfo: PosStation) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: lat, lng: lng)
        marker.userInfo = ["stationInfo": stationInfo]
        marker.captionText = name
        marker.mapView = mapView
        
        if isSelected {
            marker.width = selectedMarkerWidth
            showInfoView()
            updateInfoView(marker)
        } else {
            marker.width = unselectedMarkerWidth
        }
        marker.height = marker.width * 1.6
        
        markerTouchHandler(marker)
        markers.append(marker)
    }
    
    // TODO: - 마커 선택여부에 따라 이미지 변경
    private func markerTouchHandler(_ marker: NMFMarker) {
        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            self.setDefaultAllMarkers()
            if let marker = overlay as? NMFMarker {
                if marker.width == self.unselectedMarkerWidth {
                    marker.width = self.selectedMarkerWidth
                    self.showInfoView()
                    self.updateInfoView(marker)
                }
                
                marker.height = marker.width * 1.6
                
                if let stationInfo = marker.userInfo["stationInfo"] as? PosStation {
                    if let gpsY = stationInfo.gpsY,
                       let gpsX = stationInfo.gpsX {
                        self.cameraUpdate(latStr: gpsY, lngStr: gpsX, isAnimation: true)
                    }
                }
            }
            return true
        };
    }
    
    private func removeAllMarker() {
        markers.forEach { marker in
            marker.mapView = nil
        }
    }
    
    private func setDefaultAllMarkers() {
        markers.forEach { marker in
            marker.width = unselectedMarkerWidth
            marker.height = marker.width * 1.6
        }
    }
    
    // MARK: - InfoView
    private func setupInfoView() {
        infoView.layer.shadowRadius = 0.5
        infoView.layer.shadowOpacity = 0.5
        infoView.layer.shadowColor = UIColor.gray.cgColor
        infoView.layer.shadowOffset = CGSize(width: 0, height: -1)
        
        hideInfoView()
    }
    
    private func updateInfoView(_ marker: NMFMarker) {
        guard let stationInfo = marker.userInfo["stationInfo"] as? PosStation,
              let stationNm = stationInfo.stationNm,
              let arsId = stationInfo.arsId else { return }
        infoViewTitleLabel.text = stationNm
        infoViewSubTitleLabel.text = arsId
    }
    
    private func hideInfoView() {
        infoView.subviews.forEach { content in
            content.isHidden = true
        }
        UIView.animate(withDuration: 0.2) {
            self.infoViewHeight.constant = 0
            self.infoView.layoutIfNeeded()
            self.mapView.layoutIfNeeded()
        }
    }
    
    private func showInfoView() {
        infoView.subviews.forEach { content in
            content.isHidden = false
        }
        UIView.animate(withDuration: 0.2) {
            self.infoViewHeight.constant = 100
            self.infoView.layoutIfNeeded()
            self.mapView.layoutIfNeeded()
        }
    }
    
    
    // MARK: - API Request
    private func getStationByNameList() {
        guard let stationName = stationName else { return }
        self.showLoading()
        Task {
            do {
                let response = try await BusAPI.shared.getStationByNameList(stationName)
                if let items = response.msgBody?.itemList {
                    self.stations = items
                    self.setupSelectedMarker()
                    self.getStationByPos()
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func getStationByPos() {
        self.showLoading()
        Task {
            do {
                guard let selectStation = selectStation,
                      let tmY = selectStation.tmY,
                      let tmX = selectStation.tmX else { return }
                let response = try await BusAPI.shared.getStationByPos(tmX: tmX, tmY: tmY)
                print(response)
                if let msgBody = response.msgBody,
                   let itemList = msgBody.itemList {
                    self.makeAroundMarker(itemList)
                    self.cameraUpdate(latStr: tmY, lngStr: tmX, isAnimation: false)
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    // MARK: - Tap Event
    @IBAction func infoViewClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
        guard let arsId = infoViewSubTitleLabel.text,
              let stationNm = infoViewTitleLabel.text else { return }
        vc.arsId = arsId
        vc.stationNm = stationNm
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        setDefaultAllMarkers()
        hideInfoView()
    }
}
