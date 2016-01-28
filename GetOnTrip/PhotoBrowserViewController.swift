//
//  PhotoBrowserViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 16/1/7.
//  Copyright © 2016年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class PhotoBrowserViewController: UIViewController {
    // MARK: - 属性
    /// 数据源
    private var imageStrs: [String]
    private var describes: [String]
    /// 查看图片的索引
    private var currentIndex: Int
    /// layout
    lazy private var layout = UICollectionViewFlowLayout()
    /// collectionview
    lazy private var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    // 照片的选择属性
    private var photoScale: CGFloat = 0
    /// 图标
    lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "icon_app_rote"))
    /// 读图提示
    lazy var promptLabel: UILabel = UILabel(color: UIColor(hex: 0xFFFFFF, alpha: 0.7), title: "| 读图", fontSize: 20, mutiLines: true, fontName: Font.PingFangSCLight)
    /// 页码
    lazy var pageNumLabel: UILabel = UILabel(color: .whiteColor(), title: "/4", fontSize: 13, mutiLines: true, fontName: Font.PingFangSCRegular)
    /// 页数
    lazy var pageLabel: UILabel = UILabel(color: .whiteColor(), title: "3", fontSize: 16, mutiLines: true, fontName: Font.PingFangSCRegular)
    // MARK: -  初始化加载方法
    override func loadView() {
        // 将视图的大小`设大`
        initView()
    }
    
    private func initView() {
        var screenBounds = Frame.screen
        screenBounds.size.width += 20
        view = UIView(frame: screenBounds)
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(collectionView)
        view.addSubview(iconView)
        view.addSubview(promptLabel)
        view.addSubview(pageNumLabel)
        view.addSubview(pageLabel)
        
        iconView.ff_AlignInner(.TopLeft, referView: view, size: CGSizeMake(25, 26), offset: CGPointMake(10, 17))
        promptLabel.ff_AlignHorizontal(.CenterRight, referView: iconView, size: nil, offset: CGPointMake(10, 0))
        pageNumLabel.ff_AlignInner(.TopRight, referView: view, size: nil, offset: CGPointMake(-22, 21))
        pageLabel.ff_AlignHorizontal(.BottomLeft, referView: pageNumLabel, size: nil, offset: CGPointMake(0, 0))
        collectionView.ff_Fill(view)
        prepareCollectionView()
    }
    
    var isScroll:Bool = true
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        prepareLayout()
        // 跳转到用户选定的页面
        if isScroll {
            let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            isScroll = false
        }
        
    }
    
    // MARK: - 自定义方法
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///  返回当前显示图片的索引
    func currentImageIndex() -> Int {
        return collectionView.indexPathsForVisibleItems().last!.item
    }
    
    ///  获得当前显示的 图像视图
    func currentImageView() -> UIImageView {
        let indexPath = collectionView.indexPathsForVisibleItems().last
        let cell = collectionView.cellForItemAtIndexPath(indexPath!) as! PhotoViewerCell
        return cell.imageView
    }
    
    private func prepareLayout() {
        layout.itemSize = collectionView.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView.pagingEnabled = true
    }
    
    private func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.clearColor()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PhotoViewerCell.self, forCellWithReuseIdentifier: HMPhotoBrowserCellReuseIdentifier)
    }
    
    init(urls: [String], descs: [String], index: Int) {
        // 先初始化本类的属性
        imageStrs = urls
        describes = descs
        currentIndex = index
        
        // `再`调用系统提供的 `父类` 构造函数
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var temp: Int = 0 {
        didSet {
            self.pageLabel.text = "\(temp)"
        }
    }
}

private let HMPhotoBrowserCellReuseIdentifier = "HMPhotoBrowserCellReuseIdentifier"

extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate, PhotoViewerCellDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageNumLabel.text = "/\(imageStrs.count)"
        return imageStrs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMPhotoBrowserCellReuseIdentifier, forIndexPath: indexPath) as! PhotoViewerCell
        
        cell.imageStr = imageStrs[indexPath.item]
        cell.descLabel.attributedText = describes[indexPath.item].getAttributedString(0, lineSpacing: 7, breakMode: .ByTruncatingTail, fontName: Font.PingFangSCRegular, fontSize: 14)
        let h: CGFloat = describes[indexPath.item].sizeofStringWithFount(UIFont(name: Font.PingFangSCRegular, size: 14) ?? UIFont(name: Font.ios8Font, size: 14)!,
            maxSize: CGSizeMake(Frame.screen.width - 18, CGFloat.max), lineSpacing: 7).height
        cell.descScrollView.contentSize = CGSizeMake(Frame.screen.width - 18, h + 13)
        cell.descScrollView.hidden = describes[indexPath.item] == "" ? true : false
        cell.photoDelegate = self
        pageLabel.text = "\(indexPath.row + 1)"
        return cell
    }
    
    // 点击关闭
    func photoViewerCellDidTapImage() {
        // 关闭界面
        close()
    }
    
    ///  缩放进行中
    func photoViewerDidZooming(scale: CGFloat) {
        print(scale)
        // 交互式转场
        // 记录缩放比例
        photoScale = scale
        
        // 隐藏控件
        hideControl(photoScale < 1.0)
        
        // 判断如果缩放比例小于 1，开始交互式转场
        if photoScale < 1.0 {
            startInteractiveTransition(self)
        } else {
            // 恢复形变
            view.transform = CGAffineTransformIdentity
            view.alpha = 1.0
        }
    }
    
    func photoViewerDidEndZoom() {
        // 判断当前的缩放比例
        if photoScale < 0.8 {
            // 直接关闭 － 告诉转场动画结束
            completeTransition(true)
        } else {
            // 恢复控件
            hideControl(false)
            
            // 恢复形变
            view.transform = CGAffineTransformIdentity
            view.alpha = 1.0
        }
    }
    
    ///  隐藏控件
    private func hideControl(isHidden: Bool) {
        view.backgroundColor = isHidden ? UIColor.clearColor() : UIColor.blackColor()
    }
}

extension PhotoBrowserViewController: UIViewControllerInteractiveTransitioning, UIViewControllerContextTransitioning {
    
    ///  transitionContext 是提供专场所需的所有信息
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        // 缩放视图
        view.transform = CGAffineTransformMakeScale(photoScale, photoScale)
        // 设置透明度
        view.alpha = photoScale
    }
    
    func completeTransition(didComplete: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func containerView() -> UIView? { return self.view.superview }
    func isAnimated() -> Bool { return true }
    func isInteractive() -> Bool { return true }
    func transitionWasCancelled() -> Bool { return true }
    func presentationStyle() -> UIModalPresentationStyle { return UIModalPresentationStyle.Custom }
    func updateInteractiveTransition(percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func viewControllerForKey(key: String) -> UIViewController? { return self }
    func viewForKey(key: String) -> UIView? { return self.view }
    func targetTransform() -> CGAffineTransform { return CGAffineTransformIdentity }
    func initialFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
    func finalFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
}
