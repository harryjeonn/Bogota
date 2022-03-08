//
//  AdmobManager.swift
//  bogota
//
//  Created by 전현성 on 2022/02/25.
//

import Foundation
import GoogleMobileAds
import UIKit

enum AdmobType {
    case home
    case favorite
    case station
    case bus
    case search
    case more
    
    func adUnitID() -> String {
        switch self {
        case .home:
            return "ca-app-pub-6497545219748270/9254428512"
        case .favorite:
            return "ca-app-pub-6497545219748270/1304512657"
        case .station:
            return "ca-app-pub-6497545219748270/7111017885"
        case .bus:
            return "ca-app-pub-6497545219748270/8991430986"
        case .search:
            return "ca-app-pub-6497545219748270/7103634240"
        case .more:
            return "ca-app-pub-6497545219748270/5016171738"
        }
    }
}

class AdmobManager: NSObject {
    static let shared = AdmobManager()
    
    let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    func addAdmobView(type: AdmobType, view: UIView) {
        guard let vc = Utils.shared.topViewController() else { return }
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: 50))
        
        let bannerView = GADBannerView(adSize: adSize)
        bannerView.backgroundColor = .clear
        bannerView.adUnitID = type.adUnitID()
//        bannerView.adUnitID = testBannerAdUnitID
        bannerView.rootViewController = vc
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        switch type {
        case .home, .favorite, .more:
            NSLayoutConstraint.activate([
                bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                bannerView.heightAnchor.constraint(equalToConstant: 50)
            ])
        case .station, .bus, .search:
            NSLayoutConstraint.activate([
                bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
                bannerView.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
}

extension AdmobManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
