//
//  EventInteractor.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

let favPlist = "FavPlistStore"

class EventListController {

    var dataChanged: (() -> Void)?
    var stateChanged: ((SearchState) -> Void)?
    private var eventSearch: EventSearch
    private var events: [Event] = []
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy hh:mm aaa"
        formatter.locale = Locale(identifier: "enUS")
        return formatter
    }()
    // MARK: - Callbacks
    private var cellEventDetails: [EventDetail] = [EventDetail]() {
        didSet {
            dataChanged?()
        }
    }

    var saved: Favorite = Favorite() {
        didSet {
            recomputeCellModel()
        }
    }

    private(set) var searchState: SearchState = .initial {
        didSet {
            stateChanged?(searchState)
        }
    }

    init() {
        eventSearch = EventSearch()
        eventSearch.delegate = self
    }

    func refresh() {
        if let fav: Favorite = PlistStore().fetch(at: favPlist) {
            saved = fav
        }
    }

    func cancelPressed() {
        searchState = .initial
    }

    func search(with query: String) {
        eventSearch.search(with: query)
    }

    func cancelLastRequest() {
        eventSearch.cancel()
    }

    func numberOfRows() -> Int {
        return cellEventDetails.count
    }

    func details(for row: Int) -> EventDetail {
        return cellEventDetails[row]
    }

    private func modelEventData(_ event: Event) -> EventDetail {
        let displayDate = formatter.string(from: event.localDateTime)
        let imageURL: URL? = event.performers.count > 0 ? event.performers[0].image : nil
        let eventIdString = String(event.eventId)
        let favorite = saved.all[eventIdString] != nil
        return EventDetail.init(eventID: eventIdString, eventName: event.title,
                                date: displayDate, location: event.venue.location,
                                imageURL: imageURL, favorite: favorite)
    }

    private func recomputeCellModel() {
        cellEventDetails = events.map { modelEventData($0) }
    }
}

extension EventListController: EventSearching {
    func fail(err: AppError) {
        guard case .networkError(let ntwErr) = err, ntwErr.code != .cancelled else { return }
        searchState = .error(err)
    }

    func result(events: [Event]) {
        searchState = events.count > 0 ? .loaded : .noData
        self.events = events
        recomputeCellModel()
    }
}
