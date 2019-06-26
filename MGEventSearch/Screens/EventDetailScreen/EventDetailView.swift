//
//  EventDetailController.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import UIKit
import Kingfisher

protocol FavoritedEvent: class {
    func doneFavorite(eventDict: EventDict)
}

class EventDetailView: UIViewController {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var eventImage: UIImageView!

    var details: EventDetail
    weak var delegate: FavoritedEvent?
    private lazy var eventDetailCont = EventDetailController()

    init(details: EventDetail) {
        self.details = details
        super.init(nibName: String(describing: type(of: self)), bundle: .main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarApperance()
        setEventDetails()
    }

    // MARK: - Private Methods
    private func setNavigationBarApperance() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = details.eventName
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
        if let subviews = self.navigationController?.navigationBar.subviews {
            for navItem in subviews {
                for itemSubView in navItem.subviews {
                    if let largeLabel = itemSubView as? UILabel {
                        largeLabel.text = self.title
                        largeLabel.numberOfLines = 0
                        largeLabel.lineBreakMode = .byWordWrapping
                    }
                }
            }
        }
        navigationController?.navigationBar.barTintColor = .white
        let rightButton = UIBarButtonItem(image: UIImage(assetIdentifier: .bookmark),
                                          style: .done, target: self, action: #selector(self.save))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.tintColor = .red
    }

    private func setEventDetails() {
        date.text = details.date
        venue.text = details.location
        if let imageURL = details.imageURL {
            eventImage.kf.setImage(with: imageURL, placeholder:
                UIImage(assetIdentifier: .placeholderBig))
        } else {
            eventImage.backgroundColor = .gray
            eventImage.image = UIImage(assetIdentifier: .noImage)
            eventImage.contentMode = .scaleAspectFit
        }
    }

    @objc func save() {
        let saved = eventDetailCont.saveIn(plist: favPlist, eventID: details.eventID)
        delegate?.doneFavorite(eventDict: saved)
    }
}
