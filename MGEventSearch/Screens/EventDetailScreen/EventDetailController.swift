//
//  EventDetailController.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 14/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

class EventDetailController {

    func saveIn(plist: String, eventID: String) -> EventDict {
        let plistStore = PlistStore()
        let old: Favorite? = plistStore.fetch(at: plist)
        var new: Favorite
        if let old = old {
            new = old
            var add = old.all
            add[eventID] = true
            new.all = add
        } else {
            new = Favorite(all: [eventID: true])
        }
        DispatchQueue.global().async {
            plistStore.save(data: new, at: favPlist)
        }
        return new.all
    }

}
