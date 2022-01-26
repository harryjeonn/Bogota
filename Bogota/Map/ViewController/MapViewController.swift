//
//  MapViewController.swift
//  bogota
//
//  Created by 전현성 on 2022/01/24.
//

import UIKit

class MapViewController: BaseViewController {
    @IBOutlet weak var testTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchStationByName(_ keyword: String) {
        Task {
            do {
                let response = try await BusAPI.shared.getStationByNameList(keyword)
                self.testTextView.text = "\(response)"
            } catch {
                print("*** Error: \(error.localizedDescription) - \(error)")
            }
        }
    }
}
