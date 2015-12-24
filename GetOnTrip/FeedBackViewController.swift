//
//  FeedBackViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/6.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit
import MJRefresh

class FeedBackViewController: MenuViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var tableView: UITableView = UITableView()
    
    /// 反馈情况(历史)
    var lastRequest: FeedbackRequest = FeedbackRequest()

    /// 发送按钮
    lazy var sendButton: UIButton = UIButton(title: "发送", fontSize: 12, radius: 34 * 0.5, titleColor: SceneColor.fontGray, fontName: Font.PingFangSCLight)
    
    /// 发送文字
    lazy var sendContentText: UITextField = UITextField()
    
    /// 底view
    lazy var commentBottomView: UIView = UIView()
    
    var dataSource: [Feedback] = [Feedback]()
    
    lazy var collectPrompt = UILabel(color: UIColor(hex: 0x2A2D2E, alpha: 0.3), title: "还木有登录...\n请先登录吧(∩_∩)", fontSize: 13, mutiLines: true)
    
    // MARK: - 初始化相关
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initView()
        initTableView()
        initCommentBottomView()
        initRefresh()
        initPrompt()
    }
    
    private func initView() {
        navBar.titleLabel.text = "反馈"
        view.backgroundColor = .whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    /// 初始化底部
    private func initCommentBottomView() {
        
        view.addSubview(commentBottomView)
        commentBottomView.addSubview(sendContentText)
        commentBottomView.addSubview(sendButton)
        commentBottomView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 50, UIScreen.mainScreen().bounds.width, 50)
        commentBottomView.backgroundColor = SceneColor.greyThin
        
        sendContentText.frame = CGRectMake(8, 8, UIScreen.mainScreen().bounds.width - 119, 34)
        sendButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 100, 8, 91, 34)
        sendButton.backgroundColor = SceneColor.shallowYellows
        sendButton.addTarget(self, action: "sendFeedBackMessage", forControlEvents: .TouchUpInside)
        
        sendContentText.borderStyle = .None
        sendContentText.layer.borderWidth = 0.5
        sendContentText.layer.borderColor = UIColor(hex: 0x1C1C1C, alpha: 0.5).CGColor
        sendContentText.layer.cornerRadius = 2
        sendContentText.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 0.5)
        sendContentText.leftView = UIView(frame: CGRectMake(0, 0, 5, 1))
        sendContentText.leftViewMode = .Always
    }
    
    /// 实始化tableview
    private func initTableView() {
        
        view.addSubview(tableView)
        tableView.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 64)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.registerClass(FeedBackMyTableViewCell.self, forCellReuseIdentifier: "FeedBackMyTableViewCell")
        tableView.registerClass(FeedBackSytemTableViewCell.self, forCellReuseIdentifier: "FeedBackSytemTableViewCell")
    }
    
    /// 初始化刷新方法
    private func initRefresh() {
        //上拉刷新
        let tbHeaderView = MJRefreshNormalHeader { [weak self] () -> Void in self?.loadMore() }
        tbHeaderView.automaticallyChangeAlpha = true
        tbHeaderView.activityIndicatorViewStyle = .Gray
        tbHeaderView.stateLabel?.font = UIFont.systemFontOfSize(12)
        tbHeaderView.lastUpdatedTimeLabel?.font = UIFont.systemFontOfSize(11)
        tbHeaderView.stateLabel?.textColor = SceneColor.lightGray
        tbHeaderView.lastUpdatedTimeLabel?.textColor = SceneColor.lightGray
        tbHeaderView.lastUpdatedTimeLabel?.hidden = true
        tbHeaderView.stateLabel?.hidden = true
        tbHeaderView.arrowView?.image = UIImage()
        tableView.mj_header = tbHeaderView
    }
    
    /// 初始化提示
    private func initPrompt() {
        view.addSubview(collectPrompt)
        collectPrompt.ff_AlignInner(.CenterCenter, referView: view, size: nil, offset: CGPointMake(0, -50))
        collectPrompt.textAlignment = .Center
        collectPrompt.hidden = false
        if globalUser != nil {
            collectPrompt.hidden = true
            loadData()
        }
    }
    
//    
//    /*
//    - (void)scrollToBottom {
//    // 滚动到最后一行
//    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
//    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//*/
    
    // MARK: - tableView dataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = dataSource[indexPath.row]
        if data.type == "1" {
            let cell = tableView.dequeueReusableCellWithIdentifier("FeedBackMyTableViewCell", forIndexPath: indexPath) as! FeedBackMyTableViewCell
            cell.data = data
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FeedBackSytemTableViewCell", forIndexPath: indexPath) as! FeedBackSytemTableViewCell
            cell.data = data
            return cell
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return FeedBackMyTableViewCell.heightWithFeedBack(dataSource[indexPath.row])
    }
    
    /// 当键盘弹出的时候，执行相关操作
    func keyboardChanged(not: NSNotification) {
        
        let keyBoardFrame = not.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let time = not.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.0
        let keyBoardY = keyBoardFrame?.origin.y
        let transFromValue = keyBoardY! - view.bounds.height
        
        UIView.animateWithDuration(time) { [weak self] () -> Void in
            self?.commentBottomView.frame.origin.y = transFromValue == 0 ? UIScreen.mainScreen().bounds.height - 50 : keyBoardY! - 50
            self?.tableView.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - transFromValue)
        }
    }
    
    /// 是否正在加载中
    var isLoading:Bool = false
    
    /// 注意：不能在loadData中进行beginRefreshing, beginRefreshing会自动调用loadData
    private func loadData() {
        if self.isLoading { return }
        self.isLoading = true
        
        lastRequest.fetchListFirstPageModels {[weak self] (data, status) -> Void in
            print(data)
            //处理异常状态
            if RetCode.SUCCESS != status {
                ProgressHUD.showErrorHUD(self?.view, text: MessageInfo.NetworkError)
                self?.tableView.mj_header.endRefreshing()
                self?.isLoading = false
                return
            }
            
            if let dataSource = data {
                self?.tableView.mj_header.endRefreshing()
                self?.dataSource = dataSource
                self?.tableView.reloadData()
            }
            self?.isLoading = false
        }
    }
    
    /// 底部加载更多
    func loadMore(){
        if self.isLoading { return }
        self.isLoading = true
        //请求下一页
        self.lastRequest.fetchListNextPageModels { [weak self] (result, status) -> Void in
            
            if let data = result {
                if data.count > 0 {
                    // 总数量 - 最后一页
//                    let count1 = ((self?.lastRequest.page)! * (self?.lastRequest.pageSize)!) - (self?.dataSource.count)!
//                    let count = (self?.dataSource.count ?? 0) - (self?.dataSource.count ?? 0) % (self?.lastRequest.pageSize ?? 0)
//                    // 找出最后一页多的
//                    for _  in 0...count {
//                        self?.dataSource.removeLast()
//                    }
                    
                    self?.dataSource.appendContentsOf(data)
//                    self?.dataSource.insertContentsOf(data, at: 0)
//                    self?.dataSource.insert(Feedback(dict: [String : AnyObject]()), atIndex: 0)
                    //                        self?.dataSource.appendContentsOf(cells)
//                    var indexPaths = [NSIndexPath]()
//                    for _ in data {
//                    indexPaths.append(NSIndexPath(forItem: 0, inSection: 0))
////                        indexPaths.append(NSIndexPath(forItem: 1, inSection: 0))
//                    }
//                    self?.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                    self?.tableView.reloadData()
                    //                        self?.dataSource = cells + dataSource
                    self?.tableView.mj_header.endRefreshing()
                } else {
                    self?.tableView.mj_header.endRefreshing()
                }
            }
            self?.isLoading = false
        }
    }
    
    /// 发送反馈消息
    func sendFeedBackMessage() {
        
        let content = sendContentText.text ?? ""
        if content == "" {
            ProgressHUD.showErrorHUD(nil, text: "请先输入需要反馈的消息")
            return
        }
        if globalUser != nil {
            self.isLoginAction(content)
        } else { /// 未登陆时
            LoginView.sharedLoginView.doAfterLogin() { [weak self] (success, error) -> () in
                self?.sendContentText.resignFirstResponder()
                if success {
                    self?.isLoginAction(content)
                } else { /// 登陆失败
                    ProgressHUD.showErrorHUD(nil, text: "登陆失败，请检查网络设置")
                }
            }
        }
    }
    
    private func isLoginAction(content: String) {
        lastRequest.fetchSendModels(content) { [weak self] (result, status) -> Void in
            if status == RetCode.SUCCESS {
                ProgressHUD.showSuccessHUD(nil, text: "发送成功")
                
                let fb = Feedback(dict: [String : AnyObject]())
                
                
                
                let format = NSDateFormatter()
                format.locale = NSLocale(localeIdentifier: "en")
                format.dateFormat = "yyyy-MM-dd HH:mm"
                let dest = format.stringFromDate(NSDate())
                
                self?.sendContentText.text = ""
                return
            }
            ProgressHUD.showErrorHUD(nil, text: "发送失败，请重新发送")
        }
    }
    
    /// 添加回复信息
    private func addReceivedInfo() {
        
        NSDate()
        
    }
    
    // scrollerview delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if sendContentText.isFirstResponder() {
            sendContentText.resignFirstResponder()
        }
    }
    
    /// 注销通知
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}