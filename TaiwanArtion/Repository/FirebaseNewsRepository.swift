//
//  FirebaseNewsRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation

class FirebaseNewsRepository: NewsRepository {

    private let database: FirebaseDatabase

    init(database: FirebaseDatabase = FirebaseDatabase(collectionName: "news")) {
        self.database = database
    }

    func getRandomNews(count: Int, completion: @escaping (Result<[News], Error>) -> Void) {
        database.getRandomDocuments(count: count) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let newsList = data.compactMap { News.from($0) }
                completion(.success(newsList))
            } else {
                completion(.success([]))
            }
        }
    }

    func getNews(byID id: String, completion: @escaping (Result<News?, Error>) -> Void) {
        database.readDocument(documentID: id) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(News.from(data)))
            } else {
                completion(.success(nil))
            }
        }
    }

    func getNews(byIDs ids: [String], completion: @escaping (Result<[News], Error>) -> Void) {
        var newsList: [News] = []
        let dispatchGroup = DispatchGroup()

        for id in ids {
            dispatchGroup.enter()
            database.readDocument(documentID: id) { data, error in
                defer { dispatchGroup.leave() }
                if let data = data, let news = News.from(data) {
                    newsList.append(news)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(newsList))
        }
    }
}
