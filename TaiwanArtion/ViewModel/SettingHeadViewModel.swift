//
//  SettingHeadViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/7.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol SettingHeadViewModelInput {
    var inputCellForRowAt: BehaviorRelay<IndexPath> { get }
    var selectedHeadImageIndex: PublishSubject<IndexPath> { get }
    var selectedNewPhoto: PublishSubject<Data> { get }
    var savePhoto: PublishSubject<Void> { get }
    var resetHead: PublishSubject<Void> { get }
    //輸入暫存的圖片檔案Data
}

protocol SettingHeadViewModelOutput {
    var outputCellContentForRowAt: BehaviorRelay<Any> { get }
    var outputCellSelectedForRowAt: BehaviorRelay<Bool?> { get }
    var headImagesObservable: BehaviorRelay<[Any]> { get }
    var isAllowSavePhoto: BehaviorRelay<Bool> { get }
    var storeHead: BehaviorRelay<Any?> { get }
    var isCurrentSelectedIndex: BehaviorRelay<Bool> { get }
}

protocol SettingHeadViewModelType {
    var input: SettingHeadViewModelInput { get }
    var output: SettingHeadViewModelOutput { get }
}

class SettingHeadViewModel: SettingHeadViewModelInput, SettingHeadViewModelOutput, SettingHeadViewModelType {

    private let disposeBag = DisposeBag()
    
    //Input
    var inputCellForRowAt: BehaviorRelay<IndexPath> = BehaviorRelay(value: [0, 0])
    var selectedHeadImageIndex: PublishSubject<IndexPath> = PublishSubject()
    var savePhoto: PublishSubject<Void> = PublishSubject()
    var selectedNewPhoto: PublishSubject<Data> = PublishSubject()
    var resetHead: PublishSubject<Void> = PublishSubject()
    
    //Output
    var storeHead: BehaviorRelay<Any?> = BehaviorRelay(value: nil)
    var isAllowSavePhoto: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var headImagesObservable: BehaviorRelay<[Any]> { BehaviorRelay(value: defaultPhotos) }
    var isCurrentSelectedIndex: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var outputCellContentForRowAt: BehaviorRelay<Any> = BehaviorRelay(value: "")
    var outputCellSelectedForRowAt: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
    
    private var currentPhotoIndexPath: IndexPath?
    
    private var defaultPhotos: [String] = ["takePhoto", "bigHead01", "bigHead02", "bigHead03", "bigHead04", "bigHead05", "bigHead06", "bigHead07", "bigHead08", "bigHead09"]
    
    //MARK: - input、output
    var input: SettingHeadViewModelInput { self }
    var output: SettingHeadViewModelOutput { self }
    
    init() {
        //input
        inputCellForRowAt
            .subscribe { [weak self] indexPath in
                self?.cellForRowAt(indexPath: indexPath)
            }
            .disposed(by: disposeBag)

        selectedHeadImageIndex
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.storeHead.accept(self.headImagesObservable.value[indexPath.row])
                self.currentPhotoIndexPath = indexPath
                self.isAllowSelected()
            })
            .disposed(by: disposeBag)

        selectedNewPhoto
            .subscribe(onNext: { [weak self] image in
                self?.storeHead.accept(image)
            })
            .disposed(by: disposeBag)

        savePhoto.subscribe(onNext: {
            //這邊儲存進本地端的照片
            AppLogger.debug("savePhoto", category: .viewModel)
            //存進去Firebase
        })
        .disposed(by: disposeBag)

        resetHead
            .subscribe(onNext: { [weak self] in
                self?.resetSelected()
            })
            .disposed(by: disposeBag)
        
        self.isAllowSelected()
    }
    
    private func isAllowSelected() {
        isAllowSavePhoto.accept(currentPhotoIndexPath == nil ? false: true)
    }
    
    private func resetSelected() {
        storeHead.accept(nil)
    }
    
    private func cellForRowAt(indexPath: IndexPath) {
        let cellContent = defaultPhotos[indexPath.row]
        var isSelected: Bool?
        if currentPhotoIndexPath == nil {
            isSelected = nil
        } else {
            isSelected = defaultPhotos[indexPath.row] == defaultPhotos[currentPhotoIndexPath!.row]
        }
        outputCellContentForRowAt.accept(cellContent)
        outputCellSelectedForRowAt.accept(isSelected)
    }
}
