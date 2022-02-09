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
    @IBOutlet weak var refreshButton: UIButton!
    
    private var locationManager = LocationManager.shared
    
    private var posStations = [PosStation]()
    
    private let emptyView = EmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.getCurrentLocation()
        setupTableView()
        setupTabbar()
        setupUI()
        setupGestures()
        getStationByPos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    private func setupTabbar() {
        // TabBar 색상 설정
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.backgroundColor = .tabBarBgColor
    }
    
    private func setupUI() {
        // TextField
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 10
        searchTextField.placeholder = "정류장 검색"
        
        // Button
        searchButton.setImage(UIImage(named: "btn_search"), for: .normal)
        
        refreshButton.backgroundColor = .white
        refreshButton.tintColor = .black
        refreshButton.layer.cornerRadius = refreshButton.frame.width / 2
        refreshButton.layer.shadowRadius = 1
        refreshButton.layer.shadowOpacity = 0.5
        refreshButton.layer.shadowColor = UIColor.gray.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor.gray.cgColor
        
        // TableView
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // emptyView
        emptyView.bounds = tableView.bounds
        emptyView.emptyLabel.text = "정류장 정보가 없습니다."
        tableView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
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
        if let msgBody = response.msgBody,
           let itemList = msgBody.itemList {
            posStations = itemList
            tableView.reloadData()
        }
        
        emptyView.isHidden = !posStations.isEmpty
    }
    
    private func getStationByPos() {
        guard let lat = locationManager.locManager.location?.coordinate.latitude,
              let lon = locationManager.locManager.location?.coordinate.longitude else {
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
    
    private func didSearch() {
        if let text = searchTextField.text,
           text != "" {
            // Tab 이동하면서 검색 API 요청
            guard let tabBarController = tabBarController,
                  let viewControllers = tabBarController.viewControllers else { return }
            
            guard let vc = viewControllers[1] as? MapViewController else { return }
            vc.searchStationByName(text)
            self.tabBarController?.selectedIndex = 1
            searchTextField.text = nil
        } else {
            dismissKeyboard()
        }
    }
    
    // MARK: - Button event
    @IBAction func searchButtonClicked(_ sender: Any) {
        didSearch()
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getStationByPos()
    }
}

// MARK: - TableView Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
        let posStation = posStations[indexPath.row]
        
        if let stationNm = posStation.stationNm {
            cell.titleLabel.text = stationNm
        }
        
        if let arsId = posStation.arsId,
           let distance = posStation.dist {
            cell.subTitleLabel.text = "\(arsId) | \(distance)m"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select cell")
        guard let arsId = posStations[indexPath.row].arsId,
              let stationNm = posStations[indexPath.row].stationNm else { return }
        
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
        vc.arsId = arsId
        vc.stationNm = stationNm
        self.navigationController?.pushViewController(vc, animated: true)
        
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

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didSearch()
        return true
    }
}
