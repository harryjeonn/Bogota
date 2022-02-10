//
//  BusDetailViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/28.
//

import UIKit

class BusDetailViewController: BaseViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var busNumerLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var busTypeLabel: UILabel!
    @IBOutlet weak var busTimeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var intervalLabel: UILabel!
    
    var busInfo: LowBusInfo?
    var arsId: String?
    private var routes = [RouteInfo]()
    private var busPositions = [BusPosition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        getStationByRoute()
        getBusPosByRtidList()
        updateBusInfo()
    }
    
    private func setupUI() {
        contentView.layer.shadowRadius = 0.5
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        busNumerLabel.textAlignment = .center
        directionLabel.textAlignment = .center
        busTypeLabel.textAlignment = .center
        busTimeLabel.textAlignment = .center
        intervalLabel.textAlignment = .center
        
        busNumerLabel.text = ""
        directionLabel.text = ""
        busTypeLabel.text = ""
        busTimeLabel.text = ""
        intervalLabel.text = ""
        
        busNumerLabel.font = .systemFont(ofSize: 20)
        directionLabel.font = .systemFont(ofSize: 15)
        busTypeLabel.font = .systemFont(ofSize: 20)
        busTimeLabel.font = .systemFont(ofSize: 15)
        intervalLabel.font = .systemFont(ofSize: 15)
        
        busNumerLabel.textColor = .black
        directionLabel.textColor = .gray
        busTypeLabel.textColor = .white
        busTimeLabel.textColor = .gray
        intervalLabel.textColor = .gray
        
        busTypeLabel.clipsToBounds = true
        busTypeLabel.layer.cornerRadius = 5
        
        refreshButton.backgroundColor = .white
        refreshButton.tintColor = .black
        refreshButton.layer.cornerRadius = refreshButton.frame.width / 2
        refreshButton.layer.shadowRadius = 1
        refreshButton.layer.shadowOpacity = 0.5
        refreshButton.layer.shadowColor = UIColor.gray.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func updateBusInfo() {
        guard let busInfo = busInfo else { return }
        
        if let rtNm = busInfo.rtNm {
            busNumerLabel.text = rtNm
        }
        
        if let sectNm = busInfo.sectNm {
            directionLabel.text = "\(sectNm)"
        }
        
        if let routeType = busInfo.routeType {
            busTypeLabel.text = Route.shared.convertRouteType(routeType).title()
            busTypeLabel.backgroundColor = Route.shared.convertRouteType(routeType).color()
        }
        
        if var firstTime = busInfo.firstTm,
           var lastTime = busInfo.lastTm {
            let insertIndex = firstTime.index(firstTime.startIndex, offsetBy: 2)
            firstTime.insert(":", at: insertIndex)
            lastTime.insert(":", at: insertIndex)
            busTimeLabel.text = "운행시간 \(firstTime)~  \(lastTime)"
        }
        
        if let term = busInfo.term {
            intervalLabel.text = "배차간격 \(term)분"
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 80
        
        
        let nib = UINib(nibName: "BusRouteCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BusRouteCell")
    }
    
    private func getStationByRoute() {
        self.showLoading()
        
        Task {
            do {
                guard let busRouteId = busInfo?.busRouteId else { return }
                let response = try await BusAPI.shared.getStationByRoute(busRouteId)
                self.updateRoute(response)
                self.moveScroll()
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func getBusPosByRtidList() {
        self.showLoading()
        
        Task {
            do {
                guard let busRouteId = busInfo?.busRouteId else { return }
                let response = try await BusAPI.shared.getBusPosByRtidList(busRouteId)
                self.updateBusPosition(response)
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func moveScroll() {
        var row = 0
        routes.enumerated().forEach { index, route in
            if route.arsId == arsId {
                row = index - 3
                let indexPath = IndexPath(row: row, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                return
            }
        }
    }
    
    private func updateRoute(_ response: StationByRouteResponse) {
        if let msgBody = response.msgBody,
           let itemList = msgBody.itemList {
            routes = itemList
            tableView.reloadData()
        }
    }
    
    private func updateBusPosition(_ response: BusPosByRtidListResponse) {
        if let msgBody = response.msgBody,
           let itemList = msgBody.itemList {
            busPositions = itemList
            tableView.reloadData()
        }
    }
    
    private func updateArrMsg(_ response: LowStationByUidResponse) {
        if let msgBody = response.msgBody,
           let itemList = msgBody.itemList {
            itemList.forEach { item in
                if item.busRouteId == busInfo?.busRouteId {
                    self.busInfo = item
                }
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getBusPosByRtidList()
        guard let arsId = arsId else { return }
        self.showLoading()
        Task {
            do {
                let response = try await BusAPI.shared.getLowStationByUidList(arsId)
                updateArrMsg(response)
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
}

extension BusDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusRouteCell") as? BusRouteCell else { return UITableViewCell() }
        
        let route = routes[indexPath.row]
        
        // 선택 정류장 셀
        if route.arsId == arsId {
            cell.backgroundColor = .skyColor
            if let firstArrMsg = busInfo?.arrmsg1 {
                cell.firstArrMsgLabel.text = firstArrMsg
            }
            
            if let secondArrMsg = busInfo?.arrmsg2 {
                cell.secondArrMsgLabel.text = secondArrMsg
            }
            cell.firstArrMsgLabel.isHidden = false
            cell.secondArrMsgLabel.isHidden = false
        } else {
            cell.backgroundColor = .clear
            cell.firstArrMsgLabel.isHidden = true
            cell.secondArrMsgLabel.isHidden = true
        }
        
        // 각 정류장 이름과 정류장 번호
        cell.stationLabel.text = route.stationNm
        cell.stationIdLabel.text = route.arsId
        
        // 첫 정류장과 마지막 정류장 라인 디테일
        if routes.first == route {
            cell.lineViewTopConstraint.constant = 30
        } else if routes.last == route {
            cell.lineViewBottomConstraint.constant = 30
        } else {
            cell.lineViewTopConstraint.constant = 0
            cell.lineViewBottomConstraint.constant = 0
        }
        
        // 각 정류장 구간 별 속도 시각화
        if let sectSpd = route.sectSpd {
            if Int(sectSpd)! <= 10 {
                cell.lineView.backgroundColor = .redColor
            } else if Int(sectSpd)! <= 20 {
                cell.lineView.backgroundColor = .yellowColor
            } else {
                cell.lineView.backgroundColor = .greenColor
            }
        }
        
        // 버스 위치 표시
        var isBusHide = true
        busPositions.forEach { busPosition in
            if busPosition.busType == "1" && busPosition.lastStnId == route.station {
                isBusHide = false
            }
        }
        
        cell.busImageView.isHidden = isBusHide
        
        
        return cell
    }
}
