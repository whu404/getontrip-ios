//
//  CompulsoryPlayView.swift
//  GetOnTrip
//
//  Created by 王振坤 on 16/1/12.
//  Copyright © 2016年 Joshua. All rights reserved.
//

import UIKit

class CompulsoryPlayView: UIView {

    /// 必玩底部三角
    override func drawRect(rect: CGRect) {
        let ctf = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(ctf, 0, 0)
        CGContextAddLineToPoint(ctf, 25, 0)
        CGContextAddLineToPoint(ctf, 0, 25)
        CGContextClosePath(ctf)
        SceneColor.originYellow.setFill()
        CGContextSetLineCap(ctf, CGLineCap.Round)
        CGContextDrawPath(ctf, CGPathDrawingMode.Fill)
    }
}
