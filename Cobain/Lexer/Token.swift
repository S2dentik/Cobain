//
//  Token.swift
//  Cobain
//
//  Created by Alexandru Culeva on 3/1/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

enum Token {
    case motif // Function
    case extern // External
    case identifier(String)
    case number(Double)
    case unknown(Character)
    
    init(identifier: String) {
        switch identifier {
        case "motif": self = .motif
        case "extern": self = .extern
        default: self = .identifier(identifier)
        }
    }
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.motif, .motif), (.extern, .extern): return true
        case let (.identifier(lID), .identifier(rID)): return lID == rID
        case let (.number(lNumber), .number(rNumber)): return lNumber == rNumber
        case let (.unknown(lChar), .unknown(rChar)): return lChar == rChar
        default: return false
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case .motif: return "motif"
        case .extern: return "extern"
        case let .identifier(id): return id
        case let .number(number): return String(number)
        case let .unknown(char): return String(char)
        }
    }
}
