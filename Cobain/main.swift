//
//  main.swift
//  Cobain
//
//  Created by Alexandru Culeva on 2/28/17.
//  Copyright © 2017 Alexandru Culeva. All rights reserved.
//

import Foundation

let stream = Stream("""
motif add() {
    return 1+1; #just adds these two numbers
}
""")

let tokens = Lexer(stream: stream).tokens
print(tokens)
