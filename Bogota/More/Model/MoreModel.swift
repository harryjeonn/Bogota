//
//  MoreModel.swift
//  bogota
//
//  Created by 전현성 on 2022/02/28.
//

import Foundation

enum MoreType {
    case description
    case donation
    case review
    case openSource
    case policy
    
    func title() -> String {
        switch self {
        case .description:
            return "앱 설명"
        case .donation:
            return "기부 내역"
        case .review:
            return "앱 리뷰"
        case .openSource:
            return "정보제공처"
        case .policy:
            return "개인정보처리방침"
        }
    }
}

struct MoreList {
    var type: MoreType
}

class MoreModel: NSObject {
    static let shared = MoreModel()
    
    var moreList = [MoreList]()
    
    func makeMoreList() {
        var list = [MoreList]()
        list.append(MoreList(type: .description))
        list.append(MoreList(type: .donation))
        // TODO: - 앱 배포 후 리뷰URL 연결
//        list.append(MoreList(type: .review))
        list.append(MoreList(type: .openSource))
        list.append(MoreList(type: .policy))
        
        moreList = list
    }
}
