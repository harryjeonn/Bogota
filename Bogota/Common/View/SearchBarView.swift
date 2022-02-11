//
//  SearchBarView.swift
//  bogota
//
//  Created by 전현성 on 2022/02/14.
//

import UIKit

protocol SearchBarViewDelegate {
    func searchButtonClicked(text: String, searchType: SearchType)
}

class SearchBarView: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var delegate: SearchBarViewDelegate?
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
    }
    
    private func search() {
        if let text = textField.text,
           text != "" {
            if searchGuideView.isStation {
                delegate?.searchButtonClicked(text: text, searchType: .station)
            } else {
                delegate?.searchButtonClicked(text: text, searchType: .bus)
            }
        } else {
            dismissKeyboard()
        }
    }
    
    private func addGuideView() {
        guard let topViewController = Utils.shared.topViewController() else { return }
        topViewController.view.addSubview(searchGuideView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchGuideView.addGestureRecognizer(tap)
        
        searchGuideView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchGuideView.topAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchGuideView.leadingAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            searchGuideView.trailingAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            searchGuideView.bottomAnchor.constraint(equalTo: topViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        search()
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addGuideView()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchGuideView.removeFromSuperview()
    }
}
