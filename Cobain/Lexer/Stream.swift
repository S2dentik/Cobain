//
//  Stream.swift
//  Cobain
//
//  Created by Alexandru Culeva on 3/1/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

class Stream<T: Collection & SubsequenceInitializable> {
    
    private var sequence: T
    
    init(_ sequence: T) {
        self.sequence = sequence
    }
    
    /// Reads first character of the stream and consumes it
    func read() -> T.Element? {
        guard let firstChar = sequence.first else { return nil }
        sequence = sequence.droppingFirst
        return firstChar
    }
    
    /// Reads first character of the stream without consuming it
    func stalk() -> T.Element? {
        return sequence.first
    }
    
    /// Consumes first character of the stream and returns the remaining string
    func consume() -> Stream<T> {
        sequence = sequence.droppingFirst
        return self
    }
}
