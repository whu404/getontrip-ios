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
        
        var apiPath = path
        if let range = path?.rangeOfString("/api/") {
            apiPath?.replaceRange(range, with: "/api/\(AppIni.ApiVersion)/")
        }
        
        var params = [String]()
        for (field, value) in post {
            params.append("\(field)=\(value)")
        }
        //G请求才会有效缓存
        var urlPath = (url ?? "") + (apiPath ?? "")
        if params.count > 0 {
            urlPath += "?" + params.joinWithSeparator("&")
        }
        
        let url = urlPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
        
        print("[HttpRequest]:url=\(url)")
        
        let ts    = String(format: "%.0f", NSDate().timeIntervalSince1970)
        let token = "\(AppIni.SecretKey)\(ts)".sha256 + ts
        let postArgs = ["token": token]
        HttpRequest.sharedManager.request(.POST, url, parameters: postArgs).response { request, response, respData, error -> Void in
            //异常
            if error != nil {
                print("[HttpRequest]:error=\(error)")
                return handler(result: nil, status: RetCode.NETWORK_ERROR)
            }
            //处理数据
            if let data = respData {
                let json = JSON(data: data)
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