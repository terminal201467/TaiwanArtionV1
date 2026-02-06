//
//  ExhibitionRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation

/// 分頁載入結果
struct PaginatedExhibitionResult {
    let exhibitions: [ExhibitionInfo]
    let lastDocument: Any?
    let hasMore: Bool
}

protocol ExhibitionRepository {
    func getRandomExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getHotExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getRecentExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getExhibitions(month: String?, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)

    /// 分頁取得展覽資料
    /// - Parameters:
    ///   - pageSize: 每頁數量
    ///   - lastDocument: 上一頁的最後一筆文件（用於游標分頁），首次載入傳入 nil
    ///   - completion: 完成回調，包含展覽資料和分頁資訊
    func getExhibitionsPaginated(
        pageSize: Int,
        lastDocument: Any?,
        completion: @escaping (Result<PaginatedExhibitionResult, Error>) -> Void
    )
}
