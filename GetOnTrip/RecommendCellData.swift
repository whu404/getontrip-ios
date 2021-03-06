//
//  RecommendCellData.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/11/5.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import Foundation

struct RecommendCellType  {
    static let TypeTopic = "3"
    static let TypeCity  = "2"
    static let TypeSight = "1"
}

/// 搜索数据
class RecommendCellData: ModelObject {
    
    //id
    var id: String = ""
    //标题
    var name: String = ""
    //图片
    var image: String = "" {
        didSet {
            image = UIKitTools.sliceImageUrl(image, width: Int(UIScreen.mainScreen().bounds.width), height: Int(RecommendContant.rowHeight))
        }
    }
    
    var param1: String = ""
    
    var param2: String = ""
    
    var param3: String = ""
    
    //补充用于话题传景点id
    var param4: String = ""
    
    var dis: String = ""
    
    var dis_unit: String = ""
    
    //城市＝2，景点＝1
    var type: String = RecommendCellType.TypeSight
    /// 城市id
    lazy var cityid: String = ""
    /// 城市名
    lazy var cityname: String = ""
    
    init(dict: [String: AnyObject]) {
        super.init()
        //
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    func isTypeCity() -> Bool {
        return self.type == RecommendCellType.TypeCity ? true : false
    }
    
    func isTypeTopic() -> Bool {
        return self.type == RecommendCellType.TypeTopic ? true : false
    }
    
    func isTypeSight() -> Bool {
        return self.type == RecommendCellType.TypeSight ? true : false
    }
}
