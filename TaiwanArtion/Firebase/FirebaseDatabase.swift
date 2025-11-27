//
//  Firebase.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/15.
//

import FirebaseCore
import FirebaseFirestore

class FirebaseDatabase {
    
    private let collectionName: String
    private let db: Firestore
    
    init(collectionName: String) {
        self.collectionName = collectionName
        self.db = Firestore.firestore()
    }
    
    func createDocument(data: [String: Any], completion: @escaping (String?, Error?) -> Void) {
        var documentRef: DocumentReference? = nil
        documentRef = db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(documentRef?.documentID, nil)
            }
        }
    }
    
    func readDocument(documentID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let documentRef = db.collection(collectionName).document(documentID)
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(document.data(), nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func updateDocument(documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection(collectionName).document(documentID)
        documentRef.updateData(data) { error in
            completion(error)
        }
    }
    
    func deleteDocument(documentID: String, completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection(collectionName).document(documentID)
        documentRef.delete { error in
            completion(error)
        }
    }
    
    /// 獲取隨機文件（優化版本）
    /// - Parameters:
    ///   - count: 要獲取的文件數量
    ///   - completion: 完成回調
    /// - Note: 使用限制查詢來提升性能，避免獲取整個 collection
    func getRandomDocuments(count: Int, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        AppLogger.enter(category: .firebase)
        AppLogger.debug("獲取 \(count) 個隨機文件", category: .firebase)

        // 優化：先獲取總數，然後使用隨機偏移量
        db.collection(collectionName).limit(to: 1).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if error != nil {
                // 如果獲取總數失敗，使用簡單的限制查詢
                self.db.collection(collectionName)
                    .limit(to: count * 3) // 獲取 3 倍數量以便隨機選擇
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            AppLogger.error("獲取隨機文件失敗", category: .firebase, error: error)
                            completion(nil, error)
                        } else {
                            let documents = querySnapshot?.documents.shuffled().prefix(count)
                            let results = documents?.map { $0.data() }
                            AppLogger.info("成功獲取 \(results?.count ?? 0) 個隨機文件", category: .firebase)
                            completion(Array(results ?? []), nil)
                        }
                    }
            } else {
                // 使用限制查詢優化
                self.db.collection(collectionName)
                    .limit(to: min(count * 2, 50)) // 限制最多獲取 50 個以提升性能
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            AppLogger.error("獲取隨機文件失敗", category: .firebase, error: error)
                            completion(nil, error)
                        } else {
                            let documents = querySnapshot?.documents.shuffled().prefix(count)
                            let results = documents?.map { $0.data() }
                            AppLogger.info("成功獲取 \(results?.count ?? 0) 個隨機文件", category: .firebase)
                            completion(Array(results ?? []), nil)
                        }
                        AppLogger.exit(category: .firebase)
                    }
            }
        }
    }
    
    func getHotDocument(count: Int, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection(collectionName).order(by: "hitRate", descending: true).limit(to: count).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let results = querySnapshot?.documents.map { $0.data() }
                completion(results, nil)
            }
        }
    }
    
    func getRecentDocuments(count: Int, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection(collectionName).order(by: "startDate", descending: false).limit(to: count).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let results = querySnapshot?.documents.map { $0.data() }
                completion(results, nil)
            }
        }
    }
    
    /// 獲取熱門展覽（依瀏覽次數排序）
    /// - Parameters:
    ///   - count: 要獲取的展覽數量，預設為 10
    ///   - completion: 完成回調，返回展覽資料陣列或錯誤
    func getPopularDocument(count: Int = 10, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        AppLogger.enter(category: .firebase)

        db.collection(collectionName)
            .order(by: "viewCount", descending: true)
            .limit(to: count)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    AppLogger.logFirebaseOperation(
                        operation: "getPopularDocument",
                        collection: self.collectionName,
                        success: false,
                        error: error
                    )
                    completion(nil, error)
                } else {
                    let results = querySnapshot?.documents.map { $0.data() }
                    AppLogger.logFirebaseOperation(
                        operation: "getPopularDocument",
                        collection: self.collectionName,
                        success: true
                    )
                    AppLogger.info("獲取 \(results?.count ?? 0) 個熱門展覽", category: .firebase)
                    completion(results, nil)
                }
            }

        AppLogger.exit(category: .firebase)
    }

    /// 獲取高評分展覽（依評分排序）
    /// - Parameters:
    ///   - count: 要獲取的展覽數量，預設為 10
    ///   - minRating: 最低評分，預設為 4.0
    ///   - completion: 完成回調，返回展覽資料陣列或錯誤
    func getHighEvaluationDocument(count: Int = 10, minRating: Double = 4.0, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        AppLogger.enter(category: .firebase)

        db.collection(collectionName)
            .whereField("rating", isGreaterThanOrEqualTo: minRating)
            .order(by: "rating", descending: true)
            .limit(to: count)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    AppLogger.logFirebaseOperation(
                        operation: "getHighEvaluationDocument",
                        collection: self.collectionName,
                        success: false,
                        error: error
                    )
                    completion(nil, error)
                } else {
                    let results = querySnapshot?.documents.map { $0.data() }
                    AppLogger.logFirebaseOperation(
                        operation: "getHighEvaluationDocument",
                        collection: self.collectionName,
                        success: true
                    )
                    AppLogger.info("獲取 \(results?.count ?? 0) 個高評分展覽", category: .firebase)
                    completion(results, nil)
                }
            }

        AppLogger.exit(category: .firebase)
    }
    
    //首頁讀取資料的相關function
    func readDocument(habby: String? = nil, month: String? = nil, item: String? = nil, completion: @escaping ([[String: Any]], Error?) -> Void) {
        var query: Query = db.collection(collectionName)
        
        if let habby = habby {
            query = query.whereField("habby", isEqualTo: habby)
        }
        
        if let month = month {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            
            if let date = monthFormatter.date(from: month) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let dateString = dateFormatter.string(from: date)
                query = query.whereField("startDate", isEqualTo: dateString)
            } else {
                // Invalid month string
                completion([], nil)
                return
            }
        }
        
        if let item = item {
            query = query.whereField("category", isEqualTo: item)
        }
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion([], error)
                return
            }
            
            var documents: [[String: Any]] = []
            
            for document in snapshot?.documents ?? [] {
                documents.append(document.data())
            }
            
            completion(documents, nil)
        }
    }
    
    private func getMonthString(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        if let date = dateFormatter.date(from: dateString) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            let monthString = monthFormatter.string(from: date)
            return monthString
        }

        return nil
    }

    // MARK: - Pagination Support

    /// 分頁載入文件
    /// - Parameters:
    ///   - pageSize: 每頁載入的文件數量
    ///   - lastDocument: 上一頁的最後一個文件（用於繼續載入），首次載入時傳 nil
    ///   - orderBy: 排序欄位，預設為 nil（不排序）
    ///   - descending: 是否降序排列，預設為 false
    ///   - completion: 完成回調，返回文件資料陣列、最後一個文件快照（用於下次載入）和錯誤
    /// - Note: 使用 DocumentSnapshot 作為分頁游標，支援向下無限滾動載入
    func getPaginatedDocuments(
        pageSize: Int,
        lastDocument: DocumentSnapshot? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        completion: @escaping ([[String: Any]]?, DocumentSnapshot?, Error?) -> Void
    ) {
        AppLogger.enter(category: .firebase)
        AppLogger.debug("分頁載入：pageSize=\(pageSize), hasLastDoc=\(lastDocument != nil)", category: .firebase)

        var query: Query = db.collection(collectionName)

        // 如果指定了排序欄位
        if let orderField = orderBy {
            query = query.order(by: orderField, descending: descending)
        }

        // 設定分頁游標
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }

        // 限制每頁數量
        query = query.limit(to: pageSize)

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                AppLogger.error("分頁載入失敗", category: .firebase, error: error)
                completion(nil, nil, error)
            } else {
                let documents = querySnapshot?.documents ?? []
                let results = documents.map { $0.data() }
                let lastDoc = documents.last

                AppLogger.info("分頁載入成功：獲取 \(results.count) 個文件", category: .firebase)
                completion(results, lastDoc, nil)
            }

            AppLogger.exit(category: .firebase)
        }
    }

    /// 分頁載入符合條件的文件
    /// - Parameters:
    ///   - field: 查詢欄位
    ///   - value: 查詢值
    ///   - pageSize: 每頁載入的文件數量
    ///   - lastDocument: 上一頁的最後一個文件
    ///   - orderBy: 排序欄位
    ///   - descending: 是否降序排列
    ///   - completion: 完成回調
    func getPaginatedDocuments(
        whereField field: String,
        isEqualTo value: Any,
        pageSize: Int,
        lastDocument: DocumentSnapshot? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        completion: @escaping ([[String: Any]]?, DocumentSnapshot?, Error?) -> Void
    ) {
        AppLogger.enter(category: .firebase)
        AppLogger.debug("條件分頁載入：\(field)=\(value), pageSize=\(pageSize)", category: .firebase)

        var query: Query = db.collection(collectionName)
            .whereField(field, isEqualTo: value)

        // 如果指定了排序欄位
        if let orderField = orderBy {
            query = query.order(by: orderField, descending: descending)
        }

        // 設定分頁游標
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }

        // 限制每頁數量
        query = query.limit(to: pageSize)

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                AppLogger.error("條件分頁載入失敗", category: .firebase, error: error)
                completion(nil, nil, error)
            } else {
                let documents = querySnapshot?.documents ?? []
                let results = documents.map { $0.data() }
                let lastDoc = documents.last

                AppLogger.info("條件分頁載入成功：獲取 \(results.count) 個文件", category: .firebase)
                completion(results, lastDoc, nil)
            }

            AppLogger.exit(category: .firebase)
        }
    }
}
