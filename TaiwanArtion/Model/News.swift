//
//  NewsModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/9/20.
//

import Foundation

public struct News {

    var id: String
    var title: String
    var date: String
    var author: String
    var image: String
    var description: String

}

// MARK: - Dictionary Conversion

extension News {
    static func from(_ data: [String: Any]) -> News? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let date = data["date"] as? String,
              let author = data["author"] as? String,
              let image = data["image"] as? String,
              let description = data["description"] as? String else { return nil }
        return News(
            id: id,
            title: title,
            date: date,
            author: author,
            image: image.isEmpty ? "defaultExhibition" : image,
            description: description
        )
    }
}
