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
    case failure(Error)
    case success(T)
    
    public var value: T? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public enum TrelloError: Error {
    case networkError(error: NSError?)
    case jsonError(error: Error?)
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

open class Trello {
    
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
    public func getAllBoards(_ completion: @escaping (Result<[Board]>) -> Void) {
        let url = try! Router.allBoards.asURL()
        
        Alamofire.request(url, parameters: self.authParameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let boards = try [Board].decode(json)
                completion(.success(boards))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
        let parameters = self.authParameters
            .with(["cards": cardType.rawValue as AnyObject])
            .with(["lists": listType.rawValue as AnyObject])
            .with(["members": memberType.rawValue as AnyObject])
        
        Alamofire.request(Router.board(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let board = try Board.decode(json)
                completion(.success(board))
            } catch {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
}

// MARK: Lists
extension Trello {
    public func getListsForBoard(_ id: String, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters.with(["filter": filter.rawValue as AnyObject])
        
        Alamofire.request(Router.lists(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let lists = try [CardList].decode(json)
                completion(.success(lists))
            } catch {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
            getListsForBoard(board.id, completion: completion)
    }
}


// MARK: Cards
extension Trello {
    public func getCardsForList(_ id: String, withMembers: Bool = false, completion: @escaping (Result<[Card]>) -> Void) {
        let parameters = self.authParameters.with(["members": withMembers as AnyObject])
        
        Alamofire.request(Router.cardsForList(listId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let cards = try [Card].decode(json)
                completion(.success(cards))
            } catch {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
}


// Member API
extension Trello {
    public func getMember(_ id: String, completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(Router.member(id: id), parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let member = try Member.decode(json)
                completion(.success(member))
            } catch {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getMembersForCard(_ cardId: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(Router.member(id: cardId), parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            do {
                let members = try [Member].decode(json)
                completion(.success(members))
            } catch {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getAvatarImage(_ avatarHash: String, size: AvatarSize, completion: @escaping (Result<Image>) -> Void) {
        Alamofire.request("https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error as NSError?)))
                return
            }
            
            completion(.success(image))
        }
    }
    
    public enum AvatarSize: Int {
        case small = 30
        case large = 170
    }
}


private enum Router: URLConvertible {

    static let baseURLString = "https://api.trello.com/1/"
    
    case search
    case allBoards
    case board(boardId: String)
    case lists(boardId: String)
    case cardsForList(listId: String)
    case member(id: String)
    case membersForCard(cardId: String)
    
    func asURL() throws -> URL {
        switch self {
        case .search:
            return URL(string: Router.baseURLString + "search/")!
        case .allBoards:
            return URL(string: Router.baseURLString + "members/me/boards/")!
        case .board(let boardId):
            return URL(string: Router.baseURLString + "boards/\(boardId)/")!
        case .lists(let boardId):
            return URL(string: Router.baseURLString + "boards/\(boardId)/lists/")!
        case .cardsForList(let listId):
            return URL(string: Router.baseURLString + "lists/\(listId)/cards/")!
        case .member(let memberId):
            return URL(string: Router.baseURLString + "members/\(memberId)/")!
        case .membersForCard(let cardId):
            return URL(string: Router.baseURLString + "cards/\(cardId)/members/")!
        }

    }
}

extension Dictionary {
    func with (_ other: [Key: Value]) -> [Key: Value] {
        var mergedDict: [Key: Value] = [:]
        [self, other].forEach { dict in
            for (key, value) in dict {
                mergedDict[key] = value
            }
        }
        return mergedDict
    }
}
