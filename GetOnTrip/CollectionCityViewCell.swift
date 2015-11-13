//
//  CollectionCityViewCell.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/6.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout
import SVProgressHUD

// MARK: - CollectTopicCell
class CollectCityCell: UICollectionViewCell {
    
    lazy var iconView: UIImageView = UIImageView()
    
    lazy var cityName: UILabel = UILabel(color: UIColor.whiteColor(), title: "", fontSize: 16, mutiLines: true)
    
    lazy var topicNum: UILabel = UILabel(color: UIColor(hex: 0xFFFFFF, alpha: 0.7), title: "", fontSize: 11, mutiLines: false)
    
    var collectCity: CollectCity? {
        didSet {
            iconView.sd_setImageWithURL(NSURL(string: collectCity!.image), placeholderImage:PlaceholderImage.defaultSmall)
            cityName.text = collectCity!.name
            topicNum.text = collectCity!.topicNum
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(cityName)
        addSubview(topicNum)
        iconView.contentMode   = UIViewContentMode.ScaleAspectFill
        iconView.clipsToBounds = true
        setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAutoLayout() {
        iconView.frame = bounds
        cityName.ff_AlignInner(ff_AlignType.CenterCenter, referView: self, size: nil, offset: CGPointMake(0, 0))
        topicNum.ff_AlignInner(ff_AlignType.BottomCenter, referView: self, size: nil, offset: CGPointMake(0, -11))
    }
    
}
