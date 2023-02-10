//
//  BaseViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation
import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class BaseViewController: UIViewController {
    let searchBarView = SearchBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        setupNavigation()
        searchBarView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchBarView.removeGuideView()
        searchBarView.textField.text = nil
    }
    
    private func setupTabbar() {
        // TabBar 색상 설정
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.backgroundColor = .tabBarBgColor
    }
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        // Navigation Bar 경계선 지우기
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.titleView = self.searchBarView
    }
    
    // MARK: - Show common popup
    func showCommonPopupView(title: String, desc: String) {
        guard let vc = Utils.shared.topViewController() else { return }
//        guard let vc = UIApplication.shared.windows.last else { return }
        
        let popupView = CommonPopupView()
        popupView.titleLabel.text = title
        popupView.descriptionLabel.text = desc
        popupView.confirmButton.setTitle("확인", for: .normal)
        
        vc.view.addSubview(popupView)
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
            popupView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0),
            popupView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0),
            popupView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Loading indicator
    func showLoading() {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }
            
            let loadingIndicatorView: UIActivityIndicatorView
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                loadingIndicatorView.frame = window.frame
                window.addSubview(loadingIndicatorView)
            }
            
            loadingIndicatorView.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}

//MARK: - Search bar delegate (네비게이션 검색창)
extension BaseViewController: SearchBarViewDelegate {
    func searchButtonClicked(text: String?, searchType: SearchType?, isActive: Bool?) {
        if let _ = isActive {
            searchBarView.textField.becomeFirstResponder()
        }
        
        let sb = UIStoryboard(name: "Search", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController,
              let text = text,
              let searchType = searchType else { return }
        let upperText = text.uppercased()
        vc.keyword = upperText
        vc.searchType = searchType
        
        Utils.shared.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellClicked(searchHistoryModel: SearchHistoryModel) {
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        switch searchHistoryModel.type {
        case .station:
            guard let vc = sb.instantiateViewController(withIdentifier: "StationDetailViewController") as? StationDetailViewController else { return }
            if let stationName = searchHistoryModel.stationName,
               let arsId = searchHistoryModel.arsId {
                vc.stationNm = stationName
                vc.arsId = arsId
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .bus:
            guard let vc = sb.instantiateViewController(withIdentifier: "BusDetailViewController") as? BusDetailViewController else { return }
            
            if let busRoute = searchHistoryModel.busRoute,
               let busRouteId = busRoute.busRouteId {
                vc.busRoute = busRoute
                vc.busRouteId = busRouteId
            }
            
            Utils.shared.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
