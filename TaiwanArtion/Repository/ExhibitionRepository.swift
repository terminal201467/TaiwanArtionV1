//
//  ExhibitionRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation

protocol ExhibitionRepository {
    func getRandomExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getHotExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getRecentExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
    func getExhibitions(month: String?, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void)
}
