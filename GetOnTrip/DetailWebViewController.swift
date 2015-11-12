//
//  SightDetailController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/10/14.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class DetailWebViewController: BaseViewController {

    lazy var webView: UIWebView = UIWebView()
    
    /// 自定义导航
    var navBar: CustomNavigationBar = CustomNavigationBar(title: "", titleColor: UIColor.whiteColor(), titleSize: 14)
    
    var url: String? {
        didSet {
            if let urlStr = url?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                webView.loadRequest(NSURLRequest(URL: NSURL(string: urlStr)!))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SceneColor.frontBlack
        
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "途知", style: .Plain, target: nil, action: nil)

        view.addSubview(webView)
        webView.addSubview(loadingView)
        view.addSubview(navBar)
        view.bringSubviewToFront(navBar)

        webView.frame = view.bounds
        webView.backgroundColor = UIColor.whiteColor()
        webView.opaque = false
        
        navBar.setBackBarButton(UIImage(named: "icon_back"), title: "途知", target: self, action: "popViewAction:")
        navBar.setButtonTintColor(UIColor.yellowColor())
        navBar.setBlurViewEffect(false)
        navBar.backgroundColor = SceneColor.frontBlack
        
        loadingView.ff_AlignInner(.TopCenter, referView: webView, size: loadingView.getSize(), offset: CGPointMake(0, view.bounds.height/2))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let vc = parentViewController as? UINavigationController
        let nav = vc?.visibleViewController as? SightViewController
        nav?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: "", action: "")
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    var loadingView: LoadingView = LoadingView(color: SceneColor.lightGray)
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadingView.start()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingView.stop()
    }
}
