//
//  UIImage+Addition.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 13/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    enum AssetIdentifier: String {
        case bookmark = "bookmark"
        case placeholderBig = "placeholder-Big"
        case noImage = "No image"
    }
    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)!
    }
}
