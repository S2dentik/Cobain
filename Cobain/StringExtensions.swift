//
//  StringExtensions.swift
//  Cobain
//
//  Created by Alexandru Culeva on 3/1/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

extension String {
    var first: Character? {
        return characters.first
    }
    
    var droppingFirst: String {
        return String(characters.dropFirst())
    }
}
