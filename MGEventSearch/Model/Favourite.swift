//
//  Favourite.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 11/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

typealias EventDict = [String: Bool]

struct Favorite: Codable {
    var all: EventDict
    init(all: EventDict = [:]) {
        self.all = all
    }
}
