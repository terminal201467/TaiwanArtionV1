//
//  SplashViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

class SplashViewModel {
    
    var allowTap: ((Bool) -> Void)?
    
    let handleSelectedItem: PublishRelay = PublishRelay<String>()
    
    let handleSelectedIndex: PublishRelay = PublishRelay<Int>()
    
    let sendOutHabby: PublishRelay = PublishRelay<Void>()
    
    private var selectedItems = Set<String>() {
        didSet {
            allowTap?(setAllowButtonTap())
            AppLogger.debug("selectedItems:\(selectedItems)", category: .viewModel)
        }
    }
    
    private var selectedIndex = Set<Int>() {
        didSet {
            AppLogger.debug("selectedIndex:\(selectedIndex)", category: .viewModel)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        handleSelectedItem.subscribe(onNext: { item in
            self.toggleSelection(selectedSet: &self.selectedItems, item: item)
        })
        .disposed(by: disposeBag)
        
        handleSelectedIndex.subscribe(onNext: { index in
            self.toggleSelection(selectedSet: &self.selectedIndex, item: index)
        })
        .disposed(by: disposeBag)
        
        sendOutHabby.subscribe(onNext: {
            if self.setAllowButtonTap() {
                self.saveDataToUserDefault()
            } else {
                //
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func setAllowButtonTap() -> Bool {
        if selectedItems.count < 1 {
            return false
        } else if selectedItems.count > 3 {
            return false
        } else {
            return true
        }
    }
    
    private func toggleSelection<T: Hashable>(selectedSet: inout Set<T>, item: T) {
        if selectedSet.contains(item) {
            selectedSet.remove(item)
        } else {
            selectedSet.insert(item)
        }
    }
    
    //這邊可能要回傳的是，哪幾個cell是有的，如果有的話就回傳Bool
    func provideSelectedCell(indexPath: IndexPath) -> Bool {
        selectedIndex.contains(indexPath.item) ? true : false
    }
    
    //儲存使用者喜好進本地端（後面會用到）
    func saveDataToUserDefault() {
        
    }
    
}
