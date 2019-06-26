//
//  EventResponse.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 11/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

struct EventResponse: Codable {
    let events: [Event]?
}

struct Event: Codable {
    let title: String
    let localDateTime: Date
    let eventId: Int
    let venue: Venue
    let performers: [Performers]
    private enum CodingKeys: String, CodingKey {
        case title
        case localDateTime = "datetime_local"
        case eventId = "id"
        case venue
        case performers
    }
}

struct Venue: Codable {
    let name: String
    let location: String?
    private enum CodingKeys: String, CodingKey {
        case name
        case location = "display_location"
    }
}

struct Performers: Codable {
    let image: URL?
}
