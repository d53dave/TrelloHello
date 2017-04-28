//
//  Label.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Label {
    public let id: String
    public let name: String?
    public let color: String
    public let boardId: String?
    public let uses: Int?
}

extension Label: Decodable {
    public static func decode(_ json: Any) throws -> Label {
        return try Label(id: json => "id",
                         name: json =>? "name",
                         color: json => "color",
                         boardId: json =>? "idBoard",
                         uses: json =>? "uses")
    }
}
