
//
//  BaseHomeController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/23.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class MainViewController: UIViewController {
    
    // MASK: Properties
    
    //代理左侧菜单的操作
    var slideDelegate: SlideMenuViewControllerDelegate?
    
    lazy var slideButton: UIButton = {
        let button = UIButton(type: UIButtonType.Custom)
        button.setBackgroundImage(UIImage(named: "icon_hamburger"), forState: UIControlState.Normal)
        button.addTarget(self, action: "toggleMenu", forControlEvents: UIControlEvents.TouchUpInside)
        return button
        }()
    
    var cityId: String = ""
    // MASK: View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideButton.frame  = CGRectMake(0, 0, 21, 14)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "searchButtonClicked:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: 自定义方法
    
    func toggleMenu(){
        slideDelegate?.toggle()
    }
    
    
    func showSearch(){
        
        let svc = SearchViewController()
        svc.searchResult.cityId = cityId
        print(parentViewController)
        presentViewController(svc, animated: true, completion: nil)

    }
    

}
