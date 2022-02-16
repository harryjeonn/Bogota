//
//  BaseViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    let searchBarView = SearchBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        // Navigation Bar 경계선 지우기
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchBarView.removeGuideView()
        searchBarView.textField.text = nil
    }
    
    
    // MARK: - Show common popup
    func showCommonPopupView(title: String, desc: String) {
//        guard let vc = Utils.shared.topViewController() else { return }
        guard let vc = UIApplication.shared.windows.last else { return }
        
        let popupView = CommonPopupView()
        popupView.titleLabel.text = title
        popupView.descriptionLabel.text = desc
        popupView.confirmButton.setTitle("확인", for: .normal)
        
        vc.addSubview(popupView)
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.topAnchor.constraint(equalTo: vc.topAnchor, constant: 0),
            popupView.leadingAnchor.constraint(equalTo: vc.leadingAnchor, constant: 0),
            popupView.trailingAnchor.constraint(equalTo: vc.trailingAnchor, constant: 0),
            popupView.bottomAnchor.constraint(equalTo: vc.bottomAnchor, constant: 0)
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
