//
//  ScrolledImageView.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/8/28.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit
import SDWebImage

class ScrolledImageView: UIView {
    
    // MARK: Properties
    
    //ImageView比View上下分别增高量
    var extra:CGFloat = 30
    
    //图片View
    var imageView:UIImageView = UIImageView()
    
    //ImageView的y轴偏移因子 [-1.0, 1.0]， 注意y以UIView为基准
    //默认yOffset=0, 上拉最大幅度时yOffset=extra, 下拉最大幅度yOffset=-extra
    //对应factor=0.0, 1.0, -1.0
    private var factor:CGFloat = 0.0
    
    // MARK: View Life Circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI(){
        self.clipsToBounds   = true
        
        self.imageView.contentMode   = UIViewContentMode.ScaleAspectFill
        self.imageView.clipsToBounds = true
        
        self.addSubview(imageView)
        self.bringSubviewToFront(imageView)
        updateFactor(0)
    }
    
    func loadImage(url:NSURL?){
        //默认随机纯色背景
        self.imageView.sd_setImageWithURL(url)
    }
    
    func updateFactor(factor: CGFloat) {
        self.factor   = factor
        let yOffset   = extra * self.factor
        let y         = -extra + yOffset
        self.imageView.frame = CGRectMake(0, y, self.frame.width, self.frame.height + 2*extra)
    }
    
}