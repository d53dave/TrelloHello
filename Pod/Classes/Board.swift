//
//  Board.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Board {
    public let id: String
    public let name: String
    public let description: String?
    public let url: String?
    public let closed: Bool?
    public let organizationId: String?
    public let lists: [CardList]?
    public let cards: [Card]?
    public let members: [Member]?
}

extension Board: Decodable {
    public static func decode(_ json: Any) throws -> Board {
        return try Board(id: json => "id",
                         name: json => "name",
                         description: json =>? "desc",
                         url: json =>? "url",
                         closed: json =>? "closed",
                         organizationId: json =>? "idOrganization",
                         lists: json =>? "lists",
                         cards: json =>? "cards",
                         members: json =>? "members")
    }
}
