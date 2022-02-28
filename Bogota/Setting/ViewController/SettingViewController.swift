//
//  SettingViewController.swift
//  bogota
//
//  Created by 이환규 on 2022/02/27.
//

import UIKit

class SettingViewController: UIViewController {

    
    @IBOutlet var setTableView: UITableView!
 
    
    let ase = ["오픈소스 출처","기부내역","앱 리뷰","개인정보처리방침","앱 설명"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView.delegate = self
        setTableView.dataSource = self
        
    }


}




// MARK: - TableView Delegate
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard (name: "Setting", bundle: nil)
        
            switch indexPath.row {

                case 0:
                guard  let nextVC = storyBoard.instantiateViewController(withIdentifier: "OpenSourc") as? OpenSourcViewController else {return}
                  self.navigationController?.pushViewController(nextVC, animated: true)
                
                case 1:
                guard  let nextVC = storyBoard.instantiateViewController(withIdentifier: "Donation") as? DonationViewController else {return}
                  self.navigationController?.pushViewController(nextVC, animated: true)

                case 2:
                guard  let nextVC = storyBoard.instantiateViewController(withIdentifier: "appReview") as? AppReviewViewController else {return}
                  self.navigationController?.pushViewController(nextVC, animated: true)
                    
                case 3:
                guard  let nextVC = storyBoard.instantiateViewController(withIdentifier: "Personal") as? PersonalViewController else {return}
                  self.navigationController?.pushViewController(nextVC, animated: true)
                    
                case 4:
                    
                guard  let nextVC = storyBoard.instantiateViewController(withIdentifier: "explanation") as? explanationViewController else {return}
                  self.navigationController?.pushViewController(nextVC, animated: true)
                default:

                return

    }
        
    }
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return ase.count
    
   
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "openCell", for: indexPath)
    cell.accessoryType = .disclosureIndicator  //테이블뷰 셀 화살표 추가
    cell.textLabel?.text = ase [indexPath.row]
    return cell
}
    
    
}
