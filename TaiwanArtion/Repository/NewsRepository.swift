//
//  NewsRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation

protocol NewsRepository {
    func getRandomNews(count: Int, completion: @escaping (Result<[News], Error>) -> Void)
    func getNews(byID id: String, completion: @escaping (Result<News?, Error>) -> Void)
    func getNews(byIDs ids: [String], completion: @escaping (Result<[News], Error>) -> Void)
}
