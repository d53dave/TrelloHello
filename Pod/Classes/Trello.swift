//
//  Trello.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Alamofire
import AlamofireImage

public enum Result<T> {
    case Failure(Error)
    case Success(T)
    
    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}

public enum TrelloError: Error {
    case NetworkError(error: NSError?)
    case JSONError(error: Error?)
}

public enum ListType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
}

public enum CardType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
    case Visible = "visible"
}

public enum MemberType: String {
    case Admins = "admins"
    case All = "all"
    case None = "none"
    case Normal = "normal"
    case Owners = "owners"
}

public class Trello {
    
    let authParameters: [String: AnyObject]
    
    public init(apiKey: String, authToken: String) {
        self.authParameters = ["key": apiKey as AnyObject, "token": authToken as AnyObject]
    }
    
    // TODO: The response end of this is tough
//    public func search(query: String, partial: Bool = true) {
//        let parameters = authParameters + ["query": query] + ["partial": partial]
//        
//        Alamofire.request(.GET, Router.Search, parameters: parameters).responseJSON { (let response) in
//            print("Search Response \(response.result)")
//            // Returns a list of actions, boards, cards, members, and orgs that match the query
//        }
//    }
}

extension Trello {
    // MARK: Boards
    public func getAllBoards(completion: @escaping (Result<[Board]>) -> Void) {
        Alamofire.request(Router.AllBoards, method: .get, parameters: self.authParameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let boards = try [Board].decode(json)
                completion(.Success(boards))
            } catch (let error) {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getBoard(id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
        let parameters = self.authParameters
            .with(other: ["cards": cardType.rawValue as AnyObject])
            .with(other: ["lists": listType.rawValue as AnyObject])
            .with(other: ["members": memberType.rawValue as AnyObject])
        
        Alamofire.request(Router.Board(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let board = try Board.decode(json)
                completion(.Success(board))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
}

// MARK: Lists
extension Trello {
    public func getListsForBoard(id: String, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters.with(other: ["filter": filter.rawValue as AnyObject])
        
        Alamofire.request(Router.Lists(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let lists = try [CardList].decode(json)
                completion(.Success(lists))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getListsForBoard(board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        getListsForBoard(id: board.id, filter: filter, completion: completion)
    }
}


// MARK: Cards
extension Trello {
    public func getCardsForList(id: String, withMembers: Bool = false, completion: @escaping (Result<[Card]>) -> Void) {
        let parameters = self.authParameters.with(other: ["members": withMembers as AnyObject])
        
        Alamofire.request(Router.CardsForList(listId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let cards = try [Card].decode(json)
                completion(.Success(cards))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
}


// Member API
extension Trello {
    public func getMember(id: String, completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(Router.Member(id: id), parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let member = try Member.decode(json)
                completion(.Success(member))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getMembersForCard(cardId: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(Router.Member(id: cardId), parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let members = try [Member].decode(json)
                completion(.Success(members))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getAvatarImage(avatarHash: String, size: AvatarSize, completion: @escaping (Result<Image>) -> Void) {
        Alamofire.request("https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error as NSError?)))
                return
            }
            
            completion(.Success(image))
        }
    }
    
    public enum AvatarSize: Int {
        case Small = 30
        case Large = 170
    }
}


private enum Router: URLConvertible {

    static let baseURLString = "https://api.trello.com/1/"
    
    case Search
    case AllBoards
    case Board(boardId: String)
    case Lists(boardId: String)
    case CardsForList(listId: String)
    case Member(id: String)
    case MembersForCard(cardId: String)
    
    func asURL() throws -> URL {
        switch self {
        case .Search:
            return URL(string: Router.baseURLString + "search/")!
        case .AllBoards:
            return URL(string: Router.baseURLString + "members/me/boards/")!
        case .Board(let boardId):
            return URL(string: Router.baseURLString + "boards/\(boardId)/")!
        case .Lists(let boardId):
            return URL(string: Router.baseURLString + "boards/\(boardId)/lists/")!
        case .CardsForList(let listId):
            return URL(string: Router.baseURLString + "lists/\(listId)/cards/")!
        case .Member(let memberId):
            return URL(string: Router.baseURLString + "members/\(memberId)/")!
        case .MembersForCard(let cardId):
            return URL(string: Router.baseURLString + "cards/\(cardId)/members/")!
        }

    }
}

extension Dictionary {
    func with (other: [Key: Value]) -> [Key: Value] {
        var mergedDict: [Key: Value] = [:]
        [self, other].forEach { dict in
            for (key, value) in dict {
                mergedDict[key] = value
            }
        }
        return mergedDict
    }
}
