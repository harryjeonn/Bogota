//
//  MoreViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/02/28.
//

import UIKit
import SafariServices

class MoreViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MoreModel.shared.makeMoreList()
        setupTabbar()
        setupTableView()
        AdmobManager.shared.addAdmobView(type: .more, view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupTabbar() {
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.backgroundColor = .tabBarBgColor
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = self.searchBarView
    }
    
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoreModel.shared.moreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        let item = MoreModel.shared.moreList[indexPath.row]
        cell.textLabel?.text = item.type.title()
        cell.textLabel?.font = .systemFont(ofSize: 17)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = MoreModel.shared.moreList[indexPath.row].type
        
        var url: URL?
        
        switch type {
        case .description:
            url = URL(string: "https://devhoxvi.blogspot.com/2022/02/blog-post.html")
        case .donation:
            url = URL(string: "https://devhoxvi.blogspot.com/2022/02/blog-post_27.html")
        case .review:
            if let url = URL(string: "itms-apps://itunes.apple.com/app/1612002644?action=write-review") {
                UIApplication.shared.open(url, options: [:])
            }
            return
        case .openSource:
            url = URL(string: "https://devhoxvi.blogspot.com/2022/02/blog-post_5.html")
        case .policy:
            url = URL(string: "https://devhoxvi.blogspot.com/2021/11/ios.html")
        }
        
        guard let url = url else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
