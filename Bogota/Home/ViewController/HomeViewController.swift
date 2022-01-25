//
//  HomeViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit
import CoreLocation

class HomeViewController: BaseViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var locationManager = CLLocationManager()
    
    private var testStationList = [String]()
    private var stations = [Station]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentLocation()
        setupTableView()
        setupTabbar()
        setupUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStationByPos()
    }
    
    private func setupTabbar() {
        // TabBar 색상 설정
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    }
    
    private func setupUI() {
        // TextField
        searchTextField.layer.cornerRadius = 10
        searchTextField.placeholder = "정류장 검색"
        
        // Button
        searchButton.setImage(UIImage(named: "btn_search"), for: .normal)
        
        // TableView
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HomeStationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeStationCell")
    }
    
    private func setupGestures() {
        // 키보드 숨김 제스처
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // tableView cell event 못 받기 때문에 false 설정
        tap.cancelsTouchesInView = false
    }
    
    private func updateTableView(_ response: StationByPosResponse) {
        guard let msgBody = response.msgBody,
              let itemList = msgBody.itemList else { return }
        
        stations = itemList
        tableView.reloadData()
    }
    
    private func getCurrentLocation() {
        // Delegate 설정
        locationManager.delegate = self
        // 거리 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 권한 허용 팝업
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // 위치 서비스 On
            
            // 위치 업데이트 시작
            locationManager.startUpdatingLocation()
        } else {
            // 위치 서비스 Off
        }
    }
    
    private func getStationByPos() {
        guard let lat = locationManager.location?.coordinate.latitude,
              let lon = locationManager.location?.coordinate.longitude else {
                  print("Error: Can not load location")
                  return
              }
        let tmX = String(format: "%.8f", lon)
        let tmY = String(format: "%.8f", lat)
        showLoading()
        Task {
            do {
                let response = try await BusAPI.shared.getStationByPos(tmX: tmX, tmY: tmY)
                self.updateTableView(response)
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    // MARK: - Button event
    @IBAction func searchButtonClicked(_ sender: Any) {
        print("Clicked search button")
        // TODO: 정류소 검색
        // 정류소 이름이나 ID 가지고 정류소 검색
        // 위치정보와 정류소 지나는 버스 정보 필요
        // 화면 전환
        
        // test code
        if let text = searchTextField.text,
           text != "" {
            testStationList.append(text)
            searchTextField.text = nil
        }
        
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
        let station = stations[indexPath.row]
        
        if let stationNm = station.stationNm {
            cell.titleLabel.text = stationNm
        }
        
        if let arsId = station.arsId {
            cell.subTitleLabel.text = "\(arsId)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select cell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        label.text = "내 주변 정류장"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        
        headerView.addSubview(label)
        
        return headerView
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    // 위치 정보 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
