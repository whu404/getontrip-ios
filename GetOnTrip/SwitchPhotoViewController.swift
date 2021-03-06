//
//  SwitchPhotoViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/7.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

/// 选取照片控制器
class SwitchPhotoViewController: MenuViewController {
    
    /// 照片view
    var photoView: PhotoView = PhotoView()
    
    lazy var bottomView = UIView(color: UIColor.blackColor(), alphaF: 0.7)
    
    var cancelBtn = UIButton(title: "取消", fontSize: 20, radius: 0)
    
    var trueBtn = UIButton(title: "确定", fontSize: 20, radius: 0)
    
    lazy var shade: PhotoShadeView = PhotoShadeView(color: UIColor.clearColor(), alphaF: 1.0)
    
    /// 是否保存的是用户的背景图片
    var isSaveBackImageBool: Bool = false {
        didSet {
            shade.isRound = !isSaveBackImageBool
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleLabel.text = "选择照片"
        navBar.rightButton.removeFromSuperview()
        navBar.rightButton2.removeFromSuperview()
        navBar.setBackBarButton(UIImage(named: "icon_back"), title: nil, target: self, action: #selector(SwitchPhotoViewController.popViewAction(_:)))
        
        view.backgroundColor = SceneColor.bgBlack
        shade.userInteractionEnabled = true
        shade.multipleTouchEnabled = true
        view.clipsToBounds = true
        view.addSubview(photoView)
        view.addSubview(shade)
        view.addSubview(bottomView)
        bottomView.addSubview(cancelBtn)
        bottomView.addSubview(trueBtn)
        photoView.ff_AlignInner(.TopLeft, referView: view, size: UIScreen.mainScreen().bounds.size, offset: CGPointMake(0, 0))
        shade.ff_AlignInner(.TopLeft, referView: view, size: UIScreen.mainScreen().bounds.size, offset: CGPointMake(0, 0))
        bottomView.ff_AlignInner(.BottomLeft, referView: view, size: CGSize(width: view.bounds.width, height: 44), offset: CGPointMake(0, 0))
        cancelBtn.ff_AlignInner(.CenterLeft, referView: bottomView, size: CGSizeMake(50, 44), offset: CGPointMake(0, 0))
        trueBtn.ff_AlignInner(.CenterRight, referView: bottomView, size: CGSizeMake(50, 44), offset: CGPointMake(0, 0))
        
        cancelBtn.addTarget(self, action: #selector(SwitchPhotoViewController.cancelAction(_:)), forControlEvents: .TouchUpInside)
        trueBtn.addTarget(self, action: #selector(SwitchPhotoViewController.trueAction), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = Frame.screen.width / min(photoView.imgPhoto.image!.size.width, photoView.imgPhoto.image!.size.height)
        photoView.imgPhoto.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    ///  取消按钮方法
    func cancelAction(btn: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    ///  确定按钮方法
    func trueAction() {
        // TODO: - 如果是用户的个人背景图片，那就将图片使用双倍图
        let imageData = UIImagePNGRepresentation(photoView.savePhotoAction().scaleImage(isSaveBackImageBool ? Frame.screen.width * 2: 200))
        
        ProgressHUD.sharedProgressHUD.showOperationPrompt(nil, text: "正在保存中", style: nil) { [weak self] (handler) -> Void in
            let fileName = self?.isSaveBackImageBool ?? true ? "backimg" : "file"
            UserLogin.sharedInstance.uploadUserInfo([fileName : imageData], sex: nil, nick_name: nil) { (result, status) -> Void in
                handler()
                if status == RetCode.SUCCESS {
                    UserLogin.sharedInstance.loadAccount({ (result, status) -> Void in
                        if status == RetCode.SUCCESS {
                            ProgressHUD.showSuccessHUD(nil, text: "保存成功")
                            self?.navigationController?.popViewControllerAnimated(true)
                        } else {
                            ProgressHUD.showErrorHUD(nil, text: "保存失败")
                        }
                    })
                } else {
                    ProgressHUD.showErrorHUD(self?.view, text: RetCode.getShowUNE(status ?? 0))
                }
            }
        }
    }
}

/// 照片遮罩
class PhotoShadeView: UIView {
    
    /// 是否是圆
    var isRound:Bool = false
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for item in super.superview!.subviews {
            if item.isKindOfClass(NSClassFromString("GetOnTrip.PhotoView")!) {
                let it = item as? PhotoView
                return it?.imgPhoto
            }
            
        }
        return super.hitTest(point, withEvent: event)
    }
    
    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()        
        CGContextAddRect(ctx, rect)
        UIColor(hex: 0x939393, alpha: 0.7).setFill()
        CGContextFillPath(ctx)
        let ctx1 = UIGraphicsGetCurrentContext()
        let w: CGRect = UIScreen.mainScreen().bounds
        if isRound {
            CGContextAddEllipseInRect(ctx1, CGRectMake(0, w.height * 0.5 - w.width * 0.5, w.width, w.width))
        } else {
            CGContextAddRect(ctx1, CGRectMake(0, w.height * 0.5 - w.width * 0.5, w.width, w.width))
        }
        CGContextSetLineCap(ctx1, CGLineCap.Round)
        CGContextSetLineJoin(ctx1, CGLineJoin.Round)
        CGContextSetBlendMode(ctx1, CGBlendMode.Copy)
        UIColor.clearColor().setFill()
        CGContextFillPath(ctx1)
        
    }
}
