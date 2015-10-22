//
//  CommentTopicController.swift
//  GetOnTrip
//
//  Created by 王振坤 on 15/10/13.
//  Copyright © 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout

class CommentTopicController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var lastCommentRequest = TopicCommentRequest()
    
    /// 话题ID
    var topicId: String?
    
    /// 评论内容tableview
    lazy var commentTableView: UITableView = UITableView()
    /// 发布底部view
    lazy var issueCommentView: UIView = UIView(color: UIColor.whiteColor())
    /// 发布textfield
    lazy var issueTextfield: UITextField = UITextField()
    /// 发布按钮
    lazy var issueCommentBtn: UIButton = UIButton(title: "确认发布", fontSize: 12, radius: 10, titleColor: UIColor(hex: 0x696969, alpha: 1.0))
    
    var commentBottomConst: NSLayoutConstraint?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.orangeColor()
        view.addSubview(commentTableView)
        view.addSubview(issueCommentView)
        issueCommentView.addSubview(issueTextfield)
        issueCommentView.addSubview(issueCommentBtn)
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        issueCommentView.backgroundColor = UIColor.redColor()
        commentTableView.backgroundColor = UIColor.greenColor()
        issueTextfield.backgroundColor = UIColor.purpleColor()
        issueCommentBtn.backgroundColor = UIColor.cyanColor()
        
        
        

//        loadCommentData()
        setupAutoLayout()
    }

    private func loadCommentData() {
        
        if lastCommentRequest.topicId == nil {
            lastCommentRequest.topicId = topicId
        }
        
        lastCommentRequest.fetchTopicCommentModels {(handler: TopicDetail) -> Void in
//            self.messageLists = handler
//            self.tableView.reloadData()
        }
    }
    

    
    private func setupAutoLayout() {
        
        
        commentTableView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: CGSizeMake(view.bounds.width, 444 - 50), offset: CGPointMake(0, 0))
        let const = issueCommentView.ff_AlignInner(ff_AlignType.BottomLeft, referView: view, size: CGSizeMake(view.bounds.width, 50), offset: CGPointMake(0, 0))
        issueTextfield.ff_AlignInner(ff_AlignType.CenterLeft, referView: issueCommentView, size: CGSizeMake(view.bounds.width - 19 - 15 - 91, 34), offset: CGPointMake(9, 0))
        issueCommentBtn.ff_AlignInner(ff_AlignType.CenterRight, referView: issueCommentView, size: CGSizeMake(19, 34), offset: CGPointMake(19, 0))
        commentBottomConst = issueCommentView.ff_Constraint(const, attribute: NSLayoutAttribute.Bottom)
    }
    

    
    // MARK: - tableview datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        issueTextfield.resignFirstResponder()
    }
    
}
