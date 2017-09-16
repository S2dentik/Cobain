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

    var isAlpha: Bool {
        return "a" ... "z" ~= self || "A" ... "Z" ~= self
    }

    var isAlphanumeric: Bool {
        return isAlpha || "0" ... "9" ~= self
    }

    var isDigitOrDot: Bool {
        return "0" ... "9" ~= self || self == "."
    }

    var isHash: Bool {
        return self == "#"
    }

    var isNewline: Bool {
        return self == "\n" || self == "\r"
    }
}
