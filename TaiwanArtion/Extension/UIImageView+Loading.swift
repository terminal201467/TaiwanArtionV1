//
//  UIImageView+Loading.swift
//  TaiwanArtion
//
//  Created on 2026/2/6.
//

import UIKit
import Kingfisher

extension UIImageView {

    /// 統一的圖片載入方法，支援 placeholder、漸變動畫和錯誤處理
    /// - Parameters:
    ///   - urlString: 圖片 URL 字串
    ///   - placeholder: 預設圖片名稱，預設為 "defaultExhibition"
    ///   - targetSize: 目標尺寸用於降採樣，nil 則使用 ImageView 本身尺寸
    func loadImage(
        from urlString: String,
        placeholder: String = "defaultExhibition",
        targetSize: CGSize? = nil
    ) {
        // 處理空字串或直接使用 placeholder 名稱的情況
        if urlString.isEmpty || urlString == placeholder {
            self.image = UIImage(named: placeholder)
            return
        }

        // 驗證 URL 格式
        guard let url = URL(string: urlString) else {
            AppLogger.warning("無效的圖片 URL: \(urlString)", category: .network)
            self.image = UIImage(named: placeholder)
            return
        }

        // 計算降採樣尺寸（適應不同 cell 尺寸）
        let downsampleSize = targetSize ?? self.bounds.size
        let finalSize = downsampleSize.width > 0 ? downsampleSize : CGSize(width: 300, height: 300)

        // 設定圖片載入選項
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .scaleFactor(UIScreen.main.scale),
            .backgroundDecode
        ]

        // 只在有明確尺寸時才進行降採樣
        if finalSize.width > 0 && finalSize.height > 0 {
            options.append(.processor(DownsamplingImageProcessor(size: finalSize)))
        }

        // 設定 placeholder 圖片
        let placeholderImage = UIImage(named: placeholder)

        // 載入圖片
        self.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: options
        ) { [weak self] result in
            switch result {
            case .success:
                // 成功載入，無需額外處理
                break
            case .failure(let error):
                // 載入失敗，使用 fallback 圖片
                AppLogger.warning("圖片載入失敗: \(error.localizedDescription)", category: .network)
                self?.image = placeholderImage
            }
        }
    }

    /// 取消當前的圖片下載任務
    func cancelImageLoad() {
        self.kf.cancelDownloadTask()
    }
}
