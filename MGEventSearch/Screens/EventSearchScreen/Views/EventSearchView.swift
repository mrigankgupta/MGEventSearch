//
//  ViewController.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

class EventSearchView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: ErrorView!

    private var cancelled: Bool = false
    private var timer: Timer?
    lazy var eventList = EventListController()

    private var rowHeight: CGFloat {
        let cellDefaultHeight: CGFloat = 100
        let screenDefaultHeight: CGFloat = 480
        let factor: CGFloat = cellDefaultHeight/screenDefaultHeight
        return factor * UIScreen.main.bounds.size.height
    }

    init() {
        super.init(nibName: String(describing: type(of: self)), bundle: .main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overriden ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: EventCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: EventCell.self))
        setApperanceOnViewDidAppear()
        eventList.dataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        eventList.stateChanged = displayStateChange
        displayStateChange(state: eventList.searchState)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarApperanceOnViewWillAppear()
        eventList.refresh()
    }
    // MARK: - Private
    private func displayStateChange(state: SearchState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .initial:
                self?.tableView.isHidden = true
                self?.errorView.isHidden = true
            case .loaded:
                self?.tableView.isHidden = false
                self?.errorView.isHidden = true
            case .noData:
                self?.tableView.isHidden = true
                self?.errorView.isHidden = false
                self?.errorView.errorMessage.text = "Please try different! Unable to find content with search query."
            case .error:
                self?.tableView.isHidden = true
                self?.errorView.isHidden = false
                self?.errorView.errorMessage.text = "Something went wrong. Check your connection."
            }
        }
    }

    private func setApperanceOnViewDidAppear() {
        tableView.dataSource = self
        tableView.delegate = self
        createSearchBar()
        self.definesPresentationContext = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func createSearchBar() {
        guard navigationItem.searchController == nil else { return }
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "search events..."
        search.searchBar.tintColor = .white
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setNavigationBarApperanceOnViewWillAppear() {
        navigationController?.navigationBar.barTintColor =
            UIColor(red: 18/255.0, green: 41/255.0, blue: 59/255.0, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

}

extension EventSearchView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventDetailView = EventDetailView(details: eventList.details(for: indexPath.row))
        navigationItem.searchController?.resignFirstResponder()
        navigationController?.pushViewController(eventDetailView, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

extension EventSearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cancelled = false
        eventList.cancelLastRequest()
        searchTimerCancel()
        if let query = searchBar.text, !query.isEmpty {
            searchTimerStart(query: query)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        search(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        eventList.cancelPressed()
        cancelled = true
        tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    // MARK: - Search Bar supporting method
    private func search(_ barText: String) {
        eventList.cancelLastRequest()
        eventList.search(with: barText)
    }

    private func searchTimerStart(query: String) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:
            #selector(self.fireQuery(timer:)), userInfo: query, repeats: false)
    }

    private func searchTimerCancel() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
    }

    @objc func fireQuery(timer: Timer) {
        if let query = timer.userInfo as? String {
            if !cancelled {
                search(query)
            }
        }
    }
}

extension EventSearchView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return eventList.numberOfRows() }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let details = eventList.details(for: indexPath.row)
        cell.configure(event: details)
        return cell
    }
}

extension EventSearchView: FavoritedEvent {
    func doneFavorite(eventDict: EventDict) {
        eventList.saved.all = eventDict
    }
}
