//
//  SearchBaseViewController.swift
//  GetOnTrip
//
//  Created by 何俊华 on 15/8/5.
//  Copyright (c) 2015年 Joshua. All rights reserved.
//

import UIKit
import FFAutoLayout
import SVProgressHUD

public let SearchContentKeyWordType: String = "keyword"
public let SearchContentTopicType  : String = "topic"
public let SearchContentBookType   : String = "book"

class SearchResultsViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    var resultData = [String : AnyObject]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var contentData = [SearchContent]()
    
    var sectionTitle = [String]()
    
    var titleMap = ["sight":"景点", "city":"城市", "content":"内容"]
        
    var page    : String = "1"
    
    let pageSize: String = "6"
    
    var cityId = ""
    
    /// 搜索提示
    var searchResult: UILabel = UILabel(color: UIColor(hex: 0xFFFFFF, alpha: 0.6), title: "当前搜索无内容", fontSize: 14, mutiLines: true)
    /// 定位城市
    var locationCity: UIButton = UIButton(image: "location_Yellow", title: " 即刻定位当前城市", fontSize: 12, titleColor: UIColor(hex: 0xF3FD54, alpha: 1.0))
    
    var scrollLock:Bool = false
    
    var tableView = UITableView()
    
    var pageNum = 1
    
    var recordLoadButton: UIButton?
    
    var filterString: String = "" {
        didSet {

            if self.filterString == "" {
                self.resultData.removeAll()
                self.contentData.removeAll()
                self.tableView.reloadData()
                return
            }
            
            SearchResultsRequest.sharedSearchResultRection.fetchSearchResultsModels(page, pageSize: pageSize, filterString: filterString) { (rows) -> Void in
                if self.filterString != "" {
                    self.resultData = rows as! [String : AnyObject]
                    if (rows["content_num"]!!.intValue == 0) && (rows["city_num"]!!.intValue == 0) && (rows["sight_num"]!!.intValue == 0) {
                        self.searchResult.hidden = false
                    }
                }
            }
        }
    }
    
    //MARK: View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAddProperty()
        setupAutoLayout()
    }

    private func setupAddProperty() {
        
        view.addSubview(tableView)
        view.addSubview(searchResult)
        view.addSubview(locationCity)
        
        
        locationCity.addTarget(self, action: "switchCurrentCity:", forControlEvents: UIControlEvents.TouchUpInside)
        searchResult.sendSubviewToBack(view)
        searchResult.hidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame:CGRectZero)
        tableView.separatorColor  = UIColor.grayColor()
        tableView.rowHeight = 60
        tableView.backgroundView = UIImageView(image: UIImage(named: "search-bg0")!)
        tableView.registerClass(SearchResultsCell.self, forCellReuseIdentifier: "SearchResults_Cell")
        tableView.registerClass(ShowMoreTableViewCell.self, forCellReuseIdentifier: "ShowMoreTableView_Cell")
    }
    
    func switchCurrentCity(btn: UIButton) {
        
        if cityId == "" {
            locationCity.hidden = true
            searchResult.text = "当前城市未开通"
        } else {
            
            if cityId == "-1" { SVProgressHUD.showErrorWithStatus("未能获取权限定位失败!"); return }
            let vc = CityViewController()
            vc.cityId = cityId
            let nav = UINavigationController(rootViewController: vc)
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
            presentViewController(nav, animated: true, completion: nil)

        }
    }
    
    private func setupAutoLayout() {
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: CGSizeMake(view.bounds.width, view.bounds.height), offset: CGPointMake(0, 0))
        locationCity.ff_AlignInner(ff_AlignType.TopCenter, referView: view, size: nil, offset: CGPointMake(0, 92))
        searchResult.ff_AlignInner(ff_AlignType.BottomCenter, referView: locationCity, size: nil, offset: CGPointMake(0, 81))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if contentData.count != 0 { return 1 }
        return resultData.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if contentData.count != 0 { return "" }
        switch section {
        case 0:
            if resultData["searchCitys"]!.count == 0 { return "" }
            return "城市"
        case 1:
            if resultData["searchSights"]!.count == 0 { return "" }
            return "景点"
        case 2:
            if resultData["searchContent"]!.count == 0 { return "" }
            return "内容"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let sc = parentViewController as! SearchViewController
        sc.recordData.insert(filterString, atIndex: 0)
        if sc.recordData.count >= 6 {
            sc.recordData.removeLast()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let data = resultData["searchCitys"] as! [SearchResult]
            if data.count == indexPath.row { return }
        case 1:
            let data = resultData["searchSights"] as! [SearchResult]
            if data.count == indexPath.row { return }
        case 2:
            let Contentdata = resultData["searchContent"] as! [SearchContent]
            if Contentdata.count == indexPath.row { return }
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if let searchCity = resultData["searchCitys"] {
                
                let vc = CityViewController()
                let searchC = searchCity[indexPath.row] as! SearchResult
                vc.cityId = searchC.id!
                let nav = UINavigationController(rootViewController: vc)
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
                presentViewController(nav, animated: true, completion: nil)
            }
        case 1:
            if let searchSight = resultData["searchSights"] {
                
                let vc = SightViewController()
                let searchC = searchSight[indexPath.row] as! SearchResult
                vc.sightId = searchC.id!
                let nav = UINavigationController(rootViewController: vc)
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
                presentViewController(nav, animated: true, completion: nil)
                
            }
        case 2:
            if let searchContent = resultData["searchContent"] as? [SearchContent] {
                
                let searchType = searchContent[indexPath.row]
                if searchType.search_type == SearchContentKeyWordType {
                    let vc = DetailWebViewController()
                    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
                    vc.url = searchType.url
                    let nav = UINavigationController(rootViewController: vc)
                    presentViewController(nav, animated: true, completion: nil)
                } else if searchType.search_type == SearchContentTopicType {
                    let vc = TopicDetailController()
                    vc.topicId = searchType.id!
                    let nav = UINavigationController(rootViewController: vc)
                    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
                    presentViewController(nav, animated: true, completion: nil)
                } else if searchType.search_type ==  SearchContentBookType {
                    let vc = SightBookDetailController()
                    vc.bookId = searchType.id!
                    let nav = UINavigationController(rootViewController: vc)
                    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: vc, action: "dismissViewController")
                    presentViewController(nav, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
//        let frame = CGRectMake(0, view.frame.size.height-1, view.frame.width, 0.5)
//        let line  = UIView(frame: frame)
//        line.backgroundColor = UIColor.grayColor()
//        view.addSubview(line)
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.lightGrayColor()
        headerView.textLabel!.font = UIFont.systemFontOfSize(11)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contentData.count != 0 { return contentData.count }
        switch section {
        case 0:
            let num = resultData["city_num"]?.intValue
                let resultCount = (resultData["searchCitys"]!.count)!
                if Int(num!) <= resultCount {
                    return resultCount
                } else {
                    return resultCount + 1
                }
            
        case 1:
             let num = resultData["sight_num"]?.intValue
                let resultCount = (resultData["searchSights"]!.count)!
                if Int(num!) <= resultCount {
                    return resultCount
                } else {
                    return resultCount + 1
            }
            
        case 2:
             let num = resultData["content_num"]?.intValue
                let resultCount = (resultData["searchContent"]!.count)!
                if Int(num!) <= resultCount {
                    return resultCount
                } else {
                    return resultCount + 1
            }
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if contentData.count != 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SearchResults_Cell", forIndexPath: indexPath) as! SearchResultsCell
            cell.searchContent = contentData[indexPath.row]
            
            if contentData.count - 1 == indexPath.row {
                
                if pageNum != -1 {
                    pageNum++
                    loadMoreAction(recordLoadButton!)
                }
            }
            return cell
        }

        switch indexPath.section {
        case 0:
            let data = resultData["searchCitys"]! as! [SearchResult]
            if data.count == indexPath.row {
                let cellMore = tableView.dequeueReusableCellWithIdentifier("ShowMoreTableView_Cell", forIndexPath: indexPath) as! ShowMoreTableViewCell
                cellMore.showMore.addTarget(self, action: "loadMoreAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cellMore.showMore.setTitle("显示全部城市", forState: UIControlState.Normal)
                cellMore.showMore.tag = 2
                return cellMore
            }
        case 1:
            let data = resultData["searchSights"] as! [SearchResult]
            if data.count == indexPath.row {
                let cellMore = tableView.dequeueReusableCellWithIdentifier("ShowMoreTableView_Cell", forIndexPath: indexPath) as! ShowMoreTableViewCell
                cellMore.showMore.addTarget(self, action: "loadMoreAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cellMore.showMore.setTitle("显示全部景点", forState: UIControlState.Normal)
                cellMore.showMore.tag = 1
                return cellMore
            }
        case 2:
            let Contentdata = resultData["searchContent"] as! [SearchContent]
            if Contentdata.count == indexPath.row {
                let cellMore = tableView.dequeueReusableCellWithIdentifier("ShowMoreTableView_Cell", forIndexPath: indexPath) as! ShowMoreTableViewCell
                cellMore.showMore.addTarget(self, action: "loadMoreAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cellMore.showMore.setTitle("显示全部内容", forState: UIControlState.Normal)
                cellMore.showMore.tag = 3
                return cellMore
            }
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResults_Cell", forIndexPath: indexPath) as! SearchResultsCell
        cell.searchCruxCharacter = filterString
        switch indexPath.section {
        case 0:
            let data = resultData["searchCitys"] as! [SearchResult]
            cell.searchResult = data[indexPath.row]
        case 1:
            let data = resultData["searchSights"] as! [SearchResult]
            cell.searchResult = data[indexPath.row]
        case 2:
            let Contentdata = resultData["searchContent"] as! [SearchContent]

            let ContentType = Contentdata[indexPath.row]
                cell.searchContent = ContentType
        default:
            break
        }

        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Apperance of cell
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {

        if !searchController.active { return }
        
        filterString = searchController.searchBar.text!
        
        if searchController.searchBar.text != "" {
            searchResult.hidden = true
            locationCity.hidden = true
        } else {
            searchResult.hidden = true
            locationCity.hidden = false
        }
    }
    
    
    func loadMoreAction(btn: UIButton) {
        recordLoadButton = btn
        SearchMoreRequest.fetchMoreResult(btn.tag, page: pageNum, pageSize: 15, query: filterString) { (result) -> Void in
            
            let data = result["data"] as! [String : AnyObject]
            
            
            for item in data["data"] as! [[String : AnyObject]] {
                self.contentData.append(SearchContent(dict: item))
            }

            self.tableView.reloadData()
            
            if let pageN = data["num"]?.intValue {
                if Int(pageN / 15) <= self.pageNum {
                    self.pageNum = -1
                }
            }
        }
    }
}
