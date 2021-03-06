//
//  PhotoView.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/11/6.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class PhotoView: UIView, UIGestureRecognizerDelegate {

    var imgPhoto: UIImageView = UIImageView()
    
    /// 初始frame
    var initialImgPhotoFrame: CGRect = CGRectZero
    
    
    
    var img : UIImage = UIImage() {
        didSet{
            imgPhoto.image = img
            imgPhoto.bounds = CGRectMake(0, 0, img.size.width, img.size.height)
            imgPhoto.center = CGPointMake(UIScreen.mainScreen().bounds.width * 0.5, UIScreen.mainScreen().bounds.height * 0.5)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imgPhoto)
        imgPhoto.contentMode = UIViewContentMode.ScaleAspectFill
        imgPhoto.userInteractionEnabled = true
        imgPhoto.multipleTouchEnabled   = true
        /// 旋转
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(PhotoView.rotationGesture(_:)))
        rotation.delegate = self
        imgPhoto.addGestureRecognizer(rotation)
        
        /// 捏合手势, 缩放
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(PhotoView.pinchGesture(_:)))
        pinch.delegate = self
        imgPhoto.addGestureRecognizer(pinch)
        
        /// 拖拽手势, 平移
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PhotoView.panGesture(_:)))
        imgPhoto.addGestureRecognizer(pan)
        
        /// 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PhotoView.longPressGesture(_:)))
        imgPhoto.addGestureRecognizer(longPress)
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  得到一个view的父控制器
    ///
    ///  - returns: 它自己的父控制器 有它可以省很多麻烦
    func viewcontroller() -> UIViewController? {
        for var next = self.superview; (next != nil); next = next?.superview {
            let nextResponder = next?.nextResponder()
            if ((nextResponder?.isKindOfClass(NSClassFromString("GetOnTrip.SwitchPhotoViewController")!)) != nil) {
                return nextResponder as? UIViewController
            }
        }
        return nil
    }
    
    func longPressGesture(recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.Began {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                recognizer.view?.alpha = 0.5
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        recognizer.view?.alpha = 1
                        let vc = self.viewcontroller() as? SwitchPhotoViewController
                        vc?.trueAction()
                    })
            })
        }
    }
    
    ///  截图
    class func captureShotWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        view.layer.renderInContext(ctx!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func savePhotoAction() -> UIImage{
         return self.avatarSubtract(PhotoView.captureShotWithView(self))
    }
    
    func avatarSubtract(image: UIImage) -> UIImage {
        let w = UIScreen.mainScreen().bounds
        let tempImage = image.scaleImage(w.width)
        let image1 = CGImageCreateWithImageInRect(tempImage.CGImage, CGRectMake(0, (tempImage.size.height * 0.5 - tempImage.size.width * 0.5), tempImage.size.width, tempImage.size.width))
        return UIImage(CGImage: image1!)
    }
    
    // 捏合手势
    func pinchGesture(recognizer: UIPinchGestureRecognizer) {

        recognizer.view?.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        recognizer.scale = 1
        
        if recognizer.state == .Ended {
            let imgMin = min(imgPhoto.frame.width, imgPhoto.frame.height)
            if imgMin < Frame.screen.width {
                UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
                    let scale = Frame.screen.width / min(self?.imgPhoto.image!.size.width ?? 0, self?.imgPhoto.image!.size.height ?? 0)
                    recognizer.view?.transform = CGAffineTransformMakeScale(scale, scale)
                    recognizer.view!.center = self?.center ?? CGPointZero
                })
            }
        }
    }
    
    // 拖拽
    
    var temp: CGAffineTransform?
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        
        let translation = recognizer.translationInView(recognizer.view)
        recognizer.view?.transform = CGAffineTransformTranslate(recognizer.view!.transform, translation.x, translation.y)
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        
        if recognizer.state == .Ended {
            let screenWidthHalf = (Frame.screen.height - Frame.screen.width) * 0.5
            UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
                if self?.imgPhoto.frame.origin.x > 0 {
                    recognizer.view!.frame.origin.x = 0
                }
                if CGRectGetMaxX(self?.imgPhoto.frame ?? CGRectZero) < Frame.screen.width {
                    recognizer.view!.frame.origin.x = Frame.screen.width - recognizer.view!.frame.width
                }
                if self?.imgPhoto.frame.origin.y > screenWidthHalf {
                    recognizer.view!.frame.origin.y = screenWidthHalf
                }
                if CGRectGetMaxY(self?.imgPhoto.frame ?? CGRectZero) < (Frame.screen.height - screenWidthHalf) {
                    recognizer.view!.frame.origin.y = Frame.screen.height - recognizer.view!.frame.height - screenWidthHalf
                }
            })
        }
    }
    // 旋转
    func rotationGesture(recognizer: UIRotationGestureRecognizer) {
//        recognizer.view?.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
//        recognizer.rotation = 0
    }
}
