//
//  EventDisplay.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 11/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

struct EventDetail {
    let eventID: String
    let eventName: String
    let date: String
    let location: String?
    let imageURL: URL?
    let favorite: Bool
}

enum SearchState {
    case initial
    case noData
    case loaded
    case error(Error)
}
