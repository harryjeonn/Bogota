//
//  StationDetailViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/27.
//

import UIKit

class StationDetailViewController: BaseViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ardIdLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var showMapButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    private var busInfos = [LowBusInfo]()
    
    var ardId = ""
    var stationNm = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        getStationDetail()
        setupUI()
        setupInfo()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupUI() {
        contentView.layer.shadowRadius = 0.5
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        stationNameLabel.font = .systemFont(ofSize: 20)
        
        ardIdLabel.textColor = .gray
        ardIdLabel.font = .systemFont(ofSize: 15)
        ardIdLabel.textAlignment = .center
        
        directionLabel.textColor = .gray
        directionLabel.font = .systemFont(ofSize: 17)
        directionLabel.textAlignment = .center
        
        showMapButton.setTitle("", for: .normal)
        showMapButton.setImage(UIImage(named: "tabbar_map"), for: .normal)
        showMapButton.backgroundColor = .white
        showMapButton.layer.cornerRadius = showMapButton.frame.width / 2
        showMapButton.layer.shadowRadius = 2
        showMapButton.layer.shadowOpacity = 0.5
        showMapButton.layer.shadowColor = UIColor.gray.cgColor
        showMapButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        refreshButton.backgroundColor = .white
        refreshButton.tintColor = .black
        refreshButton.layer.cornerRadius = refreshButton.frame.width / 2
        refreshButton.layer.shadowRadius = 1
        refreshButton.layer.shadowOpacity = 0.5
        refreshButton.layer.shadowColor = UIColor.gray.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor.gray.cgColor
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupInfo() {
        ardIdLabel.text = "\(ardId)"
        stationNameLabel.text = stationNm
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "BusInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BusInfoCell")
    }
    
    private func updateInfo() {
        if let sectNm = busInfos.last?.sectNm,
           let findIndex: String.Index = sectNm.firstIndex(of: "~") {
            directionLabel.text = "\(sectNm[...sectNm.index(before: findIndex)]) 방면"
        } else {
            directionLabel.text = ""
        }
    }
    
    private func updateTableView(_ response: LowStationByUidResponse) {
        guard let msgBody = response.msgBody,
              let itemList = msgBody.itemList else { return }
        
        busInfos = itemList
        tableView.reloadData()
    }
    
    private func getStationDetail() {
        showLoading()
        Task {
            do {
                let response = try await BusAPI.shared.getLowStationByUidList(ardId)
                print(response)
                self.updateTableView(response)
                self.updateInfo()
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }

    }

    @IBAction func showMapButtonClicked(_ sender: Any) {
        guard let tabBarController = tabBarController,
              let viewControllers = tabBarController.viewControllers else { return }
        
        guard let vc = viewControllers[1] as? MapViewController else { return }
        // TODO: - 화면 이동하면서 지도 중심 맞추기 (정류장 고유번호 사용)
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getStationDetail()
    }
}

extension StationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusInfoCell") as? BusInfoCell else { return UITableViewCell() }
        let busInfo = busInfos[indexPath.row]
        
        if let routeType = busInfo.routeType {
            cell.routeTypeLabel.text = Route.shared.convertRouteType(routeType).title()
            cell.routeTypeLabel.backgroundColor = Route.shared.convertRouteType(routeType).color()
        }
        
        if let routeName = busInfo.rtNm {
            cell.routeNameLabel.text = routeName
        }
        
        if let firstArrMsg = busInfo.arrmsg1 {
            cell.firstArrMsgLabel.text = firstArrMsg
        }
        
        if let secondArrMsg = busInfo.arrmsg2 {
            cell.secondArrMsgLabel.text = secondArrMsg
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - 버스 상세화면 진입
        let busInfo = busInfos[indexPath.row]
        
    }
}
