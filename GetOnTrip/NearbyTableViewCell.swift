//
//  NearbyTableViewCell.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/7/24.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit

class NearbyTableViewCell: UITableViewCell {

    // MASK: Outlets

    @IBOutlet weak var topicImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var desc: UILabel!
    @IBOutlet var scan: UILabel!
    @IBOutlet var favorites: UILabel!
    
    var topicImage: UIImage? {
        didSet{
            topicImageView.image = topicImage
        }
    }
    
    var topicImageUrl:String? {
        didSet{
            if let url = topicImageUrl {
                if url != "" {
                    ImageLoader.sharedLoader.imageForUrl(url) { (image:UIImage?, url:String) in
                        self.topicImage = image
                    }
                }
            }
            if self.topicImage == nil {
                self.topicImage = UIImage(named: "default-topic")
            }
        }
    }
    
    var title:String? {
        didSet {
            if let newTitle = title {
                self.titleLabel.text = newTitle
            }
        }
    }
    
    var subtitle:String? {
        didSet {
            if let newTitle = subtitle {
                self.subtitleLabel.text = newTitle
            }
        }
    }
    
    var favoritesValue:String? {
        didSet {
            if let newFavorites = favoritesValue {
                self.favorites.text = newFavorites
            }
        }
    }
    
    var descValue:String? {
        didSet {
            if let newValue = descValue {
                self.desc.text = newValue
            }
        }
    }
    
    var scanValue:String? {
        didSet {
            if let newValue = scanValue {
                self.scan.text = newValue
            }
        }
    }
    
}
