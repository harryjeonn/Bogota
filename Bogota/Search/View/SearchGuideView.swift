//
//  SearchGuideView.swift
//  bogota
//
//  Created by 전현성 on 2022/02/14.
//

import UIKit

class SearchGuideView: UIView {
    @IBOutlet weak var stationButton: UIButton!
    @IBOutlet weak var busButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var isStation = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("SearchGuideView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.backgroundColor = .white
        setupUI()
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
