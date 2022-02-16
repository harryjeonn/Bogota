//
//  SearchBarView.swift
//  bogota
//
//  Created by 전현성 on 2022/02/14.
//

import UIKit

protocol SearchBarViewDelegate {
    func searchButtonClicked(text: String?, searchType: SearchType?, isActive: Bool?)
    func cellClicked(searchHistoryModel: SearchHistoryModel)
}

class SearchBarView: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var delegate: SearchBarViewDelegate?
    var isActive = false
    let searchGuideView = SearchGuideView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("SearchBarView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = .clear
        setupContentView()
        addSubview(view)
    }

    private func setupContentView() {
        searchButton.setImage(UIImage(named: "btn_search"), for: .normal)
        
        textField.delegate = self
        textField.layer.cornerRadius = 10
        textField.placeholder = "정류장, 정류장 번호 검색"
        textField.returnKeyType = .search
        
        searchGuideView.delegate = self
    }
    
    private func search() {
        if let text = textField.text,
           text != "" {
            if searchGuideView.isStation {
                delegate?.searchButtonClicked(text: text, searchType: .station, isActive: nil)
            } else {
                delegate?.searchButtonClicked(text: text, searchType: .bus, isActive: nil)
            }
            searchGuideView.removeFromSuperview()
        } else {
            dismissKeyboard()
        }
    }
    
    private func addGuideView() {
        guard let topViewController = Utils.shared.topViewController() else { return }
        topViewController.view.addSubview(searchGuideView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchGuideView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        searchGuideView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchGuideView.topAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchGuideView.leadingAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            searchGuideView.trailingAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            searchGuideView.bottomAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        searchButton.setImage(nil, for: .normal)
        searchButton.setTitle("취소", for: .normal)
        isActive = true
    }
    
    func removeGuideView() {
        searchGuideView.removeFromSuperview()
        searchButton.setTitle("", for: .normal)
        searchButton.setImage(UIImage(named: "btn_search"), for: .normal)
        isActive = false
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        if isActive {
            dismissKeyboard()
            removeGuideView()
        } else {
            delegate?.searchButtonClicked(text: nil, searchType: nil, isActive: isActive)
        }
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeGuideView()
        search()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addGuideView()
    }
}

extension SearchBarView: SearchGuideViewDelegate {
    func cellClicked(searchHistoryModel: SearchHistoryModel) {
        removeGuideView()
        delegate?.cellClicked(searchHistoryModel: searchHistoryModel)
    }
    
    func didScroll() {
        dismissKeyboard()
    }
}
