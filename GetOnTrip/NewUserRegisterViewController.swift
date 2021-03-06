
//
//  NewUserRegisterViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/20.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class NewUserRegisterViewController: BaseViewController {

    /// 邮箱
    lazy var emailTextField     = UITextField(alignment: NSTextAlignment.Left, sizeFout: 18, color: UIColor.blackColor())
    
    /// 密码
    lazy var passwordTextField  = UITextField(alignment: NSTextAlignment.Left, sizeFout: 18, color: UIColor.blackColor())
    
    /// 下一步按钮
    lazy var nextButton         = UIButton(title: "下一步", fontSize: 20, radius: 2, titleColor: UIColor.whiteColor())
    
    /// 邮箱字
    let emailLabel: UILabel     = UILabel(color: SceneColor.lightGrayEM, title: "  邮箱 ", fontSize: 18, mutiLines: true)
    
    /// 密码字
    let passwLabel: UILabel     = UILabel(color: SceneColor.lightGrayEM, title: "  密码 ", fontSize: 18, mutiLines: true)
    
    /// 用户协议
    lazy var userProtocolButton = UIButton(title: "", fontSize: 11, radius: 0, titleColor: UIColor(hex: 0xFFFFFF, alpha: 0.7))
    
    /// 用户
    lazy var userAgreeButton    = UIButton(image: "userProtocol_false", title: "", fontSize: 11)
    
    lazy var backButton         = UIButton(image: "back_white", title: "", fontSize: 0)
    
    lazy var navTitleLabel      = UILabel(color: UIColor.whiteColor(), title: "注册", fontSize: 24, mutiLines: true)
    
    let passwordEyeButton       = UIButton(image: "show_Password", title: "", fontSize: 20)
    
    lazy var keyboardTakebackBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initProperty()
        initView()
        initTextField()
        initAutoLayout()
    }
    
    private func initView() {
        
        view.addSubview(backButton)
        view.addSubview(navTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(userProtocolButton)
        view.addSubview(userAgreeButton)
    }
    
    private func initProperty() {
        view.backgroundColor = UIColor.whiteColor()
        let backgroundImageView = UIImageView(image: UIImage(named: "login_background"))
        view.addSubview(backgroundImageView)
        view.addSubview(keyboardTakebackBtn)
        backgroundImageView.frame = UIScreen.mainScreen().bounds
        keyboardTakebackBtn.frame = UIScreen.mainScreen().bounds
        keyboardTakebackBtn.addTarget(self, action: #selector(NewUserRegisterViewController.keyboardTakebackBtnAction(_:)), forControlEvents: .TouchUpInside)
        userAgreeButton.selected = true
        userAgreeButton.setImage(UIImage(named: "userProtocol_true"), forState: .Selected)
        userAgreeButton.addTarget(self, action: #selector(NewUserRegisterViewController.userAgreeAction(_:)), forControlEvents: .TouchUpInside)
        userProtocolButton.addTarget(self, action: #selector(NewUserRegisterViewController.userProtocolAction(_:)), forControlEvents: .TouchUpInside)
        backButton.addTarget(self, action: #selector(NewUserRegisterViewController.backAction), forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: #selector(NewUserRegisterViewController.nexButtonAction), forControlEvents: .TouchUpInside)
        passwordEyeButton.addTarget(self, action: #selector(NewUserRegisterViewController.passwordEyeButton(_:)), forControlEvents: .TouchUpInside)
        nextButton.backgroundColor = SceneColor.lightblue
        userProtocolButton.setAttributedTitle("我已阅读并同意《用户注册协议》"
        .getAttributedStringColor("《用户注册协议》", normalColor: UIColor(hex: 0xFFFFFF, alpha: 0.7), differentColor: SceneColor.lightblue), forState: .Normal)
        emailLabel.font = UIFont(name: Font.defaultFont, size: 18)
        passwLabel.font = UIFont(name: Font.defaultFont, size: 18)
        nextButton.titleLabel?.font = UIFont(name: Font.defaultFont, size: 18)
        navTitleLabel.font = UIFont(name: Font.defaultFont, size: 24)
    }

    private func initTextField() {
        
        let size = emailLabel.text?.sizeofStringWithFount1(UIFont.systemFontOfSize(18), maxSize: CGSizeMake(CGFloat.max, CGFloat.max))
        emailTextField.borderStyle         = UITextBorderStyle.RoundedRect
        emailTextField.autocorrectionType  = UITextAutocorrectionType.Default
        emailTextField.returnKeyType       = UIReturnKeyType.Done
        emailTextField.keyboardType        = UIKeyboardType.EmailAddress
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
        emailTextField.clearButtonMode     = UITextFieldViewMode.WhileEditing
        emailTextField.leftView            = emailLabel
        emailTextField.leftViewMode        = UITextFieldViewMode.Always
        emailLabel.bounds           = CGRectMake(0, 0, size!.width, size!.height)
        
        passwordTextField.borderStyle      = UITextBorderStyle.RoundedRect
        passwordTextField.leftView         = passwLabel
        passwordTextField.leftViewMode     = UITextFieldViewMode.Always
        passwordTextField.rightView        = passwordEyeButton
        passwordTextField.rightViewMode    = UITextFieldViewMode.Always
        passwordEyeButton.bounds           = CGRectMake(0, 0, 36, 11)
        passwordTextField.autocorrectionType = UITextAutocorrectionType.Default
        passwordTextField.returnKeyType    = UIReturnKeyType.Done
        passwordTextField.clearButtonMode  = UITextFieldViewMode.WhileEditing
        passwordTextField.secureTextEntry  = true
        passwLabel.bounds                  = CGRectMake(0, 0, size!.width, size!.height)
    }
    
    private func initAutoLayout() {
        let screen = UIScreen.mainScreen().bounds
        let size = CGSizeMake(screen.width - 110, 42)
        backButton.ff_AlignInner(.TopLeft, referView: view, size: CGSizeMake(13, 26), offset: CGPointMake(12, 42))
        navTitleLabel.ff_AlignInner(.TopCenter, referView: view, size: nil, offset: CGPointMake(0, 42))
        emailTextField.ff_AlignInner(.TopCenter, referView: view, size: size, offset: CGPointMake(0, screen.height * 0.21))
        passwordTextField.ff_AlignVertical(.BottomCenter, referView: emailTextField, size: size, offset: CGPointMake(0, 6))
        userAgreeButton.ff_AlignVertical(.BottomLeft, referView: passwordTextField, size: CGSizeMake(15, 15), offset: CGPointMake(0, 5))
        userProtocolButton.ff_AlignHorizontal(.CenterRight, referView: userAgreeButton, size: nil, offset: CGPointMake(5, 0))
        nextButton.ff_AlignVertical(.BottomCenter, referView: passwordTextField, size: size, offset: CGPointMake(0, 78))
    }
    
    // MARK: - 自定义方法
    func userAgreeAction(btn: UIButton) {
        btn.selected = !btn.selected
    }
    
    func userProtocolAction(btn: UIButton) {
        let vc = DetailWebViewController()
        vc.url = "http://www.getontrip.cn/privacy"
        vc.navBar.backButton.setTitle("注册", forState: .Normal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "注册", style: .Plain, target: "", action: nil)
        vc.navBar.titleLabel.text = "用户注册协议"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // 收回键盘方法
    func keyboardTakebackBtnAction(btn: UIButton) {
        view.endEditing(true)
    }
    
    // 显示密码
    func passwordEyeButton(btn: UIButton) {
        btn.selected = !btn.selected
        btn.alpha = btn.selected ? 0.4 : 0.8
        passwordTextField.secureTextEntry  = btn.selected
    }
    
    // 下一步操作按钮
    func nexButtonAction() {
        
        if userAgreeButton.selected == false {
            ProgressHUD.showSuccessHUD(self.view, text: "请阅读《用户注册协议》")
            return
        }
        
        let emailStr = emailTextField.text ?? ""
        let passwStr = passwordTextField.text ?? ""
        if RegexString.validateEmail(emailStr) {
            if RegexString.validatePassword(passwStr) {
                UserRegisterRequest.userRegister(emailStr, passwd: passwStr, handler: { (result, status) -> Void in
                    if status == RetCode.SUCCESS {
                        globalUser = UserAccount(email: emailStr, passwd: passwStr)
                        UserLogin.sharedInstance.loadAccount({ (result, status) -> Void in
                            if status == RetCode.SUCCESS {
                                let vc = self.parentViewController?.presentingViewController as? SlideMenuViewController
                                vc?.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    vc?.curVCType = RecommendViewController.self
                                })
                            } else {
                                ProgressHUD.showErrorHUD(self.view, text: "注册失败，请稍候注册")
                            }
                        })
                    } else {
                        if RetCode.getShowMsg(status) == "" {
                            ProgressHUD.showErrorHUD(self.view, text: "注册失败，请稍候注册")
                        } else {
                            ProgressHUD.showErrorHUD(self.view, text: RetCode.getShowMsg(status))
                        }
                    }
                })
            } else {
                ProgressHUD.showErrorHUD(self.view, text: "请输入6～32位字母、数字及常用符号组成")
            }
        } else {
            ProgressHUD.showErrorHUD(self.view, text: "邮箱格式错误")
        }
    }
}
