//
//  ChooseHabbyViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/18.
//

import Foundation
import RxSwift
import RxRelay


class ChooseHabbyViewModel {
    
    //所有的嗜好
    private var habbys = HabbyItem.allCases
    
    //所有的儲存嗜好
    private var storeHabbys: Set<HabbyItem> = []

    //新增、移除儲存的嗜好
    func didSelectedRowAt(indexPath: IndexPath) {
        if storeHabbys.contains(HabbyItem(rawValue: indexPath.row)!) {
            storeHabbys.remove(HabbyItem(rawValue: indexPath.row)!)
        } else {
            storeHabbys.insert(HabbyItem(rawValue: indexPath.row)!)
        }
    }

    func cellForRowAt(indexPath: IndexPath) -> (habby: HabbyItem, isSelected: Bool) {
        let habby = habbys[indexPath.row]
        let isSelected = storeHabbys.contains(habbys[indexPath.row])
        return (habby, isSelected)
    }
    
    private func uploadHabbyDataToFireBase() {
        AppLogger.debug("uploadHabby", category: .viewModel)
    }
    
    func setIsAllowToTap() -> Bool {
        storeHabbys.count >= 1 ? true : false
    }
    
    private func saveToLocal() {
        
    }
}
