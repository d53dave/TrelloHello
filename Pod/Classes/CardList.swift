//
//  CardList.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct CardList {
    public let id: String
    public let name: String
    public let boardId: String?
    public let pos: Int?
    public let subscribed: Bool?
    public let closed: Bool?
}

extension CardList: Decodable {
    public static func decode(_ json: Any) throws -> CardList {
        return try CardList(id: json => "id",
                            name: json => "name",
                            boardId: json =>? "idBoard",
                            pos: json =>? "pos",
                            subscribed: json =>? "subscribed",
                            closed: json =>? "closed")

    }
}
