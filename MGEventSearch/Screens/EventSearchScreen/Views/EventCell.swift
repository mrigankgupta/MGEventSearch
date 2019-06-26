//
//  EventCell.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var preview: RoundCornerImageView!
    @IBOutlet weak var favorited: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        preview.image = nil
        venue.text = nil
    }

    func configure(event: EventDetail) {
        title.text = event.eventName
        date.text = event.date
        venue.text = event.location
        if let imageURL = event.imageURL {
            preview.kf.setImage(with: imageURL)
        } else {
            preview.image = UIImage(assetIdentifier: .noImage)
        }
        favorited.isHidden = !event.favorite
    }
}
