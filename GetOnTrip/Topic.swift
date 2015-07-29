//
//  Topic.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/7/24.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import Foundation

//话题类
class Topic :Printable{
    
    //话题ID
    var topicid:Int
    
    //标题
    var title:String
    
    //副标题
    var subtitle:String
    
    //图片
    var imageUrl:String?
    
    //收藏
    var favorites:Int?
    
    //浏览
    var scan:Int?
    
    var description:String {
        get{
            return "Topic(\(topicid)"
        }
        set{
            newValue
        }
    }
    var desc:String?

    init(topicid:Int, title: String, subtitle: String){
        self.topicid = topicid
        self.title = title
        self.subtitle = subtitle
    }
}