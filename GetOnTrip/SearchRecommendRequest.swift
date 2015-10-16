//
//  HomeSearchCityRequest.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/29.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit

class SearchRecommendRequest: NSObject {
    /**
    * 接口2：/api/search/label
    * 搜索列表页   首页入口二
    * @param integer page
    * @param integer pageSize
    * @param integer label,搜索标签，标签可以不传
    * @return json
    */
    
    // 请求参数
    var label   : String = ""
    var page    : Int = 1
    var pageSize: Int = 6
    
    // 异步加载获取数据
    func fetchModels(handler: NSDictionary -> Void) {
        var post         = [String: String]()
        post["label"]    = String(label)
        post["page"]     = String(page)
        post["pageSize"] = String(pageSize)
        
        // 发送网络请求加载数据
        HttpRequest.ajax(AppIniDev.BaseUri,
            path: "/api/search/label",
            post: post,
            handler: {(respData: AnyObject) -> Void in
                let searchModel = NSMutableDictionary()
                
                var searchLabels = [SearchLabel]()
                var searchDatas = [RecommendCellData]()
                
                for item in respData["label"] as! NSArray {
                    searchLabels.append(SearchLabel(dict: item as! [String : String]))
                }
                
                for item in respData["content"] as! NSArray {
                    searchDatas.append(RecommendCellData(dict: item as! [String : String]))
                }
                
                let str = respData.objectForKey("image") as! String
                searchModel.setValue(searchLabels, forKey: "labels")
                searchModel.setValue(searchDatas, forKey: "datas")
                searchModel.setValue(String(AppIni.BaseUri + str), forKey: "image")
                // 回调
                handler(searchModel)
            }
        )
    }
}

/// 搜索标签
class SearchLabel: NSObject {
    /// id
    var id: String?
    /// 标签名
    var name: String?
    /// 数字
    var num: String?
    
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}

/// 搜索数据
class RecommendCellData: NSObject {
    //数据类型
    static let TypeCity  = "2"
    static let TypeSight = "1"
    
    //id
    var id: String = ""
    //标题
    var name: String = ""
    //图片
    var image: String? {
        didSet {
            image = AppIni.BaseUri + image!
        }
    }
    
    var param1: String = ""
    
    var param2: String = ""
    
    var param3: String = ""
    
    //城市＝2，景点＝1
    var type: String = RecommendCellData.TypeSight
    
    init(dict: [String: String]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    func isTypeCity() -> Bool {
        return self.type == RecommendCellData.TypeCity ? true : false
    }
}