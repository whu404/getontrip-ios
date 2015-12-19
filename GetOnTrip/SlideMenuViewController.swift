//
//  菜单控制器
//  MenuViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/22.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout
import JGProgressHUD

//定义侧边栏的两种状态（打开，关闭）枚举类型
enum SlideMenuState: Int {
    case Opening = 1
    case Closing
    mutating func toggle() {
        switch self {
        case .Closing:
            self = .Opening
        case .Opening:
            self = .Closing
        }
    }
}

struct SlideMenuOptions {
    //拉伸的宽度
    static let DrawerWidth: CGFloat = UIScreen.mainScreen().bounds.width * 0.75
    //高度
    static let DrawerHeight: CGFloat = UIScreen.mainScreen().bounds.height
    //超过该滑动阀值开始自动展开/关闭菜单
    static var AutoSlideXOffSet : CGFloat  = 60.0
    //menu
    static let MenuTableViewCellID = "MenuTableViewCellID"
}

protocol SlideMenuViewControllerDelegate {
    //打开或关闭
    func toggle() -> Void
    //恢复
    func reset() -> Void
}

let UserInfoChangeNotification = "UserInfoChangeNotification"

class SlideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SlideMenuViewControllerDelegate {
    
    // MARK: Properties and Views
    
    //当前选择的主窗体对象
    var curVCType: AnyClass! {
        didSet {
            if curVCType != oldValue {
                if let vcType =  curVCType as? UIViewController.Type {
                    let vc = vcType.init()
                    mainViewController = vc as! MainViewController
                }
            }
            //关闭侧边栏
            didClose()
        }
    }
    
    //主窗体Controller
    var mainViewController: MainViewController! {
        didSet{
            mainNavViewController.setViewControllers([mainViewController], animated: false)
            
            //初始化蒙板
            maskView = UIView(color: UIColor.blackColor(), alphaF: 0.1)
            mainViewController.view.addSubview(maskView)
            mainViewController.view.bringSubviewToFront(maskView)
            maskView.frame = mainViewController.view.bounds
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGestureHandler:")
            maskView.addGestureRecognizer(tapGestureRecognizer)
            
            if mainViewController.isKindOfClass(NSClassFromString("GetOnTrip.FavoriteViewController")!) {
                let vc = mainViewController as! FavoriteViewController
                vc.slideView.addGestureRecognizer(tapGestureRecognizer)
            }
            
            if globalUser != nil {                
                if mainViewController.isKindOfClass(NSClassFromString("GetOnTrip.MessageViewController")!) {
                    let vc = mainViewController as! MessageViewController
                    panGestureRecognizer.delegate = vc
                    panGestureRecognizer2.delegate = vc
                }
            }
            
            mainViewController.view.addGestureRecognizer(panGestureRecognizer)
            mainViewController.slideDelegate = self
            refreshMask()
        }
    }
    
    //带导航的主窗体
    lazy var mainNavViewController: UINavigationController = UINavigationController()
    
    //主窗体的遮罩层
    var maskView: UIView = UIView(color: UIColor.blackColor(), alphaF: 0.1)
    
    //左侧菜单
    var menuView: UIView = UIView()
    
    //菜单底图图片
    lazy var bgImageView: UIImageView = UIImageView(image: UIImage(named: "menu_bg")!)
    
    //菜单侧边列表项
    lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.backgroundColor = UIColor.clearColor()
        return tab
        }()
    
    //登陆后，底view
    lazy var loginAfter: UIView = UIView()
    
    //登陆前，底view
    lazy var loginBefore: UIView = UIView()
    
    //欢迎
    lazy var welcomeLabel = UILabel(color: UIColor.whiteColor(), fontSize: 36, mutiLines: true)
    //说明
    lazy var descLabel    = UILabel(color: UIColor.whiteColor(), fontSize: 12, mutiLines: true)
    //登陆后，头像
    lazy var headerView: UIImageView = UIImageView(image: PlaceholderImage.defaultUser)
    //登陆后，名称
    lazy var nameLabel: UILabel = UILabel(color: UIColor.whiteColor(), fontSize: 24, mutiLines: true)
    
    /// 微信
    lazy var wechatButton: UIButton = UIButton(icon: "icon_weixin", masksToBounds: true)
    /// QQ
    lazy var qqButton: UIButton = UIButton(icon: "icon_qq", masksToBounds: true)
    /// 更多登陆方式按钮
    lazy var moreButton: UIButton = UIButton(icon: "more_white", masksToBounds: true)
    
    //设置菜单的数据源
    let tableViewDataSource = ["首页", CityBrowseViewController.name, FavoriteViewController.name, MessageViewController.name, SettingViewController.name] // FeedBackViewController.name
    
    //菜单对应元类
    let usingVCTypes: [AnyClass] = [RecommendViewController.self, CityBrowseViewController.self, FavoriteViewController.self, MessageViewController.self, SettingViewController.self, FeedBackViewController.self]
    
    //定义当前侧边栏的状态
    var slideMenuState: SlideMenuState = SlideMenuState.Closing
    
    //登陆状态
    var logined: Bool = true
    
    //滑动手势
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action:"panGestureHandler:")
        return pan
    }()
    
    lazy var panGestureRecognizer2: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action:"panGestureHandler:")
        return pan
        }()
    
    // MARK: - 初始化方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //default
        curVCType = self.usingVCTypes[0]
        
        setupInit()
        setupAutoLayout()
        refreshLoginStatus()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userInfoDidChangeNotification:", name: UserInfoChangeNotification, object: nil)
        
        isInstallLoginClientSide()
    }
    
    //电池栏状态
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //初始化相关设置
    private func setupInit() {
        
        menuView.addSubview(bgImageView)
        menuView.sendSubviewToBack(bgImageView)
        menuView.addSubview(tableView)
        menuView.addSubview(loginAfter)
        menuView.addSubview(loginBefore)
        
        //初始菜单
        view.addSubview(menuView)
        
        //初始化主窗体
        addChildViewController(mainNavViewController)
        view.addSubview(mainNavViewController.view)
        
        //菜单subviews
        bgImageView.contentMode = .ScaleToFill
        
        loginAfter.addSubview(headerView)
        loginAfter.addSubview(nameLabel)
        loginBefore.addSubview(wechatButton)
        loginBefore.addSubview(qqButton)
        loginBefore.addSubview(moreButton)
        loginBefore.addSubview(welcomeLabel)
        loginBefore.addSubview(descLabel)
        
        welcomeLabel.text = "Hello!"
        if #available(iOS 9.0, *) {
            welcomeLabel.font = UIFont(name: Font.defaultFont, size: 36)
        } else {
            // Fallback on earlier versions
        }

        descLabel.text   = "登录/注册"
        wechatButton.addTarget(self, action: "wechatLogin", forControlEvents: .TouchUpInside)
        moreButton.addTarget(self, action: "moreLogin", forControlEvents: .TouchUpInside)
        qqButton.addTarget(self, action: "qqLogin", forControlEvents: .TouchUpInside)
        
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = view.bounds.height * 0.5 * 0.2
        tableView.registerClass(MenuSettingTableViewCell.self, forCellReuseIdentifier: SlideMenuOptions.MenuTableViewCellID)
        tableView.separatorStyle = .None
        tableView.scrollEnabled = false
        
        //添加手势
        menuView.addGestureRecognizer(panGestureRecognizer2)
        
    }
    
    private func isInstallLoginClientSide() {
        
        let wechaInstall = Device.isWeixinInstalled()
        let qqInstall    = Device.isQQInstalled()
        
        if wechaInstall && qqInstall {
            qqButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 40), offset: CGPointMake(0, 0))
            wechatButton.ff_AlignHorizontal(.CenterLeft, referView: qqButton, size: CGSizeMake(42, 40), offset: CGPointMake(-40,0))
            moreButton.ff_AlignHorizontal(.CenterRight, referView: qqButton, size: CGSizeMake(42, 40), offset: CGPointMake(40,0))
        } else if !wechaInstall && !qqInstall {
            moreButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 42), offset: CGPointMake(0, 0))
            wechatButton.hidden = true
            qqButton.hidden = true
        } else if !wechaInstall {
            qqButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 40), offset: CGPointMake(-40, 0))
            moreButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 40), offset: CGPointMake(40, 0))
            wechatButton.hidden = true
        } else if !qqInstall {
            wechatButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 40), offset: CGPointMake(-40, 0))
            moreButton.ff_AlignInner(.BottomCenter, referView: loginBefore, size: CGSizeMake(42, 40), offset: CGPointMake(40, 0))
            qqButton.hidden = true
        }
    }
    
    func refreshMask() {
        let masked = self.slideMenuState == SlideMenuState.Opening ? true : false
        maskView.hidden = !masked
    }
    
    //初始化自动布局
    private func setupAutoLayout() {
        //menu
        menuView.ff_AlignInner(.TopLeft, referView: view, size: CGSizeMake(SlideMenuOptions.DrawerWidth, view.bounds.height - 20), offset: CGPointMake(0, 20))
        bgImageView.ff_Fill(menuView)
        tableView.ff_AlignInner(.CenterCenter, referView: menuView, size: CGSizeMake(SlideMenuOptions.DrawerWidth, view.bounds.height * 0.5), offset: CGPointMake(0, 50))
        
        loginAfter.ff_AlignInner(.TopCenter, referView: menuView, size: CGSizeMake(bgImageView.bounds.width * 0.6, view.bounds.height * 0.2), offset: CGPointMake(0, 54))
        headerView.ff_AlignInner(.TopCenter, referView: loginAfter, size: CGSizeMake(60, 60), offset: CGPointMake(0, 0))
        nameLabel.ff_AlignVertical(.BottomCenter, referView: headerView, size: nil, offset: CGPointMake(0, 8))
        
        if UIScreen.mainScreen().bounds.width == 320 {
            loginBefore.ff_AlignInner(.TopCenter, referView: menuView, size: CGSizeMake(SlideMenuOptions.DrawerWidth, view.bounds.height * 0.2 + 10), offset: CGPointMake(0, 34))
        } else {
            loginBefore.ff_AlignInner(.TopCenter, referView: menuView, size: CGSizeMake(SlideMenuOptions.DrawerWidth, view.bounds.height * 0.17), offset: CGPointMake(0, 54))
        }
        
        welcomeLabel.ff_AlignInner(.TopCenter, referView: loginBefore, size: nil, offset: CGPointMake(0, 0))
        descLabel.ff_AlignInner(.CenterCenter, referView: loginBefore, size: nil, offset: CGPointMake(0, -5))
        
        //main
        maskView.ff_Fill(mainViewController.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.layer.cornerRadius = min(headerView.bounds.width, headerView.bounds.height) * 0.5
        headerView.clipsToBounds = true
    }
    
    //MARK: - 刷新登陆状态
    func refreshLoginStatus() {
        if let user = globalUser {
            loginAfter.hidden = false
            loginBefore.hidden = true
            if user.icon == "" {
                headerView.image = PlaceholderImage.defaultUser
            } else {
                headerView.sd_setImageWithURL(NSURL(string: user.icon))
            }
            nameLabel.text = user.nickname
        } else {
            loginBefore.hidden = false
            loginAfter.hidden = true
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserInfoChangeNotification, object: nil)
    }
    
    
    func userInfoDidChangeNotification(notification: NSNotification) {
        refreshLoginStatus()
    }
    
    // MARK: tableView数据源方法
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SlideMenuOptions.MenuTableViewCellID, forIndexPath: indexPath) as! MenuSettingTableViewCell
        //cell选中效果
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.titleLabel.text = tableViewDataSource[indexPath.row]
        
        //最后一行无底部横线
        if indexPath.row == tableViewDataSource.count - 1 {
            cell.isBaseLineVisabled = false
        }
        
        return cell
    }
    
    //跳转控制器
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        curVCType = usingVCTypes[indexPath.row]
    }
    
    // MARK: 自定义方法
    //用户touch的点位置
    var panGestureStartLocation : CGPoint!
    
    var menuAlpha:CGFloat = 0.0 {
        didSet{
            menuView.alpha = menuAlpha
        }
    }
    
    
    /// 登陆后的操作
    var loginFinishedHandler: UserLogin.LoginFinishedHandler = { (result, error) -> Void in
        if error != nil {
            let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
            hud.textLabel.text = "登陆失败啦，再试试手气"
            hud.showInView(UIApplication.sharedApplication().keyWindow)
            hud.dismissAfterDelay(3.0)
        }
    }
    
    func tapGestureHandler(sender: UITapGestureRecognizer){
        if sender.state == .Ended {
            toggle()
        }
    }
    
    //左右滑动效果
    func panGestureHandler(sender: UIPanGestureRecognizer) {
        //用户对视图操控的状态。
        let state    = sender.state;
        let location = sender.locationInView(mainNavViewController.view)
        var frame    = mainNavViewController.view.frame
        
        var startX:CGFloat = 0.0
        switch (state) {
        case UIGestureRecognizerState.Began:
            //记录用户开始点击的位置
            panGestureStartLocation = location;
            startX = frame.origin.x
            break;
        case UIGestureRecognizerState.Changed:
            //相比起点Began的x轴距离(每次.Changed调用是累计的
            let xOffSet = sender.translationInView(view).x
            //右滑动
            if (xOffSet > 0 && xOffSet < SlideMenuOptions.DrawerWidth){
                if (slideMenuState == SlideMenuState.Closing){
                    frame.origin.x = xOffSet + startX
                }
                //左滑动
            }else if (xOffSet < 0 && xOffSet > -SlideMenuOptions.DrawerWidth){
                if (slideMenuState == SlideMenuState.Opening){
                    frame.origin.x = xOffSet + SlideMenuOptions.DrawerWidth
                }
            }
            mainNavViewController.view.frame = frame;
            //alpha=[0.5 ~ 1.0]
            menuAlpha = min(0.5 + frame.origin.x / SlideMenuOptions.DrawerWidth, 1.0)
            break;
        case UIGestureRecognizerState.Ended:
            let xOffSet = sender.translationInView(view).x
            //超过阀值需要自动
            if abs(xOffSet) > SlideMenuOptions.AutoSlideXOffSet {
                if xOffSet < 0 && slideMenuState == SlideMenuState.Opening {
                    didClose()
                }else if xOffSet > 0 && slideMenuState == SlideMenuState.Closing {
                    didOpen()
                }
            } else {
                reset()
            }
            break;
        default:
            break;
        }
    }
    
    //打开侧边栏
    func didOpen(){
        //设置主窗体的结束位置
        var mainSize = mainNavViewController.view.frame
        mainSize.origin.x = SlideMenuOptions.DrawerWidth
        menuAlpha = max(0.5, menuAlpha)
        //动效
        UIView.animateWithDuration(0.7,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations:{ [weak self] in
                self?.mainNavViewController.view.frame = mainSize;
                self?.menuAlpha = 1.0 },
            completion: { [weak self] (finished: Bool) -> Void in
                self?.menuAlpha = 1.0
            }
        )
        
        //将侧边栏的装填标记为打开状态
        slideMenuState = SlideMenuState.Opening
        
        refreshMask()
    }
    
    //关闭侧边栏
    func didClose(){
        //点击关闭时要将当前状态标记为关闭
        if slideMenuState == SlideMenuState.Opening {
            slideMenuState = SlideMenuState.Closing
        }
        //将主窗体的起始位置恢复到原始状态
        var mainSize = mainNavViewController.view.frame
        mainSize.origin.x = 0
        menuAlpha = min(1.0, menuAlpha)
        UIView.animateWithDuration(0.7,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { [weak self] in
                self?.mainNavViewController.view.frame = mainSize;
                self?.menuAlpha = 0.5 },
            completion: { [weak self] (finished: Bool) -> Void in
                //偶尔右滑到底时被执行！why
                //self.menuAlpha = 0.0
            }
        )
        
        refreshMask()
    }
    
    // MARK: SlideMenuViewControllerDelegate
    
    func toggle() {
        if slideMenuState == SlideMenuState.Opening {
            didClose()
        } else {
            didOpen()
        }
    }
    
    func reset(){
        if slideMenuState == SlideMenuState.Opening {
            didOpen()
        } else {
            didClose()
        }
    }
    
    // MARK: 支持第三方登录
    //微信登陆
    func wechatLogin() {
        UserLogin.sharedInstance.thirdLogin(LoginType.Weixin, finishHandler: loginFinishedHandler){ (_) -> Void in
        }
        
    }
    
    //qq登陆
    func qqLogin() {
        UserLogin.sharedInstance.thirdLogin(LoginType.QQ, finishHandler: loginFinishedHandler){ (_) -> Void in
        }
    }
    
    // 更多登陆方式
    func moreLogin() {
        definesPresentationContext = true
        navigationController
        let lovc = LoginViewController()
        let nav = UINavigationController(rootViewController: lovc)
        presentViewController(nav, animated: true, completion: nil)
    }
}
