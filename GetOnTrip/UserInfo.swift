
//
//  UserInfo.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/3.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import Foundation

/// 用户信息类
class UserInfo : NSObject {
    
    var nick_name: String = ""
    
    var image: String = "" {
        didSet {
            image = AppIni.BaseUri + image
        }
    }
    
    var sex: String = ""
    
    var city: String = ""
    
    convenience init(dict: [String : AnyObject]) {
        self.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}