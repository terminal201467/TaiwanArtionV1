//
//  ExhibitionInfo.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import Foundation

public struct ExhibitionInfo: Hashable, Equatable {
    
    var title: String
    var image: String
    var tag: String
    var dateString: String
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    var dateBefore: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let pastDate = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            
            let currentDate = Date()
            let components = calendar.dateComponents([.day], from: pastDate, to: currentDate)
            if let days = components.day {
                return days
            }
        }
        return 0
    }
    var time: String
    var agency: String
    var official: String
    var telephone: String
    
    //票價：
    var advanceTicketPrice: String
    var unanimousVotePrice: String
    var studentPrice: String
    var groupPrice: String
    var lovePrice: String
    var free: String
    var earlyBirdPrice: String
    
    var city: String
    var location: String
    var address: String
    
    var equipments: [String]?
    
    var latitude: String
    var longtitude: String
    
    //評價
    var evaluation: Evaluation?
}

struct Evaluation: Hashable {
    
    var number: Int
    var allCommentCount: Int
    var allCommentStar: Int
    var allCommentRate: [CommentRate]
    var allCommentContents: [CommentContent]
    
    struct CommentContent: Hashable {
        var userImage: String
        var userName: String
        var star: Int
        var commentDate: String
        var commentRate: [CommentRate]
    }
}

struct CommentRate: Hashable {
    var contentRichness: Double
    var equipment: Double
    var geoLocation: Double
    var price: Double
    var service: Double
}

// MARK: - Dictionary Conversion

extension ExhibitionInfo {
    static func from(_ data: [String: Any]) -> ExhibitionInfo? {
        guard let title = data["title"] as? String,
              let image = data["imageUrl"] as? String,
              let dateString = data["startDate"] as? String,
              let agency = data["subUnit"] as? [String],
              let official = data["showUnit"] as? String,
              let showInfo = data["showInfo"] as? [[String: Any]],
              let price = showInfo.first?["price"] as? String,
              let time = showInfo.first?["time"] as? String,
              let latitude = showInfo.first?["latitude"] as? String,
              let longitude = showInfo.first?["longitude"] as? String,
              let location = showInfo.first?["locationName"] as? String,
              let address = showInfo.first?["location"] as? String else { return nil }
        return ExhibitionInfo(
            title: title,
            image: image.isEmpty ? "defaultExhibition" : image,
            tag: "一般",
            dateString: dateString,
            time: time,
            agency: agency.joined(),
            official: official,
            telephone: "",
            advanceTicketPrice: price,
            unanimousVotePrice: price,
            studentPrice: price,
            groupPrice: price,
            lovePrice: price,
            free: "",
            earlyBirdPrice: "",
            city: String(location.prefix(3)),
            location: location,
            address: address,
            latitude: latitude,
            longtitude: longitude
        )
    }
}
