//
//  SearchGuideView.swift
//  bogota
//
//  Created by 전현성 on 2022/02/14.
//

import UIKit

protocol SearchGuideViewDelegate {
    func cellClicked(searchHistoryModel: SearchHistoryModel)
    func didScroll()
}

class SearchGuideView: UIView {
    @IBOutlet weak var stationButton: UIButton!
    @IBOutlet weak var busButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: SearchGuideViewDelegate?
    
    var isStation = true
    var searchHistories = [SearchHistoryModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        getSearchHistory()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("SearchGuideView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = .white
        setupUI()
        setupTableView()
        addSubview(view)
    }
    
    private func setupUI() {
        stationButton.layer.borderWidth = 2
        stationButton.layer.borderColor = UIColor.black.cgColor
        stationButton.layer.cornerRadius = 5
        stationButton.setTitle("정류장", for: .normal)
        stationButton.setTitleColor(.black, for: .normal)
        
        busButton.layer.borderWidth = 0
        busButton.layer.borderColor = UIColor.black.cgColor
        busButton.layer.cornerRadius = 5
        busButton.setTitle("버스", for: .normal)
        busButton.setTitleColor(.gray, for: .normal)
    }
    
    private func getSearchHistory() {
        if let searchHistoryData = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
            do {
                let history = try PropertyListDecoder().decode([SearchHistoryModel].self, from: searchHistoryData)
                searchHistories = history
                tableView.reloadData()
            } catch {
                print("Decode error : search history")
            }
        }
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
    
    @IBAction func stationButtonClicked(_ sender: Any) {
        isStation = true
        stationButton.layer.borderWidth = 2
        busButton.layer.borderWidth = 0
        stationButton.setTitleColor(.black, for: .normal)
        busButton.setTitleColor(.gray, for: .normal)
    }
    
    @IBAction func busButtonClicked(_ sender: Any) {
        isStation = false
        stationButton.layer.borderWidth = 0
        busButton.layer.borderWidth = 2
        stationButton.setTitleColor(.gray, for: .normal)
        busButton.setTitleColor(.black, for: .normal)
    }
}

extension SearchGuideView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let searchHistory = searchHistories[indexPath.row]
        
        switch searchHistory.type {
        case .station:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
            if let stationName = searchHistory.stationName {
                cell.titleLabel.text = stationName
            }
            
            if let arsId = searchHistory.arsId {
                cell.subTitleLabel.text = "\(arsId)"
            }
            
            return cell
            
        case .bus:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBusCell") as? SearchBusCell,
                  let busRoute = searchHistory.busRoute else { return UITableViewCell() }
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchHistory = searchHistories[indexPath.row]
        delegate?.cellClicked(searchHistoryModel: searchHistory)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                searchHistories.remove(at: indexPath.row)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistories), forKey: "searchHistory")
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.didScroll()
    }
}
