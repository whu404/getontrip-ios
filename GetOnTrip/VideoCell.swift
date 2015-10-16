//
//  VideoCell.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/8/21.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class VideoCell: UITableViewCell {

    lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "2.jpg"))
    
    lazy var titleLabel: UILabel = UILabel(color: UIColor.whiteColor(), title: "故宫的至宝", fontSize: 18, mutiLines: true)
    
    lazy var timeLabel: UILabel = UILabel(color: UIColor(hex: 0xFFFFFF, alpha: 0.5), title: "时长：2小时", fontSize: 12, mutiLines: true)
    
    lazy var watchBtn: UIButton = UIButton(title: "点击观看", fontSize: 12, radius: 12)
    
    lazy var visual: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    var video: SightVideo? {
        didSet {
            iconView.image = nil
            iconView.sd_setImageWithURL(NSURL(string: video!.image!), placeholderImage: UIImage(named: "2.jpg"))
            titleLabel.text = video!.title!
            timeLabel.text = video!.len!
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupProperty()
        setupAutoLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupProperty() {
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(watchBtn)
        iconView.addSubview(visual)
        
        visual.alpha = 0.5
        watchBtn.layer.borderWidth = 1.0
        watchBtn.layer.borderColor = UIColor.yellowColor().CGColor
    }
    
    private func setupAutoLayout() {
        
        iconView.ff_AlignInner(ff_AlignType.TopLeft, referView: self, size: CGSizeMake(UIScreen.mainScreen().bounds.width, 199))
        titleLabel.ff_AlignInner(ff_AlignType.CenterCenter, referView: self, size: nil, offset: CGPointMake(0, 10))
        timeLabel.ff_AlignInner(ff_AlignType.TopLeft, referView: self, size: nil, offset: CGPointMake(19, 9))
        watchBtn.ff_AlignVertical(ff_AlignType.BottomCenter, referView: titleLabel, size: CGSizeMake(83, 28), offset: CGPointMake(0, 7))
        visual.ff_AlignInner(ff_AlignType.TopLeft, referView: iconView, size: CGSizeMake(UIScreen.mainScreen().bounds.width, 199), offset: CGPointMake(0, 0))
    }
}