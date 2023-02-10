//
//  HomeViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

class HomeViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    private var viewModel = HomeViewModel()
    private var disposeBag = DisposeBag()
    
    private var locationManager = LocationManager.shared
    
    private var posStations = [PosStation]()
    
    private let emptyView = EmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bind()
        
        locationManager.getCurrentLocation()
        setupUI()
        setupGestures()
        getStationByPos()
        checkFirstLaunch()
        AdmobManager.shared.addAdmobView(type: .home, view: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "HomeStationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: HomeStationCell.identifier)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.showEmpty
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        refreshButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.getStationByPos()
            })
            .disposed(by: disposeBag)
        
        // TableView
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfPosStation> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeStationCell.identifier, for: indexPath) as! HomeStationCell
            cell.bind(item: item)
            
            return cell
        }
        
        viewModel.posStations
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(PosStation.self)
            .subscribe { [weak self] posStation in
                guard let arsId = posStation.arsId,
                      let stationNm = posStation.stationNm else { return }
                
                let sb = UIStoryboard(name: "Detail", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
                vc.arsId = arsId
                vc.stationNm = stationNm
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupGestures() {
        // 키보드 숨김 제스처
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // tableView cell event 못 받기 때문에 false 설정
        tap.cancelsTouchesInView = false
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
                if let response = try await BusAPI.shared.getStationByPos(tmX: tmX, tmY: tmY, radius: "500") {
                    let items = response.filter { $0.arsId != "0" }
                    viewModel.posStations.accept([SectionOfPosStation(header: "내 주변 정류장", items: items)])
                }
                viewModel.showEmpty.accept(!viewModel.posStations.value.isEmpty)
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
                self.showCommonPopupView(title: "불러오기 실패", desc: "정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.")
            }
            self.hideLoading()
        }
    }
    
    private func checkFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "firstLaunch") == false {
            self.showCommonPopupView(title: "안내", desc: "서울시 저상버스 전용 앱입니다.\n타 지역 및 일반 버스의 정보는 부정확할 수 있습니다.\n\n서비스 지역을 늘려 나갈 계획입니다.")
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        }
    }
    
    // MARK: - UI
    private func setupUI() {
        // Button
        refreshButton.backgroundColor = .white
        refreshButton.tintColor = .black
        refreshButton.layer.cornerRadius = refreshButton.frame.width / 2
        refreshButton.addShadow(radius: 1, opacity: 0.5, width: 1, height: 1)
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
}

extension HomeViewController: UITableViewDelegate {
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
