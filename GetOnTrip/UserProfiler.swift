//
//  UserProfiler.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/12/18.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import Foundation

class UserProfiler: NSObject {
    
    static let instance: UserProfiler = UserProfiler()
    
    /// 是否省流量模式（开启则非wifi下不显示图片）
    var savingTrafficMode: Bool  {
        get {
            // 默认返回
            if let userDefault = NSUserDefaults.standardUserDefaults().valueForKey("isTraffic") as? Bool {
                return userDefault
            }
            return false
        }
        set {
            // 保存至用户配置
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isTraffic")
        }
    }
    
    
}