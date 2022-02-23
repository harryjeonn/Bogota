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
    @IBOutlet weak var showMapTitleButton: UIButton!
    @IBOutlet weak var addFavoriteButton: UIButton!
    @IBOutlet weak var addFavoriteTitleButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    private var busInfos = [LowBusInfo]()
    private let emptyView = EmptyView()
    private var saveFavorite: FavoriteModel?
    private var isFavorite = false
    
    var arsId = ""
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
        checkFavorite()
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
        directionLabel.text = ""
        
        showMapButton.setTitle("", for: .normal)
        showMapButton.setImage(UIImage(named: "tabbar_map"), for: .normal)
        showMapButton.backgroundColor = .white
        showMapButton.layer.cornerRadius = showMapButton.frame.width / 2
        showMapButton.addShadow(radius: 2, opacity: 0.5, width: 0, height: 0)
        
        showMapTitleButton.setTitle("지도", for: .normal)
        showMapTitleButton.tintColor = .gray
        
        addFavoriteButton.setTitle("", for: .normal)
        addFavoriteButton.backgroundColor = .white
        addFavoriteButton.layer.cornerRadius = addFavoriteButton.frame.width / 2
        addFavoriteButton.addShadow(radius: 2, opacity: 0.5, width: 0, height: 0)
        
        addFavoriteTitleButton.setTitle("즐겨찾기", for: .normal)
        addFavoriteTitleButton.tintColor = .gray
        
        refreshButton.backgroundColor = .white
        refreshButton.tintColor = .black
        refreshButton.layer.cornerRadius = refreshButton.frame.width / 2
        refreshButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor.gray.cgColor
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // emptyView
        emptyView.bounds = tableView.bounds
        emptyView.emptyLabel.text = "버스 정보가 없습니다."
        tableView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func setupInfo() {
        ardIdLabel.text = "\(arsId)"
        stationNameLabel.text = stationNm
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "BusInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BusInfoCell")
    }
    
    private func checkFavorite() {
        saveFavorite = FavoriteModel(type: .station, stationName: stationNm, arsId: arsId, busRoute: nil)
        if Favorite.shared.checkContains(saveFavorite!) {
            isFavorite = true
            addFavoriteButton.setImage(UIImage(named: "icon_favorite"), for: .normal)
        } else {
            isFavorite = false
            addFavoriteButton.setImage(UIImage(named: "tabbar_favorite"), for: .normal)
        }
    }
    
    private func updateInfo() {
//        if let sectNm = busInfos.last?.sectNm,
//           let findIndex: String.Index = sectNm.firstIndex(of: "~") {
//            directionLabel.text = "\(sectNm[...sectNm.index(before: findIndex)]) 방면"
//        } else {
//            directionLabel.text = ""
//        }
        // TODO: - 진행방향 찾아서 수정 필요
        directionLabel.text = ""
    }
    
    private func updateTableView(_ response: LowStationByUidResponse) {
        if let msgBody = response.msgBody,
           let itemList = msgBody.itemList {
            busInfos = itemList.filter({ $0.arsId != "0" })
            tableView.reloadData()
        }
        
        emptyView.isHidden = !busInfos.isEmpty
    }
    
    private func getStationDetail() {
        showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getLowStationByUidList(arsId) {
                    self.busInfos = response.filter({ $0.arsId != "0" })
                    self.tableView.reloadData()
                    emptyView.isHidden = !busInfos.isEmpty
                    self.updateInfo()
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }

    }

    @IBAction func showMapButtonClicked(_ sender: Any) {
        
        // TabBarController에서 원하는 ViewController 가져오기
        guard let tabBarController = tabBarController,
              let viewControllers = tabBarController.viewControllers,
              let naviVC = viewControllers[1] as? UINavigationController,
              let vc = naviVC.viewControllers.first as? MapViewController else { return }
        
        vc.arsId = arsId
        vc.stationName = self.stationNm
        
        // 지도 탭으로 이동
        self.tabBarController?.selectedIndex = 1
        
        // 지도 탭에 있을 때 화면전환
        if let topVC = Utils.shared.topViewController(),
           topVC is MapViewController == false {
            topVC.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getStationDetail()
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
            cell.firstArrMsgLabel.text = Utils.shared.formatArrMsg(firstArrMsg)
        }
        
        if let secondArrMsg = busInfo.arrmsg2 {
            cell.secondArrMsgLabel.text = Utils.shared.formatArrMsg(secondArrMsg)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busInfo = busInfos[indexPath.row]
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusDetailViewController") as? BusDetailViewController else { return }
        vc.busInfo = busInfo
        vc.arsId = arsId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
