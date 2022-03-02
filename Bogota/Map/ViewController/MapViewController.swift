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
    @IBOutlet weak var searchAroundButton: UIButton!
    @IBOutlet weak var goMyLocationButton: UIButton!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var searchCameraButton: UIButton!
    
    private var locationManager = LocationManager.shared
    
    private var stations = [NameStation]()
    private var selectStation: NameStation?
    private var markers = [NMFMarker]()
    private var selectedMarkerWidth: CGFloat = 40
    private var unselectedMarkerWidth: CGFloat = 30
    
    private var pickerView = UIPickerView()
    private var pickerViewList = ["100", "300", "500", "1000"]
    
    var stationName: String?
    var arsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupPickerView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        getStationByNameList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stationName = nil
        arsId = nil
    }
    
    private func setupUI() {
        setupInfoView()
        
        // 주변 정류장 버튼
        searchAroundButton.backgroundColor = .white
        searchAroundButton.layer.cornerRadius = 10
        searchAroundButton.setTitle("내 주변 정류장", for: .normal)
        searchAroundButton.titleLabel?.font = .systemFont(ofSize: 14)
        searchAroundButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
        searchAroundButton.layer.borderWidth = 0.5
        searchAroundButton.layer.borderColor = UIColor.gray.cgColor
        searchAroundButton.tintColor = .blueColor
        
        // 카메라 기준 주변 정류장 버튼
        searchCameraButton.backgroundColor = .white
        searchCameraButton.layer.cornerRadius = 10
        searchCameraButton.setTitle("현 지도 정류장", for: .normal)
        searchCameraButton.titleLabel?.font = .systemFont(ofSize: 14)
        searchCameraButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
        searchCameraButton.layer.borderWidth = 0.5
        searchCameraButton.layer.borderColor = UIColor.gray.cgColor
        searchCameraButton.tintColor = .blueColor
        
        // 내 위치 버튼
        goMyLocationButton.backgroundColor = .white
        goMyLocationButton.layer.cornerRadius = goMyLocationButton.frame.width / 2
        goMyLocationButton.setTitle("", for: .normal)
        goMyLocationButton.setImage(UIImage(systemName: "location.north.fill"), for: .normal)
        goMyLocationButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
        goMyLocationButton.layer.borderWidth = 0.5
        goMyLocationButton.layer.borderColor = UIColor.gray.cgColor
        goMyLocationButton.tintColor = .blueColor
        
        distanceTextField.backgroundColor = .white
        distanceTextField.layer.cornerRadius = 10
        distanceTextField.layer.shadowRadius = 1
        distanceTextField.layer.shadowOpacity = 0.5
        distanceTextField.layer.shadowColor = UIColor.gray.cgColor
        distanceTextField.layer.shadowOffset = CGSize(width: 1, height: 1)
        distanceTextField.layer.borderWidth = 0.5
        distanceTextField.layer.borderColor = UIColor.gray.cgColor
        distanceTextField.tintColor = .clear
        distanceTextField.inputView = pickerView
        distanceTextField.textAlignment = .center
        distanceTextField.textColor = .blueColor
        distanceTextField.font = .systemFont(ofSize: 14)
//        distanceTextField.text = "\(pickerViewList[2])m"
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = self.searchBarView
    }
    
    // MARK: - Map
    private func setupMapView() {
        guard let coord = getCurrentCoord() else { return }
        
        mapView.latitude = coord.latitude
        mapView.longitude = coord.longitude
        mapView.zoomLevel = 16
        
        mapView.positionMode = .direction
        
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
    }
    
    private func cameraUpdate(latStr: String, lngStr: String, isAnimation: Bool) {
        guard let lat = Double(latStr),
              let lng = Double(lngStr) else { return }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        if isAnimation {
            cameraUpdate.animation = .easeIn
        }
        
        mapView.moveCamera(cameraUpdate)
    }
    
    private func getCurrentCoord() -> CLLocationCoordinate2D? {
        guard let coord = locationManager.locManager.location?.coordinate else {
            print("Error: Can not load location")
            self.showCommonPopupView(title: "위치정보", desc: "위치정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            return nil
        }
        return coord
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
            marker.iconImage = NMFOverlayImage(name: "icon_selected_station")
            showInfoView()
            updateInfoView(marker)
        } else {
            marker.width = unselectedMarkerWidth
            marker.iconImage = NMFOverlayImage(name: "icon_unselected_station")
        }
        marker.height = marker.width
        
        markerTouchHandler(marker)
        markers.append(marker)
    }
    
    private func markerTouchHandler(_ marker: NMFMarker) {
        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            self.setDefaultAllMarkers()
            if let marker = overlay as? NMFMarker {
                if marker.width == self.unselectedMarkerWidth {
                    marker.width = self.selectedMarkerWidth
                    marker.iconImage = NMFOverlayImage(name: "icon_selected_station")
                    self.showInfoView()
                    self.updateInfoView(marker)
                } else {
                    marker.width = self.unselectedMarkerWidth
                    marker.iconImage = NMFOverlayImage(name: "icon_unselected_station")
                }
                marker.height = marker.width
                
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
            marker.iconImage = NMFOverlayImage(name: "icon_unselected_station")
            marker.height = marker.width
        }
    }
    
    // MARK: - InfoView
    private func setupInfoView() {
        infoView.layer.shadowRadius = 0.5
        infoView.layer.shadowOpacity = 0.5
        infoView.layer.shadowColor = UIColor.gray.cgColor
        infoView.layer.shadowOffset = CGSize(width: 0, height: -1)
        
        infoViewSubTitleLabel.textColor = .gray
        
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
                if let response = try await BusAPI.shared.getStationByNameList(stationName) {
                    self.stations = response
                    self.setupSelectedMarker()
                    
                    guard let selectStation = selectStation,
                          let tmY = selectStation.tmY,
                          let tmX = selectStation.tmX else { return }
                    self.getStationByPos(tmX: tmX, tmY: tmY)
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func getStationByPos(tmX: String, tmY: String) {
        self.showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getStationByPos(tmX: tmX, tmY: tmY, radius: getSelectDistance()) {
                    self.makeAroundMarker(response.filter({ $0.arsId != "0" }))
                    self.cameraUpdate(latStr: tmY, lngStr: tmX, isAnimation: false)
                } else {
                    self.removeAllMarker()
                    self.showCommonPopupView(title: "검색 실패", desc: "검색 범위 내 정류장이 없습니다.")
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    // MARK: - PickerView
    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.tintColor = .blueColor
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 45)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace, createToolBarButtonItem()], animated: true)
        
        distanceTextField.inputAccessoryView = toolbar
        
        pickerView.selectRow(2, inComponent: 0, animated: true)
        distanceTextField.text = "\(getSelectDistance())m"
    }
    
    private func createToolBarButtonItem() -> UIBarButtonItem {
        let doneButton = UIBarButtonItem()
        doneButton.title = "완료"
        doneButton.target = self
        doneButton.action = #selector(doneButtonClicked)
        
        return doneButton
    }
    
    private func getSelectDistance() -> String {
        let selectItem = pickerView.selectedRow(inComponent: 0)
        pickerView.selectRow(selectItem, inComponent: 0, animated: true)
        
        return pickerViewList[selectItem]
    }
    
    @objc private func doneButtonClicked() {
        let distance = getSelectDistance()
        
        if distance == "1000" {
            distanceTextField.text = "1km"
        } else {
            distanceTextField.text = "\(distance)m"
        }
        self.view.endEditing(true)
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
    
    @IBAction func searchAroundButtonClicked(_ sender: Any) {
        guard let coord = getCurrentCoord() else { return }
        let tmX = String(format: "%.8f", coord.longitude)
        let tmY = String(format: "%.8f", coord.latitude)
        
        getStationByPos(tmX: tmX, tmY: tmY)
    }
    
    @IBAction func goMyLocationButtonClicked(_ sender: Any) {
        guard let coord = getCurrentCoord() else { return }
        cameraUpdate(latStr: "\(coord.latitude)", lngStr: "\(coord.longitude)", isAnimation: true)
        goMyLocationButton.tintColor = .blueColor
    }
    
    @IBAction func searchCameraButtonClicked(_ sender: Any) {
        let tmX = String(format: "%.8f", mapView.cameraPosition.target.lng)
        let tmY = String(format: "%.8f", mapView.cameraPosition.target.lat)
        
        getStationByPos(tmX: tmX, tmY: tmY)
    }
}

extension MapViewController: NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        setDefaultAllMarkers()
        hideInfoView()
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard let coord = getCurrentCoord() else { return }
        
        let mapViewLat = String(format: "%.4f", mapView.cameraPosition.target.lat)
        let mapViewLng = String(format: "%.4f", mapView.cameraPosition.target.lng)
        let currentLat = String(format: "%.4f", coord.latitude)
        let currentLng = String(format: "%.4f", coord.longitude)
        
        if mapViewLat != currentLat && mapViewLng != currentLng {
            goMyLocationButton.tintColor = .lightGray
        }
    }
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerViewList[row] == "1000" {
            return "1km"
        } else {
            return "\(pickerViewList[row])m"
        }
    }
}
