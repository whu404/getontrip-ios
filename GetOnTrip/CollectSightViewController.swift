//
//  CollectSightViewController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/9/8.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit

let reuseIdentifier1 = "CollectionViewCell"

class CollectSightViewController: UICollectionViewController {
    
    /// 界面布局
    let layout = UICollectionViewFlowLayout()
    
    /// 网络请求加载数据
    var lastSuccessRequest: CollectSightRequest?

    /// 数据模型
    var collectSights = [CollectSight]()
    
    init() {
        super.init(collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.clearColor()
        let w: CGFloat = 170
        let h: CGFloat = 150
        // 每个item的大小
        layout.itemSize = CGSizeMake(w, h)
        // 行间距
        layout.minimumLineSpacing = 15
        // item之间水平间距
        let lw: CGFloat = (UIScreen.mainScreen().bounds.width - w * 2) / 3
        layout.minimumInteritemSpacing = lw
        layout.sectionInset = UIEdgeInsets(top: 0, left: lw, bottom: 0, right: lw)
        // Register cell classes
        collectionView?.registerClass(CSCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier1)

        refresh()
    }
    

    
    private func refresh() {
        NSLog("notice:refreshing nearby data.")
        
        //获取数据更新tableview
        if lastSuccessRequest == nil {
            lastSuccessRequest = CollectSightRequest()
        }
        
        lastSuccessRequest?.fetchCollectSightModels { (handler: [CollectSight]) -> Void in
            self.collectSights = handler
            self.collectionView?.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectSights.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier1, forIndexPath: indexPath) as! CSCollectionViewCell
        
        cell.collectSight = collectSights[indexPath.row] as CollectSight
        return cell
    }
}
// 收藏景点的cell
class CSCollectionViewCell: UICollectionViewCell {
    
    lazy var iconView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()
    
    lazy var title: UILabel = {
        var lab = UILabel()
        lab.bounds = CGRectMake(0, 0, 150, 20)
        lab.textColor = UIColor.whiteColor()
        lab.font = UIFont.boldSystemFontOfSize(16)
        lab.textAlignment = NSTextAlignment.Center
        return lab
    }()
    
    lazy var subtitle: UILabel = {
        var lab = UILabel()
        lab.textAlignment = NSTextAlignment.Center
        lab.font = UIFont.systemFontOfSize(9)
        lab.textColor = UIColor(white: 1.0, alpha: 0.7)
        lab.bounds = CGRectMake(0, 0, 150, 20)
        return lab
    }()
    
    var collectSight: CollectSight? {
        didSet {
            iconView.sd_setImageWithURL(NSURL(string: collectSight!.image!))
            title.text = collectSight?.name
            subtitle.text = collectSight?.topicNum
        }
    }
    
    lazy var bottomView: UIView = {
        var v = UIView()
        v.backgroundColor = UIColor(hex: 0x747474, alpha: 0.5)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(bottomView)
        addSubview(title)
        addSubview(subtitle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.frame = self.bounds
        bottomView.frame = self.bounds
        title.frame = CGRectMake(0, self.bounds.height * 0.5, self.bounds.width, 20)
        subtitle.frame = CGRectMake(0, self.bounds.height - 20, self.bounds.width, 20)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
