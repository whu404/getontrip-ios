//
//  TopicEnterSightController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/30.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit

// 从话题进入景点控制器
class TopicEnterSightController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 浏览提示
    lazy var browseLabel = UILabel(color: UIColor.whiteColor(), title: "选择您想浏览的景点", fontSize: 17)
    
    /// 顶部线
    lazy var topLineView = UIView(color: UIColor.whiteColor())
    
    /// 列表
    lazy var tableView  = UITableView()
    
    /// 退出按钮
    let exitButton      = UIButton(image: "topicSight_x", title: "", fontSize: 0)
    
    /// 需要选择的景点
    var dataSource: [[String : String]]? {
        didSet {
            tableView.rowHeight = CGFloat(UIScreen.mainScreen().bounds.height * 0.46 - 54) / CGFloat(dataSource?.count ?? 0)
            tableView.reloadData()
        }
    }
    
    var nav: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    private func initView() {
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(tableView)
        view.addSubview(exitButton)
        
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.bounces    = false
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(hex: 0x838383, alpha: 0.8)
        tableView.ff_AlignInner(.TopLeft, referView: view, size: CGSizeMake(UIScreen.mainScreen().bounds.width * 0.63, UIScreen.mainScreen().bounds.height * 0.46))
        tableView.registerClass(TopicSightListTableViewCell.self, forCellReuseIdentifier: "TopicSightListTableViewCell")
        
        exitButton.ff_AlignInner(.BottomCenter, referView: view, size: CGSizeMake(34, 34))
        exitButton.addTarget(self, action: "exitButtonAction", forControlEvents: .TouchUpInside)
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicSightListTableViewCell", forIndexPath: indexPath) as! TopicSightListTableViewCell
        cell.data = dataSource?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return wantBrowseSight()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = dataSource?[indexPath.row]
        let sightViewController = SightViewController()
        let sight: Sight = Sight(id: (data?["id"] ?? ""))
        sight.name = data?["name"] ?? ""
        sightViewController.sightDataSource = sight
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.nav?.pushViewController(sightViewController, animated: true)
        }
    }
    
    // 退出按钮
    func exitButtonAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 想浏览的景点
    func wantBrowseSight() -> UIView {
        let w: CGFloat = UIScreen.mainScreen().bounds.width * 0.63
        let wantView = UIView(frame: CGRectMake(0, 0, w, 54))
        let wantBrowse = UILabel(color: .whiteColor(), title: "选择您想浏览的景点", fontSize: 17, mutiLines: true)
        let baseLine   = UIView(color: .whiteColor())
        wantView.addSubview(wantBrowse)
        wantView.addSubview(baseLine)
        wantBrowse.ff_AlignInner(.CenterCenter, referView: wantView, size: nil)
        baseLine.ff_AlignInner(.BottomCenter, referView: wantView, size: CGSizeMake(w - 30, 0.5))
        return wantView
    }

}