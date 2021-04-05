//
//  CustomPhotoCell.swift
//  pixel-city
//
//  Created by Jeff Umandap on 4/5/21.
//

import UIKit

class CustomPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var pullUpImg : UIImageView!
    @IBOutlet weak var pullUpImgViewCounts : UILabel!
    
    func updateViews(forImage image: UIImage, forViewCounts views: String) {
        pullUpImg.image = image
        pullUpImgViewCounts.text = views
    }
}
