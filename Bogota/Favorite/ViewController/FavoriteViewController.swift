//
//  FavoriteViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/02/23.
//

import UIKit

class FavoriteViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var favorites: [FavoriteModel]?
    private let emptyView = EmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = self.searchBarView
        favorites = Favorite.shared.loadFavorite()
        tableView.reloadData()
        
        if let favorites = favorites {
            emptyView.isHidden = !favorites.isEmpty
        } else {
            emptyView.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let stationNib = UINib(nibName: "HomeStationCell", bundle: nil)
        tableView.register(stationNib, forCellReuseIdentifier: "HomeStationCell")
        let busNib = UINib(nibName: "SearchBusCell", bundle: nil)
        tableView.register(busNib, forCellReuseIdentifier: "SearchBusCell")
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupUI() {
        emptyView.bounds = tableView.bounds
        emptyView.emptyLabel.text = "즐겨찾기가 없습니다."
        tableView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        label.text = "즐겨찾기"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let favorites = favorites else { return 0 }
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let favorites = favorites else { return UITableViewCell() }
        let favorite = favorites[indexPath.row]
        
        switch favorite.type {
        case .station:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
            if let stationName = favorite.stationName {
                cell.titleLabel.text = stationName
            }
            
            if let arsId = favorite.arsId {
                cell.subTitleLabel.text = "\(arsId)"
            }
            
            return cell
            
        case .bus:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBusCell") as? SearchBusCell else { return UITableViewCell() }
            if let busRoute = favorite.busRoute {
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
                
            } else if let busInfo = favorite.busInfo {
                if let rtNm = busInfo.rtNm {
                    cell.titleLabel.text = rtNm
                }
                
                if let adirection = busInfo.adirection {
                    cell.directionLabel.text = "\(adirection) 방향"
                }
                
                if let routeType = busInfo.routeType {
                    cell.typeLabel.text = Route.shared.convertRouteType(routeType).title()
                    cell.typeLabel.backgroundColor = Route.shared.convertRouteType(routeType).color()
                }
                
                if let term = busInfo.term {
                    cell.idLabel.text = "배차간격 \(term)분"
                }
                
                return cell
            } else {
                return UITableViewCell()
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let favorites = favorites else { return }
        let favorite = favorites[indexPath.row]
        
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        switch favorite.type {
        case .station:
            guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
            if let stationName = favorite.stationName,
               let arsId = favorite.arsId {
                vc.stationNm = stationName
                vc.arsId = arsId
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .bus:
            guard let vc = sb.instantiateViewController(withIdentifier: "BusDetailViewController") as? BusDetailViewController else { return }
            
            if let busRoute = favorite.busRoute,
               let busRouteId = busRoute.busRouteId {
                vc.busRoute = busRoute
                vc.busRouteId = busRouteId
            } else if let busInfo = favorite.busInfo,
                      let arsId = busInfo.arsId {
                vc.busInfo = busInfo
                vc.arsId = arsId
            }
            
            Utils.shared.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favorites!.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: "favorite")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
