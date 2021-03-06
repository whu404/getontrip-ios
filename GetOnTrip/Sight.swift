//
//  Sight.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/10/16.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import Foundation

class Sight: ModelObject {
    /// id
    var id: String = ""
    /// 景点名
    var name: String = ""
    /// 景点图片
    var image: String = "" {
        didSet {
            image = UIKitTools.sliceImageUrl(image, width: 414, height: 198)
        }
    }
    /// 景点有多少内容
    var content: String = ""
    /// 有多少人收藏
    var collect: String = ""
    /// 景点标签
    var tags: [Tag] = [Tag]()
    
    /// 城市ID
    var cityid: String = ""
    /// 是否被当前用户收藏
    var isfav: String = ""
    
    init(id: String){
        super.init()
        self.id = id
    }
    
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
        tags.removeAll()
        if let taglist = dict["tags"] as? NSArray {
            for item in taglist {
                if let dic = item as? [String : AnyObject] {
                    tags.append(Tag(dict: dic))
                }
            }
        }
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    func isFavorite() -> Bool {
        return self.isfav == "1" ? true : false
    }
}