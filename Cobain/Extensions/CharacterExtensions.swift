//
//  CharacterExtensions.swift
//  Cobain
//
//  Created by Alexandru Culeva on 8/19/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

extension Character {
    static let space = Character(" ")
    static let hash = Character("#")
    static let dot = Character(".")
    static let newline = Character("\n")
    static let carriageReturn = Character("\r")

    var isAlpha: Bool {
        return "a" ... "z" ~= self || "A" ... "Z" ~= self
    }

    var isDigit: Bool {
        return "0" ... "9" ~= self
    }

    var isHash: Bool {
        return self == .hash
    }

    var isDot: Bool {
        return self == .dot
    }

    var isAlphanumeric: Bool {
        return isAlpha || isDigit
    }

    var isDigitOrDot: Bool {
        return isDigit || isDot
    }

    var isNewline: Bool {
        return self == .newline || self == .carriageReturn
    }
}
