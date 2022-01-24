//
//  HomeViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var testStationList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        setupTabbar()
        setupUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupTabbar() {
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    }
    
    private func setupUI() {
        // TextField
        searchTextField.layer.cornerRadius = 10
        searchTextField.placeholder = "정류장 검색"
        
        // Button
        searchButton.setImage(UIImage(named: "btn_search"), for: .normal)
        
        // TableView
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HomeStationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HomeStationCell")
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        print("Clicked search button")
        // TODO: 정류소 검색
        // 정류소 이름이나 ID 가지고 정류소 검색
        // 위치정보와 정류소 지나는 버스 정보 필요
        // 화면 전환
        
        // test code
        if let text = searchTextField.text,
           text != "" {
            testStationList.append(text)
            searchTextField.text = nil
        }
        
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testStationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStationCell") as? HomeStationCell else { return UITableViewCell() }
        
        cell.titleLabel.text = testStationList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select cell")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "내 주변 정류장"
    }
}
