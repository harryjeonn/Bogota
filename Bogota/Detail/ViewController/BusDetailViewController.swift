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
    @IBOutlet weak var addFavoriteButton: UIButton!
    @IBOutlet weak var addFavoriteTitleButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareTitleButton: UIButton!
    
    var busInfo: LowBusInfo?
    var arsId: String?
    var busRoute: BusRoute?
    var busRouteId: String?
    private var routes = [RouteInfo]()
    private var busPositions = [BusPosition]()
    private var saveFavorite: FavoriteModel?
    private var isFavorite = false
    private var isShareMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let busInfo = busInfo {
            busRouteId = busInfo.busRouteId
        }
        setupUI()
        setupTableView()
        getStationByRoute()
        getBusPosByRtidList()
        updateBusInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkFavorite()
        AdmobManager.shared.addAdmobView(.bus)
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
        refreshButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor.gray.cgColor
        
        addFavoriteButton.setTitle("", for: .normal)
        addFavoriteButton.backgroundColor = .white
        addFavoriteButton.layer.cornerRadius = addFavoriteButton.frame.width / 2
        addFavoriteButton.addShadow(radius: 2, opacity: 0.5, width: 0, height: 0)
        
        addFavoriteTitleButton.setTitle("즐겨찾기", for: .normal)
        addFavoriteTitleButton.tintColor = .gray
        
        shareButton.setTitle("", for: .normal)
        shareButton.tintColor = .black
        shareButton.backgroundColor = .white
        shareButton.layer.cornerRadius = shareButton.frame.width / 2
        shareButton.addShadow(radius: 2, opacity: 0.5, width: 0, height: 0)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        shareTitleButton.setTitle("공유", for: .normal)
        shareTitleButton.tintColor = .gray
    }
    
    private func checkFavorite() {
        saveFavorite = FavoriteModel(type: .bus, stationName: nil, arsId: nil, busRoute: busRoute, busInfo: busInfo)
        if Favorite.shared.checkContains(saveFavorite!) {
            isFavorite = true
            addFavoriteButton.setImage(UIImage(named: "icon_favorite"), for: .normal)
        } else {
            isFavorite = false
            addFavoriteButton.setImage(UIImage(named: "tabbar_favorite"), for: .normal)
        }
    }
    
    private func updateBusInfo() {
        if let busInfo = busInfo {
            if let rtNm = busInfo.rtNm {
                busNumerLabel.text = rtNm
            }
            
            if let adirection = busInfo.adirection {
                directionLabel.text = "\(adirection) 방향"
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
        } else if let busRoute = busRoute {
            if let rtNm = busRoute.busRouteNm {
                busNumerLabel.text = rtNm
            }
            
            if let edStationNm = busRoute.edStationNm,
               let stStationNm = busRoute.stStationNm {
                directionLabel.text = "\(edStationNm) <-> \(stStationNm)"
            }
            
            if let routeType = busRoute.routeType {
                busTypeLabel.text = Route.shared.convertRouteType(routeType).title()
                busTypeLabel.backgroundColor = Route.shared.convertRouteType(routeType).color()
            }
            
            if var firstTime = busRoute.firstBusTm,
               var lastTime = busRoute.lastLowTm {
                let startIndex = firstTime.index(firstTime.startIndex, offsetBy: 8)
                let endIndex = firstTime.index(firstTime.startIndex, offsetBy: 11)
                firstTime = String(firstTime[startIndex...endIndex])
                lastTime = String(lastTime[startIndex...endIndex])
                
                let insertIndex = firstTime.index(firstTime.startIndex, offsetBy: 2)
                firstTime.insert(":", at: insertIndex)
                lastTime.insert(":", at: insertIndex)
                busTimeLabel.text = "운행시간 \(firstTime) ~ \(lastTime)"
            }
            
            if let term = busRoute.term {
                intervalLabel.text = "배차간격 \(term)분"
            }
        }
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        
        let nib = UINib(nibName: "BusRouteCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BusRouteCell")
    }
    
    private func getStationByRoute() {
        self.showLoading()
        
        Task {
            do {
                guard let busRouteId = busRouteId else { return }
                if let response = try await BusAPI.shared.getStationByRoute(busRouteId) {
                    self.routes = response
                    self.tableView.reloadData()
                    self.moveScroll()
                }
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
                guard let busRouteId = busRouteId else { return }
                if let response = try await BusAPI.shared.getBusPosByRtidList(busRouteId) {
                    self.busPositions = response
                    self.tableView.reloadData()
                }
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
                row = index - 2
                let indexPath = IndexPath(row: row, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                return
            }
        }
    }
    
    private func updateArrMsg(_ response: [LowBusInfo]) {
        response.forEach { item in
            if item.busRouteId == busInfo?.busRouteId {
                self.busInfo = item
            }
        }
        tableView.reloadData()
    }
    
    private func shareInfomation(_ text: String) {
        let shareItems = [text]
        
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    private func changeShareMode() {
        isShareMode = !isShareMode
        tableView.reloadData()
    }
    
    private func getCurrentTime() -> String {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a HH시 mm분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateStr = dateFormatter.string(from: nowDate)
        
        return dateStr
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getBusPosByRtidList()
        guard let arsId = arsId else { return }
        self.showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getLowStationByUidList(arsId) {
                    updateArrMsg(response)
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    @IBAction func addFavoriteButtonClicked(_ sender: Any) {
        guard let saveFavorite = saveFavorite else { return }
        if isFavorite {
            Favorite.shared.deleteFavorite(saveFavorite)
            addFavoriteButton.setImage(UIImage(named: "tabbar_favorite"), for: .normal)
            self.showCommonPopupView(title: "해제 완료", desc: "즐겨찾기 해제되었습니다.")
        } else {
            Favorite.shared.saveFavorite(saveFavorite)
            addFavoriteButton.setImage(UIImage(named: "icon_favorite"), for: .normal)
            self.showCommonPopupView(title: "추가 완료", desc: "즐겨찾기에 추가되었습니다.")
        }
        isFavorite = !isFavorite
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        if isShareMode {
            shareButton.backgroundColor = .white
            self.showCommonPopupView(title: "공유 취소", desc: "공유를 취소하였습니다.")
        } else {
            shareButton.backgroundColor = .blueColor.withAlphaComponent(0.5)
            self.showCommonPopupView(title: "공유", desc: "공유할 버스를 선택해주세요.")
        }
        
        changeShareMode()
    }
}

extension BusDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = routes[indexPath.row]
        guard let arsId = route.arsId,
              let stationNm = route.stationNm else { return }
        
        if isShareMode {
            busPositions.forEach { busPosition in
                if busPosition.busType == "1" && busPosition.lastStnId == route.station {
                    if let busNumber = busNumerLabel.text,
                       let busType = busTypeLabel.text,
                       let plainNo = busPosition.plainNo {
                        let text = "[보고타]\n\n\(busNumber)번 \(busType)버스를 공유했습니다.\n\n버스 위치: \(stationNm)(\(arsId))\n차량 번호: \(plainNo)\n공유 시간: \(self.getCurrentTime())"
                        
                        self.shareInfomation(text)
                        
                    } else {
                        self.showCommonPopupView(title: "공유 실패", desc: "공유에 실패하였습니다.")
                    }
                    self.changeShareMode()
                }
            }
        } else {
            let sb = UIStoryboard(name: "Detail", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
            vc.arsId = arsId
            vc.stationNm = stationNm
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusRouteCell") as? BusRouteCell else { return UITableViewCell() }
        
        cell.shareModeView.isHidden = !isShareMode
        
        let route = routes[indexPath.row]
        var busStartPoint: CGFloat = 0
        
        // 선택 정류장 셀
        if route.arsId == arsId {
            cell.backgroundColor = .skyColor
            cell.busImageView.backgroundColor = .skyColor
            if let firstArrMsg = busInfo?.arrmsg1 {
                cell.firstArrMsgLabel.text = Utils.shared.formatArrMsg(firstArrMsg)
            }
            
            if let secondArrMsg = busInfo?.arrmsg2 {
                cell.secondArrMsgLabel.text = Utils.shared.formatArrMsg(secondArrMsg)
            }
            cell.firstArrMsgLabel.isHidden = false
            cell.secondArrMsgLabel.isHidden = false
            cell.lineViewHeightConstraint.constant = 140
            tableView.estimatedRowHeight = 140
            busStartPoint = 70
        } else {
            cell.backgroundColor = .clear
            cell.firstArrMsgLabel.isHidden = true
            cell.secondArrMsgLabel.isHidden = true
            cell.lineViewHeightConstraint.constant = 80
            tableView.estimatedRowHeight = 80
        }
        
        // 각 정류장 이름과 정류장 번호
        cell.stationLabel.text = route.stationNm
        cell.stationIdLabel.text = route.arsId
        
        // 첫 정류장과 마지막 정류장 라인 디테일
        if routes.first == route {
            cell.lineViewHeightConstraint.constant /= 2
            cell.lineViewTopConstraint.constant = cell.lineViewHeightConstraint.constant
        } else if routes.last == route {
            cell.lineViewHeightConstraint.constant /= 2
            cell.lineViewBottomConstraint.constant = cell.lineViewHeightConstraint.constant
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
                if let fullSectDist = busPosition.fullSectDist,
                   let sectDist = busPosition.sectDist {
                    if (Float(fullSectDist)! / 2) <= Float(sectDist)! {
                        cell.busImageViewTopConstraint.constant = (busStartPoint / 2) + 55
                    } else {
                        cell.busImageViewTopConstraint.constant = (busStartPoint / 3) + 5
                    }
                }
                
                if let plainNo = busPosition.plainNo {
                    cell.busNumberLabel.text = "\(plainNo.suffix(4))"
                    
                }
                isBusHide = false
            }
        }
        
        cell.busImageView.isHidden = isBusHide
        cell.busNumberView.isHidden = isBusHide
        
        // 회차지
        if let trnstnid = route.trnstnid {
            if route.station == trnstnid {
                cell.downImageView.image = UIImage(systemName: "arrow.uturn.down")
                cell.downImageView.tintColor = .lightGray
                cell.downImageView.backgroundColor = .clear
                
                cell.downImageStackView.layer.cornerRadius = 5
                cell.downImageStackView.layer.borderWidth = 1
                cell.downImageStackView.layoutMargins = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
                
                cell.roundLabel.isHidden = false
            } else {
                cell.downImageView.image = UIImage(systemName: "chevron.down.circle.fill")
                cell.downImageView.tintColor = .white
                cell.downImageView.backgroundColor = .lightGray
                cell.downImageView.layer.cornerRadius = cell.downImageView.frame.width / 2
                
                cell.downImageStackView.layer.borderWidth = 0
                cell.downImageStackView.layer.cornerRadius = cell.downImageStackView.frame.width / 2
                cell.downImageStackView.layoutMargins = .zero
                
                cell.roundLabel.isHidden = true
            }
        }
        
        return cell
    }
}
