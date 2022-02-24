//
//  SearchViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/02/11.
//

import UIKit

class SearchViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var keyword: String?
    var searchType: SearchType?
    
    private var nameStations = [NameStation]()
    private var arsIdStations = [LowBusInfo]()
    private var busRoutes = [BusRoute]()
    private let emptyView = EmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "검색결과"
    }
    
    private func getInfo() {
        switch searchType {
        case .station:
            getStationByNameList()
            getLowStationByUidList()
            let nib = UINib(nibName: "HomeStationCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "HomeStationCell")
        case .bus:
            let nib = UINib(nibName: "SearchBusCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "SearchBusCell")
            getBusRouteList()
        default:
            break
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // emptyView
        emptyView.bounds = tableView.bounds
        emptyView.emptyLabel.text = "검색결과가 없습니다."
        tableView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func getLowStationByUidList() {
        guard let keyword = keyword else { return }
        self.showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getLowStationByUidList(keyword) {
                    arsIdStations = filteredItemList(response)
                    emptyView.isHidden = true
                    tableView.reloadData()
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func filteredItemList(_ itemList: [LowBusInfo]) -> [LowBusInfo] {
        var filteredItemList = [LowBusInfo]()
        itemList.forEach { item in
            if !filteredItemList.contains(where: { $0.stnNm == item.stnNm }) {
                filteredItemList.append(item)
            }
        }
        return filteredItemList.filter({ $0.arsId != "0" })
    }
    
    private func getBusRouteList() {
        guard let keyword = keyword else { return }
        self.showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getBusRouteList(keyword) {
                    busRoutes = response
                    emptyView.isHidden = true
                    tableView.reloadData()
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func getStationByNameList() {
        guard let keyword = keyword else { return }
        self.showLoading()
        Task {
            do {
                if let response = try await BusAPI.shared.getStationByNameList(keyword) {
                    nameStations = response.filter({ $0.arsId != "0" })
                    emptyView.isHidden = true
                    tableView.reloadData()
                }
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func saveHistory(_ saveHistory: SearchHistoryModel) {
        if let searchHistoryData = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
            let searchHistories = try? PropertyListDecoder().decode([SearchHistoryModel].self, from: searchHistoryData)
            guard let newHistories = createHistories(saveHistory: saveHistory, searchHistories: searchHistories) else { return }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newHistories), forKey: "searchHistory")
        } else {
            let searchHistories = [saveHistory]
            UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistories), forKey: "searchHistory")
        }
    }
    
    private func createHistories(saveHistory: SearchHistoryModel, searchHistories: [SearchHistoryModel]?) -> [SearchHistoryModel]? {
        guard var searchHistories = searchHistories else { return nil }
        
        searchHistories.enumerated().forEach { index, searchHistory in
            if saveHistory.type == .station && saveHistory.arsId == searchHistory.arsId && saveHistory.stationName == searchHistory.stationName {
                searchHistories.remove(at: index)
            } else if saveHistory.type == .bus && saveHistory.busRoute?.busRouteId == searchHistory.busRoute?.busRouteId {
                searchHistories.remove(at: index)
            }
        }
        
        searchHistories.insert(saveHistory, at: 0)
        
        return searchHistories
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if nameStations.isEmpty == false {
            count += 1
        }

        if busRoutes.isEmpty == false {
            count += 1
        }
        
        if arsIdStations.isEmpty == false {
            count += 1
        }

        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        label.text = searchType?.headerTitle()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchType {
        case .station:
            var count = 0
            if nameStations.isEmpty {
                count = arsIdStations.count
            } else if arsIdStations.isEmpty {
                count = nameStations.count
            }
            
            return count
        case .bus:
            return busRoutes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tap
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        
        switch searchType {
        case .station:
            guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
            
            var stNm: String?
            var arsId: String?
            
            if nameStations.isEmpty {
                let arsIdStation = arsIdStations[indexPath.row]
                stNm = arsIdStation.stnNm
                arsId = arsIdStation.arsId
            } else if arsIdStations.isEmpty {
                let nameStation = nameStations[indexPath.row]
                stNm = nameStation.stNm
                arsId = nameStation.arsId
            }
            
            if let stNm = stNm,
               let arsId = arsId {
                vc.stationNm = stNm
                vc.arsId = arsId
            }
            
            let saveModel = SearchHistoryModel(type: .station, stationName: stNm, arsId: arsId, busRoute: nil)
            saveHistory(saveModel)
            
            self.navigationController?.pushViewController(vc, animated: true)
        case .bus:
            let busRoute = busRoutes[indexPath.row]
            
            let saveModel = SearchHistoryModel(type: .bus, stationName: nil, arsId: nil, busRoute: busRoute)
            saveHistory(saveModel)
            
            guard let vc = sb.instantiateViewController(withIdentifier: "BusDetailViewController") as? BusDetailViewController else { return }
            vc.busRoute = busRoute
            vc.busRouteId = busRoute.busRouteId
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchType {
        case .station:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
            
            var stNm: String?
            var arsId: String?
            
            if nameStations.isEmpty {
                let arsIdStation = arsIdStations[indexPath.row]
                stNm = arsIdStation.stnNm
                arsId = arsIdStation.arsId
            } else if arsIdStations.isEmpty {
                let nameStation = nameStations[indexPath.row]
                stNm = nameStation.stNm
                arsId = nameStation.arsId
            }
            
            cell.titleLabel.text = stNm
            cell.subTitleLabel.text = arsId
            
            return cell
        case .bus:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBusCell") as? SearchBusCell else { return UITableViewCell() }
            
            let busRoute = busRoutes[indexPath.row]
            
            if let routeType = busRoute.routeType {
                cell.typeLabel.text = Route.shared.convertRouteType(routeType).title()
                cell.typeLabel.backgroundColor = Route.shared.convertRouteType(routeType).color()
            }
            
            cell.titleLabel.text = busRoute.busRouteNm
            
            if let edStationNm = busRoute.edStationNm,
               let stStationNm = busRoute.stStationNm {
                cell.directionLabel.text = "\(edStationNm) <-> \(stStationNm)"
            } else {
                cell.directionLabel.text = ""
            }
            
            if let term = busRoute.term {
                cell.idLabel.text = "배차간격 \(term)분"
            } else {
                cell.idLabel.text = ""
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}
