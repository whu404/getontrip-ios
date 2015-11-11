//
//  CollectAddAndCancel.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/10/24.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit

class CollectAddAndCancel: NSObject {
    
    static let sharedCollectAddCancel = CollectAddAndCancel()
    
    ///  收藏方法
    ///
    ///  - parameter objid:   收藏对象 内容：1， 景点：2， 城市：3， 话题：4， 书籍：5
    ///  - parameter isAdd:   是否收藏
    ///  - parameter handler: 回调
    func fetchCollectionModels(type: Int, objid: String, isAdd: Bool, handler: (String?, Int) -> Void) {
        
        var post      = [String: String]()
        post["objid"] = String(objid)
        post["type"]  = String(type)
        let path = isAdd == true ? "/api/collect/add" : "/api/collect/del"
        
        HttpRequest.ajax2(AppIni.BaseUri, path: path, post: post) { (result, status) -> () in
            if status == RetCode.SUCCESS {

                handler(result.string, status)
                return
            }
            handler(nil, status)
        }
    }
    

}

struct FavoriteContant {
    //查询用
    static let TypeContent = 1
    
    static let TypeSight   = 2
    static let TypeCity    = 3
    static let TypeTopic   = 4
    static let TypeBook    = 5
}

class Favorite: NSObject {
    
    class func doFavorite(type: Int, objid: String, isFavorite: Bool, handler: (String?, Int) -> Void) {
        if sharedUserAccount == nil {
            LoginView.sharedLoginView.addLoginFloating({(success, error) -> () in
                if success {
                    Favorite.doAction(type, objid: objid, isFavorite: isFavorite, handler: handler)
                }})
        } else {
            Favorite.doAction(type, objid: objid, isFavorite: isFavorite, handler: handler)
        }
    }
    
    class private func doAction(type: Int, objid: String, isFavorite: Bool, handler: (String?, Int) -> Void) {
        var post      = [String: String]()
        post["objid"] = String(objid)
        post["type"]  = String(type)
        let path = isFavorite ? "/api/collect/add" : "/api/collect/del"
        
        HttpRequest.ajax2(AppIni.BaseUri, path: path, post: post) { (result, status) -> () in
            if status == RetCode.SUCCESS {
                
                handler(result.string, status)
                return
            }
            handler(nil, status)
        }
    }
}
