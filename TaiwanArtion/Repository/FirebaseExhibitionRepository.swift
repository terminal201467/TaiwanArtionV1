//
//  FirebaseExhibitionRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation

class FirebaseExhibitionRepository: ExhibitionRepository {

    private let database: FirebaseDatabase

    init(database: FirebaseDatabase = FirebaseDatabase(collectionName: "exhibitions")) {
        self.database = database
    }

    func getRandomExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        database.getRandomDocuments(count: count) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getHotExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        database.getHotDocument(count: count) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getRecentExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        database.getRecentDocuments(count: count) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getExhibitions(month: String?, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        database.readDocument(month: month) { data, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                completion(.success(exhibitions))
            }
        }
    }
}
