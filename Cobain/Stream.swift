//
//  Stream.swift
//  Cobain
//
//  Created by Alexandru Culeva on 3/1/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

class Stream {
    
    private var string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    /// Reads first character of the stream and consumes it
    func read() -> Character? {
        guard let firstChar = string.first else { return nil }
        string = string.droppingFirst
        return firstChar
    }
    
    /// Reads first character of the stream without consuming it
    func stalk() -> Character? {
        return string.first
    }
    
    /// Consumes first character of the stream and returns the remaining string
    func consume() -> Stream {
        string = string.droppingFirst
        return self
    }
}
