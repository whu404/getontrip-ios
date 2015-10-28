//
//  SearchMoreRequest.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/10/27.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit

class SearchMoreRequest: NSObject {
    
    ///  搜索更多
    ///
    ///  - parameter type:     搜索类型 1:景点,2:城市,3:内容
    ///  - parameter page:     页
    ///  - parameter pageSize: 页面大小
    ///  - parameter query:    查询词
    ///  - parameter handler:  回调数据
    class func fetchMoreResult(type: Int, page: Int, pageSize: Int, query: String, handler: AnyObject -> Void) {
        
        var post      = [String: String]()
        post["type"]  = String(type)
        post["page"]  = String(page)
        post["query"] = String(query)
        post["pageSize"] = String(pageSize)
        
        HttpRequest.ajax(AppIni.BaseUri, path: "/api/search", post: post) { (result, error) -> () in
            if error == nil {
                handler(result!)
            }
        }
    }
    
    /**
     * 接口3：/api/search/hotWord
     * 热门搜索词接口
     * @param integer size,条数，默认是10
     */
    class func fetchSearchMuchLabel(handler: ([String]?, Int) -> Void){
        HttpRequest.ajax2(AppIni.BaseUri, path: "/api/search/hotWord", post: [String: String]()) { (result, status) -> () in
            if status == RetCode.SUCCESS {
                var data = [String]()
                for it in result.arrayValue {
                    data.append(it.stringValue)
                }
                handler(data, status)
                return
            }
            handler(nil, status)
        }
    }
}