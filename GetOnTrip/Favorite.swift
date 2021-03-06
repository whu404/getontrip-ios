//
//  CollectAddAndCancel.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/10/24.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit

struct FavoriteContant {
    //查询用
    static let TypeContent = 1
    static let TypeSight   = 2
    static let TypeCity    = 3
    static let TypeTopic   = 4
    static let TypeBook    = 5
    static let TypeVideo   = 6
}

class Favorite: NSObject {
    
    class func doFavorite(type: Int, objid: String, isFavorite: Bool, handler: (String?, Int) -> Void) {
            LoginView.sharedLoginView.doAfterLogin() {(success, error) -> () in
                if success {
                    Favorite.doAction(type, objid: objid, isFavorite: isFavorite, handler: handler)
                } else {
                   handler(nil, 0)
                }
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
