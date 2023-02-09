//
//  HomeViewModel.swift
//  bogota
//
//  Created by 전현성 on 2023/02/09.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct SectionOfPosStation {
    var header: String
    var items: [PosStation]
}

extension SectionOfPosStation: SectionModelType {
    typealias Item = PosStation
    
    init(original: SectionOfPosStation, items: [Item]) {
        self = original
        self.items = items
    }
}

class HomeViewModel {
    // MARK: - Input
    
    // MARK: - Output
    let posStations = BehaviorRelay<[SectionOfPosStation]>(value: [SectionOfPosStation]())
    let showEmpty = BehaviorRelay<Bool>(value: false)
}
