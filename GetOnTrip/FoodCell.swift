//
//  FoodTableViewCell.swift
//  GetOnTrip
//
//  Created by 王振坤 on 16/1/18.
//  Copyright © 2016年 Joshua. All rights reserved.
//

import UIKit

class FoodCell: UITableViewCell {

    /// 图片
    lazy var iconView: UIImageView = UIImageView()
    ///  标题
    lazy var titleLabel: UILabel = UILabel(color: UIColor.blackColor(), title: "炒肝儿", fontSize: 18, mutiLines: false, fontName: Font.PingFangSCRegular)
    ///  副标题
    lazy var subtitleLabel: UILabel = UILabel(color: UIColor.blackColor(), title: "炒肝儿是北京地区著名的汉族传统", fontSize: 14, mutiLines: false, fontName: Font.PingFangSCLight)
    /// 必玩文字
    lazy var compulsoryLabel = UILabel(color: .whiteColor(), title: "必吃", fontSize: 8, mutiLines: true, fontName: Font.PingFangSCRegular)
    /// 必玩底部
    lazy var compulsoryView: CompulsoryPlayView = CompulsoryPlayView(color: .clearColor())
    /// 基线
    lazy var baseLine: UIView = UIView(color: UIColor(hex: 0x979797, alpha: 0.3))
    /// 商家数量
    lazy var shopNumLabel: UILabel = UILabel(color: SceneColor.originYellow, title: "12", fontSize: 12, mutiLines: true, fontName: Font.PingFangSCLight)
    /// 商家
    lazy var shopLabel: UILabel = UILabel(color: SceneColor.originYellow, title: "家名店推荐，", fontSize: 9, mutiLines: true, fontName: Font.PingFangSCLight)
    /// 话题数量
    lazy var topicNumLabel: UILabel = UILabel(color: SceneColor.originYellow, title: "12", fontSize: 12, mutiLines: true, fontName: Font.PingFangSCLight)
    /// 话题
    lazy var topicLabel: UILabel = UILabel(color: SceneColor.originYellow, title: "个相关话题", fontSize: 9, mutiLines: true, fontName: Font.PingFangSCLight)
    
    var data: AnyObject? {
        didSet {
            if let cellData = data as? Food {
                iconView.backgroundColor = cellData.bgColor
                //是否加载网络图片
                if UserProfiler.instance.isShowImage() {
                    iconView.sd_setImageWithURL(NSURL(string: cellData.image))
                }
                
                shopNumLabel.text = cellData.shopNum
                topicNumLabel.text = cellData.topicNum
                compulsoryView.hidden  = cellData.desc == "" ? true : false
                compulsoryLabel.hidden = cellData.desc == "" ? true : false
                compulsoryLabel.text   = cellData.desc
                
                subtitleLabel.attributedText = cellData.content.getAttributedString(0, lineSpacing: 1, breakMode: .ByTruncatingTail, fontName: Font.PingFangSCLight, fontSize: 14)
                titleLabel.text        = cellData.title
            }
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(iconView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(baseLine)
        contentView.addSubview(compulsoryView)
        contentView.addSubview(compulsoryLabel)
        contentView.addSubview(shopNumLabel)
        contentView.addSubview(shopLabel)
        contentView.addSubview(topicNumLabel)
        contentView.addSubview(topicLabel)

        let w: CGFloat = Frame.screen.width - 133 - 24
        subtitleLabel.numberOfLines = 2
        subtitleLabel.preferredMaxLayoutWidth = w
        let rotate: CGFloat = CGFloat(M_PI_2) * 0.5
        compulsoryLabel.transform = CGAffineTransformMakeRotation(-rotate)
        
        iconView.ff_AlignInner(.CenterLeft, referView: contentView, size: CGSizeMake(133, 84), offset: CGPointMake(9, 0))
        titleLabel.ff_AlignHorizontal(.TopRight, referView: iconView, size: CGSizeMake(w, 19), offset: CGPointMake(6, -2))
        subtitleLabel.ff_AlignVertical(.BottomLeft, referView: titleLabel, size: nil, offset: CGPointMake(0, 5))
        baseLine.ff_AlignInner(.BottomCenter, referView: contentView, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 18, 0.5))
        compulsoryView.ff_AlignInner(.TopLeft, referView: iconView, size: CGSizeMake(24, 24), offset: CGPointMake(-1, -1))
        compulsoryLabel.ff_AlignInner(.TopLeft, referView: iconView, size: nil, offset: CGPointMake(0, 2))
        shopNumLabel.ff_AlignHorizontal(.BottomRight, referView: iconView, size: nil, offset: CGPointMake(5, 3))
        shopLabel.ff_AlignHorizontal(.CenterRight, referView: shopNumLabel, size: nil)
        topicNumLabel.ff_AlignHorizontal(.CenterRight, referView: shopLabel, size: nil)
        topicLabel.ff_AlignHorizontal(.CenterRight, referView: topicNumLabel, size: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
    }
}
