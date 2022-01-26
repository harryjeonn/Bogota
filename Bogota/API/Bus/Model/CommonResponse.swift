//
//  CommonResponse.swift
//  bogota
//
//  Created by 전현성 on 2022/01/26.
//

import Foundation

struct ComMsgHeader: Codable {
    var errMsg: String?
    var requestMsgID: String?
    var responseMsgID: String?
    var responseTime: String?
    var returnCode: String?
    var successYN: String?
}
        
struct MsgHeader: Codable {
    var headerCd: String?
    var headerMsg: String?
    var itemCount: Int?
}
