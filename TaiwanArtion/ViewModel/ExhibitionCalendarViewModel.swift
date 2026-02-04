//
//  ExhibitionCalendarViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/30.
//

import Foundation
import RxRelay


protocol ExhibitionCalendarInput {
    
    //輸入點擊Habby
    var inputHabby: BehaviorRelay<HabbyItem?> { get }
    
    //輸入取得時間
    var inputDate: BehaviorRelay<String> { get }
    
    //輸入展覽月曆、展覽清單點擊的Button
    var inputContentTypeItem: BehaviorRelay<Bool> { get }
    
}

protocol ExhibitionCalendarOutput {
    
    //輸出點擊的Item
    var outputContentTypeItem: BehaviorRelay<Bool> { get }
    
    //輸出點擊的Habby
    var outputHabby: BehaviorRelay<HabbyItem?> { get }
    
    //選擇的展覽
    var outputExhibitions: BehaviorRelay<[ExhibitionInfo]> { get }
    
    //輸出日期
    var outputDate: BehaviorRelay<String?> { get }
    
    var outputRecentValidExhibitionDate: BehaviorRelay<[ExhibitionInfo]> { get }
    
}

protocol ExhibitionCalendarTypeInputOutput {
    
    var input: ExhibitionCalendarInput { get }
    
    var output: ExhibitionCalendarOutput { get }
    
}


class ExhibitionCalendarViewModel: ExhibitionCalendarTypeInputOutput, ExhibitionCalendarInput, ExhibitionCalendarOutput {
    
    //MARK: - input
    var inputHabby: BehaviorRelay<HabbyItem?> = BehaviorRelay(value: nil)
    
    var inputDate: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputContentTypeItem: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    //MARK: - output
    
    var outputContentTypeItem: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    var outputHabby: BehaviorRelay<HabbyItem?> = BehaviorRelay(value: nil)
    
    var outputExhibitions: RxRelay.BehaviorRelay<[ExhibitionInfo]> = BehaviorRelay(value: [])
    
    var outputDate: RxRelay.BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var outputRecentValidExhibitionDate: RxRelay.BehaviorRelay<[ExhibitionInfo]> = BehaviorRelay(value: [])
    
    //MARK: - input/output
    
    var input: ExhibitionCalendarInput { self }
    
    var output: ExhibitionCalendarOutput { self }
    
    //MARK: - Repository

    private let exhibitionRepository: ExhibitionRepository

    //MARK: - Initialization
    init(exhibitionRepository: ExhibitionRepository = FirebaseExhibitionRepository()) {
        self.exhibitionRepository = exhibitionRepository
        outputContentTypeItem = inputContentTypeItem
        
        outputHabby = inputHabby
        
        fetchDataHotExhibition(by: 10) { infos in
            self.outputExhibitions.accept(infos)
        }
    }
    
    func fetchDataHotExhibition(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionRepository.getHotExhibitions(count: count) { result in
            switch result {
            case .success(let exhibitions):
                completion(exhibitions)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel)
            }
        }
    }
}
