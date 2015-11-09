//
//  SettingViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/2.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout
import Alamofire
import SVProgressHUD

/// 定义选中的是第几行
struct SettingCell {
    /// 0
    static let iconCell = 0
    /// 1
    static let nickCell = 1
    /// 2
    static let sexCell  = 2
    /// 3
    static let cityCell = 3
}

class SettingViewController: MenuViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    static let name = "设置"
    
    lazy var tableView: UITableView = UITableView()
    
    /// 头像
    lazy var iconView: UIImageView = UIImageView()
    
    /// 昵称
    lazy var nickName: UITextField = UITextField(alignment: NSTextAlignment.Right, sizeFout: 14, color: UIColor.blackColor())
    /// 性别
    lazy var gender: UILabel = UILabel(color: UIColor.blackColor(), title: "男", fontSize: 14, mutiLines: false)
    
    /// 临时保存性别
    var saveGender: String?
    
    /// 城市
    lazy var city: UILabel = UILabel(color: UIColor.blackColor(), title: "未知", fontSize: 14, mutiLines: false)
    
    /// 临时保存城市
    var saveCity: String = ""
    var saveTown: String = ""
    
    /// 省市联动
    var provinces = [Province]() {
        didSet {
            pickView.reloadAllComponents()
        }
    }
    
    /// 当前省的索引
    var provinceIndex: Int = 0
    
    /// pick切换数据源方法 如果是true则是姓别，false是城市
    var pickViewSourceNameAndCity: Bool = false
    
    var lastProvinceIndex: Int = 0
    
    /// 选择城市/姓别
    lazy var pickView: UIPickerView = UIPickerView(color: UIColor.whiteColor(), hidde: true)
    
    /// 选择底部的view
    lazy var cancleBottomView: UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50))
    
    /// 取消按钮
    lazy var cancleButton: UIButton = UIButton(title: "取消", fontSize: 18, radius: 2, titleColor: SceneColor.frontBlack)

    /// 确定按钮
    lazy var trueButton: UIButton = UIButton(title: "确定", fontSize: 18, radius: 2, titleColor: SceneColor.frontBlack)
    
    /// 性别按钮
    lazy var sortButton: UIButton = UIButton(title: "性别", fontSize: 18, radius: 2, titleColor: SceneColor.frontBlack)
    
    /// 遮罩
    lazy var shadeView: UIButton = UIButton(color: UIColor.blackColor(), alphaF: 0.0)
    
    /// 退出登陆按钮
    lazy var exitLogin: UIButton = UIButton(title: "退出登录", fontSize: 14, radius: 0, titleColor: UIColor.blackColor())
    
    var saveButton: Bool = false {
        didSet {
            navBar.rightButton.enabled = saveButton
        }
    }
    
    /// 切换照片控制器
    var switchPhotoVC: SwitchPhotoViewController = SwitchPhotoViewController()

    // MARK: - 初始化相关设置
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(switchPhotoVC)
        setupAddProperty()
        setupBarButtonItem()
        loadInitSetting()
        setupInitSetting()
    }
    
    
    ///  初始化属性
    private func setupAddProperty() {

        navBar.setTitle(SettingViewController.name)
//        navBar.rightButton.setTitleColor(UIColor.yellowColor(), forState: UIControlState)
        view.addSubview(tableView)
        cancleBottomView.backgroundColor = SceneColor.whiteGray
        cancleBottomView.addSubview(trueButton)
        cancleBottomView.addSubview(sortButton)
        cancleBottomView.addSubview(cancleButton)
        cancleButton.backgroundColor = SceneColor.lightYellow
        trueButton.backgroundColor   = SceneColor.lightYellow
        sortButton.backgroundColor   = UIColor.clearColor()
        
        view.addSubview(exitLogin)
        exitLogin.backgroundColor = UIColor(hex: 0xF0F0F0, alpha: 1.0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        saveButton = false
        shadeView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        cancleButton.addTarget(self, action: "shadeViewClick", forControlEvents: UIControlEvents.TouchUpInside)
        trueButton.addTarget(self, action: "trueButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        sortButton.addTarget(self, action: "sortClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        tableView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: CGSizeMake(view.bounds.width, view.bounds.height - 64), offset: CGPointMake(0, 64))
        cancleButton.ff_AlignInner(ff_AlignType.CenterLeft, referView: cancleBottomView, size: CGSizeMake(64, 30), offset: CGPointMake(10, 0))
        sortButton.ff_AlignInner(ff_AlignType.CenterCenter, referView: cancleBottomView, size: CGSizeMake(64, 30), offset: CGPointMake(0, 0))
        trueButton.ff_AlignInner(ff_AlignType.CenterRight, referView: cancleBottomView, size: CGSizeMake(64, 30), offset: CGPointMake(-10, 0))
        exitLogin.ff_AlignInner(ff_AlignType.BottomLeft, referView: view, size: CGSizeMake(view.bounds.width, 50), offset: CGPointMake(0, 0))
    }
    
    ///  初始化设置
    private func setupInitSetting() {
        title = SettingViewController.name
        
        iconView.sd_setImageWithURL(NSURL(string: sharedUserAccount?.icon ?? ""), placeholderImage: PlaceholderImage.defaultSmall)
        
        
        if      sharedUserAccount?.gender.hashValue == 0 { gender.text = "男" }
        else if sharedUserAccount?.gender.hashValue == 1 { gender.text = "女" }
        else                                             { gender.text = "未知"}
        
        city.text = sharedUserAccount?.city
        nickName.text = sharedUserAccount?.nickname
    }
    
    ///  初始化导航
    private func setupBarButtonItem() {
        
        navBar.rightButton.removeTarget(self, action: "searchAction:", forControlEvents: UIControlEvents.TouchUpInside)
        navBar.setRightBarButton(nil, title: "保存", target: self, action: "saveUserInfo:")
        navBar.rightButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nickNameTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: nickName)

    }
    
    ///  昵称的文本改变时调用的通知
    ///
    ///  - parameter notification: 通知
    func nickNameTextFieldTextDidChangeNotification(notification: NSNotification) {
        
        let textField = notification.object as! UITextField
        nickName.text = textField.text
        
        if sharedUserAccount?.nickname != textField.text { saveButton = true } else { saveButton = false }
    }
    
    ///  移除通知
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nickName)
    }
    
    
    ///  初始化设置
    private func loadInitSetting() {
        // tableview设置
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // 省市联动
        pickView.dataSource = self
        pickView.delegate = self
        
        LocateBarterCity.getCityProvinceInfo { (result, status) -> Void in
            if status == RetCode.SUCCESS {
                if let data = result {
                    self.provinces = data
                    self.pickerView(self.pickView, didSelectRow: 0, inComponent: 0)
                } else {
                    SVProgressHUD.showErrorWithStatus("数据加载错误，请稍候再试")
                }
            } else {
                SVProgressHUD.showErrorWithStatus("城市加载失败您的网络不稳定")
            }
        }
        
        // 退出登陆
        exitLogin.addTarget(self, action: "exitLoginClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    ///  退出登陆
    func exitLoginClick() {
        print("退出登录")
        sharedUserAccount?.exitLogin()
        sharedUserAccount = nil
        // 将页面返回到首页
        let vc = parentViewController as! UINavigationController

        let nav = vc.parentViewController as! SlideMenuViewController
        nav.curVCType = RecommendViewController.self
    }
    
    func sortClick(btn: UIButton) {
        if pickViewSourceNameAndCity == true {
            btn.setTitle("性别", forState: UIControlState.Normal)
        } else {
            btn.setTitle("城市", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pickerView(pickView, didSelectRow: 0, inComponent: 0)
    }
    
    func shadeViewClick() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.shadeView.alpha = 0.0
            self.pickView.frame.origin.y = UIScreen.mainScreen().bounds.height
            self.cancleBottomView.frame.origin.y = UIScreen.mainScreen().bounds.height
        }) { (_) -> Void in
            self.shadeView.removeFromSuperview()
            self.pickView.removeFromSuperview()
            self.cancleBottomView.removeFromSuperview()
        }
    }
    
    // MARK: - tableview delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel(color: UIColor(hex: 0x1C1C1C, alpha: 0.7), title: "   基本资料", fontSize: 11, mutiLines: false)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = settingTableViewCell()
        
            if indexPath.row == SettingCell.iconCell {

                let baseView = UIView(color: SceneColor.shallowGrey, alphaF: 0.3)
                cell.left.text = "头像"
                cell.addSubview(iconView)
                iconView.layer.cornerRadius = 66 * 0.5
                iconView.layer.masksToBounds = true
                iconView.ff_AlignInner(ff_AlignType.CenterRight, referView: cell, size: CGSizeMake(66, 66), offset: CGPointMake(-10, 0))
                cell.addSubview(baseView)
                baseView.ff_AlignInner(ff_AlignType.TopCenter, referView: cell, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 18, 0.5), offset: CGPointMake(0, 0))
                
            } else if indexPath.row == SettingCell.nickCell {
                
                cell.left.text = "昵称"
                cell.addSubview(nickName)
                nickName.ff_AlignInner(ff_AlignType.CenterRight, referView: cell, size: CGSizeMake(200, 17), offset: CGPointMake(-10, 0))
                
            } else if indexPath.row == SettingCell.sexCell {
                
                cell.left.text = "性别"
                cell.addSubview(gender)
                gender.ff_AlignInner(ff_AlignType.CenterRight, referView: cell, size: nil, offset: CGPointMake(-9, 0))
                
            } else {
                
                cell.left.text = "城市"
                cell.addSubview(city)
                city.ff_AlignInner(ff_AlignType.CenterRight, referView: cell, size: nil, offset: CGPointMake(-9, 0))
                cell.baseline.removeFromSuperview()
            }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 46 : 94
    }

    /// 每行的行高
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            if      indexPath.row == 0 { return 102}
            else if indexPath.row == 1 { return 51 }
            else if indexPath.row == 2 { return 51 }
            else                       { return 51 }
        } else {
            if      indexPath.row == 0 { return 51 }
            else                       { return 200}
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 退出键盘
        nickName.resignFirstResponder()
        
        /// 先切换数据源方法，再实现动画
        if indexPath.row == SettingCell.sexCell {
            pickViewSourceNameAndCity = true
            pickView.reloadAllComponents()
            sortClick(sortButton)
        }
        
        if indexPath.row == SettingCell.cityCell {
            pickViewSourceNameAndCity = false
            pickView.reloadAllComponents()
            sortClick(sortButton)
        }
        
        /// pickView 位置动画
        if indexPath.row == SettingCell.cityCell || indexPath.row == SettingCell.sexCell{
            
            let h: CGFloat = pickViewSourceNameAndCity ? 162 : 216
            let y1: CGFloat = UIScreen.mainScreen().bounds.height
            let w: CGFloat = UIScreen.mainScreen().bounds.width
            pickView.frame = CGRectMake(0, y1, w, h)
            let y: CGFloat = UIScreen.mainScreen().bounds.height - pickView.bounds.height
            cancleBottomView.frame = CGRectMake(0, y1, w, 44)
            
            UIApplication.sharedApplication().keyWindow!.addSubview(shadeView)
            shadeView.addTarget(self, action: "shadeViewClick", forControlEvents: UIControlEvents.TouchUpInside)
            UIApplication.sharedApplication().keyWindow!.addSubview(pickView)
            UIApplication.sharedApplication().keyWindow!.addSubview(cancleBottomView)
            
            pickView.hidden = false
            if pickView.frame.origin.y > y {
            pickView.frame.origin.y = UIScreen.mainScreen().bounds.height
            let cy: CGFloat = y1 - pickView.frame.height - 44
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.pickView.frame.origin.y = y
                    self.shadeView.alpha = 0.5
                    self.cancleBottomView.frame.origin.y = cy
                })
            }
        } else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.pickView.frame.origin.y = UIScreen.mainScreen().bounds.height
            })
        }
        
        if indexPath.row == SettingCell.iconCell {
            // 选择照片
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                return
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }

    }
    
    /// 头像图片
    var iconPhoto: UIImage? {
        didSet{
            iconView.image = iconPhoto?.scaleImage(200)
            if !(iconView.image!.isEqual(iconPhoto)) {
                saveButton = true
            } else {
                saveButton = false
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        

        navigationController?.pushViewController(switchPhotoVC, animated: true)
        switchPhotoVC.photoView.img = image
        self.dismissViewControllerAnimated(true, completion: nil)
//        // 重新设回导航栏样式
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    // MARK: - pickView dataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickViewSourceNameAndCity ? 1 : 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickViewSourceNameAndCity {
                return 2
            } else {
                if component == 0 {
                    return provinces.count
                } else {
                    let provinceIndex = pickerView.selectedRowInComponent(0)
                    return provinces[provinceIndex].city.count ?? 0
                }
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //省份选中
        if (component == 0 && pickViewSourceNameAndCity == false) {
            pickerView.reloadComponent(1)
            self.lastProvinceIndex = row
        }
        
        if pickViewSourceNameAndCity == false {
            if provinces.count == 0 { return }
            let provin = provinces[lastProvinceIndex] as Province
            switch (component) {
            case 0:
                saveCity = provin.name
                let city = provin.city
                saveTown = city[0]["name"]as? String ?? ""

                break;
            case 1:
                let city = provin.city
                saveTown = city[row]["name"] as? String ?? ""
                
                break;
            default:
                break;
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var label: UILabel?
        
        label = view != nil ? view as? UILabel : UILabel()
        
        label?.textAlignment = NSTextAlignment.Center
        
        if pickViewSourceNameAndCity {
            label?.text = row == 0 ? "男" : "女"
            saveGender = label?.text
        } else {
            
            label?.text = component == 0 ? provinces[row].name : provinces[lastProvinceIndex].city[row]["name"] as? String
        }
        return label!
    }
    
    
    // MARK: - other method
    /// 确定按钮
    func trueButtonClick(btn: UIButton) {
        
        if pickViewSourceNameAndCity {
            // 设置性别
            gender.text = saveGender
            pickView.selectedRowInComponent(0)
            
            var sex: Int?
            if gender.text == "男" { sex = 0 }
            else if gender.text == "女" { sex = 1 }
            else { sex = 2 }
            
            if sharedUserAccount?.gender != sex { saveButton = true } else { saveButton = false }
        } else {
            // 设置城市
            city.text = saveCity + saveTown
            if sharedUserAccount?.city != city.text { saveButton = true } else { saveButton = false }
            
        }
        shadeViewClick()
    }

    
    /// MARK: - 保存用户信息
    func saveUserInfo(item: UIBarButtonItem) {
    
        iconView.image?.scaleImage(200)
        let imageData = UIImagePNGRepresentation(iconView.image!) ?? NSData()
        var sex: Int?
        if gender.text == "男" {
            sex = 0
        } else if gender.text == "女" {
            sex = 1
        } else {
            sex = 2
        }

        sharedUserAccount?.uploadUserInfo(imageData, sex: sex, nick_name: nickName.text, city: city.text, handler: { (result, error) -> Void in
            if error == nil {
                SVProgressHUD.showInfoWithStatus("保存成功")
                self.saveButton = false
            }
        })
    }
    
}

// MARK: - settingTableViewCell
class settingTableViewCell: UITableViewCell {
    
    /// 左标签
    lazy var left: UILabel = UILabel(color: UIColor.blackColor(), title: "名字", fontSize: 14, mutiLines: false)
    
    /// 设置底线
    lazy var baseline: UIView! = UIView(color: SceneColor.shallowGrey, alphaF: 0.3)
    
    init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(baseline)
        addSubview(left)
        
        selectionStyle = UITableViewCellSelectionStyle.None
        baseline.ff_AlignInner(ff_AlignType.BottomCenter, referView: self, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 18, 0.5), offset: CGPointMake(0, 0))
        left.ff_AlignInner(ff_AlignType.CenterLeft, referView: self, size: nil, offset: CGPointMake(9, 0))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 省市模型
class Province : NSObject {
    
    var name: String = ""
    var city: NSArray = NSArray()
    
    init(dict: [String : AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) { }
}
