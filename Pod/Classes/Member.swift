//
//  Member.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Member {
    public let id: String
    public let avatarHash: String?
    public let bio: String?
    public let confirmed: Bool?
    public let fullName: String?
    public let initials: String?
    public let username: String?
    public let email: String?
}

extension Member: Decodable {
    public static func decode(_ json: Any) throws -> Member {
        return try Member(id: json => "id",
                          avatarHash: json =>? "avatarHash",
                          bio: json =>? "bio",
                          confirmed: json =>? "confirmed",
                          fullName: json =>? "fullName",
                          initials: json =>? "initials",
                          username: json =>? "username",
                          email: json =>? "email")

    }
}
