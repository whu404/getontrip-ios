//
//  HotCity.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/12/19.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit


class HotCity: NSObject {
    
    static let HotCityImageWidth = (UIScreen.mainScreen().bounds.width - 50) / 3 - 3// 48
    
    /// 城市id
    var id    = ""
    /// 城市景点
    var sight = "" {
        didSet {
            sight = "\(sight)个景点"
        }
    }
    /// 城市话题数量
    var topic = "" {
        didSet {
            topic = "\(topic)个内容"
        }
    }
    /// 城市名
    var name  = ""
    /// 城市图片
    var image = "" {
        didSet {
            image = UIKitTools.sliceImageUrl(image, width: Int(HotCity.HotCityImageWidth), height: Int(HotCity.HotCityImageWidth))
        }
    }
    
    init(dict: [String : AnyObject]) {
        super.init()

        setValuesForKeysWithDictionary(dict)
//        id = String(dict["id"] ?? "")// as! String
//        sight = String(dict["sight"] ?? "")// as! String
//        topic = String(dict["topic"] ?? "")// as! String
//        image = String(dict["image"] ?? "")// as! String
//        name = String(dict["name"] ?? "")// as! String
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
