//
//  Card.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Card {
    public let id: String
    public let name: String
    public let description: String?
    public let closed: Bool?
    public let position: Int?
    public let dueDate: Date?
    public let listId: String?
    public let memberIds: [String]?
    public let boardId: String?
    public let shortURL: String?
    public let labels: [Label]?
}

extension Card: Decodable {
    fileprivate static var isoDateFormatter = Card.isoDateFormatterInit()
    
    fileprivate static func isoDateFormatterInit() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") as Locale!
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter
    }
    
    public static func decode(_ json: Any) throws -> Card {
        let dueDate: Date?
        
        if let jsonDate = try json =>? "due" as! String? {
            dueDate = Card.isoDateFormatter.date(from: jsonDate)!
        } else {
            dueDate = nil
        }
        
        return try Card(id: json => "id",
                        name: json => "name",
                        description: json =>? "description",
                        closed: json =>? "closed",
                        position: json =>? "position",
                        dueDate: dueDate,
                        listId: json =>? "idList",
                        memberIds: json =>? "idMembers",
                        boardId: json =>? "idBoard",
                        shortURL: json =>? "shortUrl",
                        labels: json =>? "labels")
    }
}
