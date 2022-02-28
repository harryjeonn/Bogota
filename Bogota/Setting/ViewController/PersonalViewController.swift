//
//  PersonalViewController.swift
//  bogota
//
//  Created by 이환규 on 2022/02/27.
//

import UIKit
import WebKit

class PersonalViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = URL (string: "https://www.apple.com/kr/legal/privacy/kr/")
               let requestObj = URLRequest(url: url!)
        webView.load(requestObj)
        
    }


}
