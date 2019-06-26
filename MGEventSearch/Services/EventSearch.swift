//
//  EventSearch.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

private let searchRESTMethod = "/2/events"
private let baseURL = "api.seatgeek.com"

protocol EventSearching: class {
    func result(events: [Event])
    func fail(err: AppError)
}
/* READ ME: - Please put the key for testing
 Can be improved:
    1. I have not written UT as it was not under the scope of instruction.
    Although code is written in a way that its pretty much testable Ready
    2. Assuming that UX is not in scope but details are. UI might be not 100% same as given in test link
    because I would require images as well as UX. Some images like placeholders are blurs as I
    did not find images in short time.
 Addressed
    1. Thin Network client with Error handling
    2. O(n) search for Favorite using dictionary */
class EventSearch {
    // Please put Your private seatgeek key here
    private lazy var service = WebService(baseURL: baseURL, parameters: ["client_id": "MTExODQ1MDd8MTUyMzQ0NTU2Ny43OQ"])
    private weak var last: URLSessionTask?
    public weak var delegate: EventSearching?

    func search(with query: String) {
        if query.isEmpty {
            delegate?.result(events: [])
            return
        }
        let queryDic = ["q": query]
        let parse: (Data) -> [Event]? = { (data) -> [Event]? in
            let jsdec = JSONDecoder()
            var result: EventResponse?
            do {
                jsdec.dateDecodingStrategy = .formatted(.customISO8601)
                result = try jsdec.decode(EventResponse.self, from: data)
            } catch let err {
                print("not parsing", err)
            }
            return result?.events
        }
        guard let allEvents = try? service.prepareResource(pathForREST: searchRESTMethod, argsDict: queryDic, parse: parse) else {
            delegate?.result(events: [])
            return
        }
        last = service.getMe(res: allEvents) { [weak self] (result) in
            switch result {
            case let .success(events):
                self?.delegate?.result(events: events)
            case let .failure(err):
                self?.delegate?.fail(err: err)
            }
        }
    }

    func cancel() {
        last?.cancel()
    }
}
