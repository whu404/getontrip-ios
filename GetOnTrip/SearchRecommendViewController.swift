//
//  SearchListPageController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/22.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class SearchRecommendViewController: MainViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// 数据源
    var dataSource: NSDictionary?
    
    // 搜索标签文本列表
    var searchLabels: NSMutableArray    = NSMutableArray()
    
    // 搜索标签id列表
    var searchLabelIds: NSMutableArray = NSMutableArray()
    
    /// 底部的tableView
    lazy var tableView = UITableView()
    
    /// 网络请求加载数据(添加)
    var lastSuccessAddRequest: SearchRecommendRequest?
    
    /// 搜索顶部
    var headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 244))
    
    /// 搜索顶部图片
    var headerImageView = UIImageView(image: UIImage(named: "search_header"))

    /// 记录状态按钮
    weak var currentSearchLabelButton: UIButton?
    
    //导航背景，用于完成渐变
    weak var navUnderlayView:UIView?
    
    //导航透明度
    var navBarAlpha:CGFloat = 0.0
    
    // MARK: - 初始化
    
    //电池栏状态
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = SceneColor.bgBlack
        
        //nav bar
        navUnderlayView = UIKitTools.getNavBackView(navigationController?.navigationBar)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        headerView.addSubview(headerImageView)
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 244)
        
        //添加黑色蒙板
        let maskView = UIView(color: SceneColor.bgBlack, alphaF: 0.55)
        headerView.addSubview(maskView)
        maskView.ff_Fill(headerView)
        
        addTableViewProperty()
        loadSearchData()
        setupAutoLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshBar()
    }
    
    func refreshBar(){
        //更新导航背景
        navUnderlayView?.alpha = navBarAlpha
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    ///  添加tableview相关属性
    private func addTableViewProperty() {
        view.addSubview(tableView)
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.tableHeaderView = headerView
        tableView.registerClass(SearchRecommendTableViewCell.self, forCellReuseIdentifier: StoryBoardIdentifier.SearchRecommendTableViewCellID)
        
        tableView.rowHeight       = SearchRecommendTableViewCell.RowHeight
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.None
    }
    
    /// 发送搜索信息
    private func loadSearchData() {
        if lastSuccessAddRequest == nil {
            lastSuccessAddRequest = SearchRecommendRequest()
        }
        
        lastSuccessAddRequest?.fetchModels {[unowned self] (handler: NSDictionary) -> Void in
            
            self.dataSource = handler
            if self.searchLabels.count == 0 {
                for lab in handler.objectForKey("labels") as! NSArray {
                    let labM = lab as! SearchLabel
                    let label = labM.name! + "    " + labM.num!
                    self.searchLabels.addObject(label)
                    self.searchLabelIds.addObject(labM.id!)
                }
                self.addSearchLabelButton()
            }
            self.headerImageView.sd_setImageWithURL(NSURL(string: handler.objectForKey("image") as! String), placeholderImage: UIImage(named: "search_header"))
            self.tableView.reloadData()
        }
    }
    
    ///  添加搜索标签按钮
    private func addSearchLabelButton() {
        //参数
        let btnWidth:CGFloat  = 87
        let btnHeight:CGFloat = 17
        let totalCol:Int      = 2
        let totalRow:Int      = 3
        let marginX:CGFloat   = (headerView.bounds.size.width - btnWidth * CGFloat(totalCol)) / CGFloat(totalCol + 1)
        let yOffset:CGFloat   = 105
        let marginY:CGFloat   = 26
        
        for (var i = 0; i < searchLabels.count; i++) {
            let btn = UIButton(title: searchLabels[i] as! String, fontSize: 14, radius: 0)
            
            headerView.addSubview(btn)
            
            btn.addTarget(self, action: "clkSearchLabelMethod:", forControlEvents: UIControlEvents.TouchUpInside)
            btn.setTitleColor(UIColor(hex: 0xFFFFFF, alpha: 0.6), forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            btn.tag = searchLabelIds[i].integerValue
            if i == 0 {
                btn.selected = true
                currentSearchLabelButton = btn
            }
            let row:Int = i / totalCol
            let col:Int = i % totalCol
            
            if row >= totalRow {
                break
            }
            
            let btnX:CGFloat = marginX + (marginX + btnWidth) * CGFloat(col)
            let btnY:CGFloat = yOffset + (marginY + btnHeight) * CGFloat(row)
            
            btn.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight)
        }
    }
    
    /// 布局
    private func setupAutoLayout() {
        tableView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: CGSizeMake(view.bounds.width, view.bounds.height + 64), offset: CGPointMake(0, -64))
        headerImageView.ff_Fill(headerView)
    }
    
    // MASK: - tableView 数据源及代理方法
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource != nil {
            return dataSource!.objectForKey("datas")!.count!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoardIdentifier.SearchRecommendTableViewCellID, forIndexPath: indexPath) as! SearchRecommendTableViewCell
        
        let array = dataSource!.objectForKey("datas") as! NSArray
        cell.backgroundColor = UIColor.clearColor()
        cell.data = array[indexPath.row] as? RecommendCellData
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let array = dataSource!.objectForKey("datas") as! NSArray
        if let data = array[indexPath.row] as? RecommendCellData {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if (!data.isTypeCity()) {
                let vc = SightViewController()
                vc.sightId   = data.id
                vc.sightName = data.name
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = CityViewController()
                vc.cityId   = data.id
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: ScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //导航渐变
        let threshold:CGFloat = 198 - 64
        let offsetY = scrollView.contentOffset.y
        if offsetY > 0 {
            navBarAlpha = offsetY / threshold;
            if navBarAlpha > 1 {
                navBarAlpha = 1
            } else if navBarAlpha < 0.1 {
                navBarAlpha = 0
            }
        }
        refreshBar()
    }
    
    //MARK: 自定义方法
    
    //触发搜索列表的方法
    func clkSearchLabelMethod(sender: UIButton) {
        sender.selected = true
        currentSearchLabelButton?.selected = false
        currentSearchLabelButton = sender
        
        lastSuccessAddRequest!.label = String(sender.tag)
        loadSearchData()
    }
}
