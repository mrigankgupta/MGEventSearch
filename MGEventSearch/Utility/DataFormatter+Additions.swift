//
//  DataFormatter+Aditions.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let customISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
