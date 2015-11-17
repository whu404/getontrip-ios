//
//  HttpRequest.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/8/6.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import YTKKeyValueStore

struct HttpRequestContant {
    static let timeout: NSTimeInterval = 10
}

class HttpRequest {
    
    typealias RequestFinishedCallBack = (result: AnyObject?, error: NSError?) -> ()
    
    typealias RequestJSONCallBack = (result: JSON, status: Int) -> ()
    
    /// 网络工具单例
    static let sharedHttpRequest = HttpRequest()
    
    static let sharedManager: Manager = {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        //采用后端控制缓存时间
        let nsUrlCache = NSURLCache.sharedURLCache()
        configuration.URLCache = NSURLCache.sharedURLCache()
        
        configuration.requestCachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        
        configuration.timeoutIntervalForRequest  = HttpRequestContant.timeout
        configuration.timeoutIntervalForResource = HttpRequestContant.timeout
        return Manager(configuration: configuration)
    }()
    
    ///  网络访问方法
    ///
    ///  - parameter url:     访问环境
    ///  - parameter path:    访问网络路径
    ///  - parameter post:    参数
    ///  - parameter handler: 回调数据及错误
    class func ajax2(url: String?, path: String?, post: Dictionary<String, String>, handler: RequestJSONCallBack) {
        
        //拼接urlPath, urlPath维度的缓存，需要加参数以区分
        var params = [String]()
        for (field, value) in post {
            params.append("\(field)=\(value)")
        }
        var urlPath = (path ?? "")
        if params.count > 0 {
            urlPath += "?" + params.joinWithSeparator("&")
        }
        if let range = urlPath.rangeOfString("/api/") {
            urlPath.replaceRange(range, with: "/api/\(AppIni.ApiVersion)/")
        }
        
        if let cacheJson = Cache.shareInstance.getString(urlPath)?.dataUsingEncoding(NSUTF8StringEncoding) {
            //先看有效缓存，有直接返回
            let cacheJsonObj = JSON(data: cacheJson)
            handler(result: cacheJsonObj, status: RetCode.SUCCESS)
            return
        } else {
            //无则看有没缓存先用于展示
            if let cacheJson = Cache.shareInstance.getDisplayString(urlPath)?.dataUsingEncoding(NSUTF8StringEncoding) {
                let cacheJsonObj = JSON(data: cacheJson)
                handler(result: cacheJsonObj, status: RetCode.SUCCESS)
            }
        }
        
        /// 发送真实网络请求
        var url = (url ?? "") + urlPath
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
        let timestamp = String(format: "%.0f", NSDate().timeIntervalSince1970)
        let token     = "\(AppIni.SecretKey)\(timestamp)".sha256 + timestamp
        let postArgs  = ["token": token]
        print("[HttpRequest]:url=\(url), post=\(postArgs)")
        
        HttpRequest.sharedManager.request(.POST, url, parameters: postArgs).response { request, response, respData, error -> Void in
            //异常
            if error != nil {
                print("[HttpRequest]:error=\(error)")
                return handler(result: nil, status: RetCode.NETWORK_ERROR)
            }
            //处理数据
            if let data = respData {
                let json = JSON(data: data)
                
                //添加缓存
                if let str = json["data"].rawString() {
                    Cache.shareInstance.setString(urlPath, value: str)
                }
                return handler(result: json["data"], status: json["status"].intValue)
            }
        }
    }
    
    /// 上传文件
    ///
    /// - parameter urlString:  urlString
    /// - parameter data:       要上传文件的二进制数据
    /// - parameter parameters: 参数字典
    /// - parameter finished:   完成回调
    func upload(urlString: String, data: NSData, parameters: [String: AnyObject]?, finished: RequestFinishedCallBack) {
        
        let urlStr = AppIni.BaseUri + urlString
        Alamofire.upload(.POST,
            urlStr,
            multipartFormData: { (multipartFormData) in
                
                multipartFormData.appendBodyPart(data: data, name: "file", fileName: "123.png", mimeType: "image/png")
                
                guard let params = parameters else {
                    return
                }
                
                for (k, v) in params {
                    let value = v as! String
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: k)
                }
            }) { (encodingResult) -> Void in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        finished(result: response.result.value, error: response.result.error)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    finished(result: nil, error: nil)
                }
        }
    }
}