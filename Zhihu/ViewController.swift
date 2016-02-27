//
//  ViewController.swift
//  Zhihu
//
//  Created by Lisong Xu on 2/20/16.
//  Copyright © 2016 Lisong Xu. All rights reserved.
//

import UIKit
import Haneke
import Alamofire


var nightMode = false

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var refreshControl = UIRefreshControl()
    let todayurl = "http://news-at.zhihu.com/api/4/news/latest"
    let olderurl = "http://news.at.zhihu.com/api/4/news/before/"
    var date = ""
    var titles = [String]()
    var ids = [String]()
    var images = [String]()
    var refreshTimes = 1
    var recentDate = NSDate()
    var dateString = ""
    var previousStories = 0
    var dateHeadeIndexArray = [0]
    var dateSeperator = [DateTableViewCell]()
    var dateLabels = ["今日热闻"]
    var loading = UIActivityIndicatorView()

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            if nightMode == false {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
                tableView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                dateLabel.textColor = UIColor.whiteColor()
                self.view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                nightMode = true
                tableView.reloadData()
                UIApplication.sharedApplication().statusBarStyle = .LightContent
                
            }
            else {
                self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
                self.view.backgroundColor = UIColor.whiteColor()
                dateLabel.textColor = UIColor.blackColor()
                tableView.backgroundColor = UIColor.whiteColor()
                nightMode = false
                tableView.reloadData()
                UIApplication.sharedApplication().statusBarStyle = .Default
            }
        }
    }

    //get dotay's stories
    func getArticles(url: String) {
        Alamofire.request(.GET, url).responseJSON { (response) -> Void in
            //get json data
            let jsonDict = response.result.value as? [String: AnyObject]
            if let date = jsonDict?["date"] as? String {
                self.date = date
                let dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "zh_Hans_CN")
                dateFormatter.dateFormat = "yyyyMMdd"
                self.recentDate = dateFormatter.dateFromString(date)!
                dateFormatter.dateStyle = .LongStyle
                self.dateString = dateFormatter.stringFromDate(self.recentDate)
                self.titles.append(self.dateString)
                self.images.append(self.dateString)
                self.ids.append(self.dateString)
                self.dateLabels.append(self.dateString)
            }
            if let stories = jsonDict?["stories"] as? [Dictionary<String, AnyObject>] {
                self.previousStories += stories.count
                self.dateHeadeIndexArray.append(self.previousStories + self.refreshTimes)
                for story in stories {
                    self.titles.append(story["title"]! as! String)
                    self.ids.append(String(story["id"]!))
                    if let image = story["images"] as? [String] {
                        self.images += image
                    }
                }    
            }
            self.tableView.reloadData()
        }
    }
   
    // get more stories
    func getoldArticles(date: String){
        refreshTimes += 1
        let newDate = self.olderurl + date
        getArticles(newDate)
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_Hans_CN")
        dateFormatter.dateFormat = "yyyyMMdd"
        self.date = dateFormatter.stringFromDate(self.recentDate)
    }


    // pull to refresh function
    func refresh() {

        titles = [String]()
        ids = [String]()
        images = [String]()
//        dateLabels = ["今日热闻"]
        refreshTimes = 1
        dateHeadeIndexArray = [0]
        previousStories = 0
        getArticles(todayurl)
//        getoldArticles(date)
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.navigationController?.navigationBarHidden = false
        tableView.reloadData()
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        
        
        //pan to show menu
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //set automatic row height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 76
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //add loading indicator
        loading.center = self.view.center
        loading.color = UIColor.grayColor()
        self.view.addSubview(loading)
   
        //add pull to refresh
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.grayColor()
        
        loading.startAnimating()
        
        //get today's stories
        getArticles(todayurl)
        
        loading.stopAnimating()
//        getoldArticles(date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if titles.count > 0 {
            return titles.count}
        else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let readStories = NSUserDefaults.standardUserDefaults().objectForKey("readStories") as? [String]
        //set dateseperator cell
        if dateHeadeIndexArray.contains(indexPath.row)  {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("dateCell") as! DateTableViewCell
            dateSeperator.append(cell)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.dateLabel.text = self.titles[indexPath.row]
            })
            return cell
        }
        //set stories cell
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ArticleTableViewCell
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.titles.count > 0 {
                    cell.titleLabel.text = self.titles[indexPath.row]
                    cell.thumbNail.hnk_setImageFromURL(NSURL(string: self.images[indexPath.row])!)
                    //set read stories text color to gray
                    if nightMode {
                        cell.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                        cell.titleLabel.textColor = UIColor.whiteColor()
                        if readStories?.count > 0 {
                            if readStories!.contains(self.ids[indexPath.row]) {
                                cell.titleLabel.textColor = UIColor.grayColor()
                            } else {
                                cell.titleLabel.textColor = UIColor.whiteColor()
                            }
                        }
                    } else {
                        cell.backgroundColor = UIColor.whiteColor()
                        cell.titleLabel.textColor = UIColor.blackColor()
                        if readStories?.count > 0 {
                            if readStories!.contains(self.ids[indexPath.row]) {
                                cell.titleLabel.textColor = UIColor.grayColor()
                            } else {
                                cell.titleLabel.textColor = UIColor.blackColor()
                            }
                        }
                    }
                }
            })
            //load more stories when croll to end
            if indexPath.row == self.titles.count - 2 {
                getoldArticles(date)
            }
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //store read stories ids
        var readStories = NSUserDefaults.standardUserDefaults().objectForKey("readStories") as? [String]
        if readStories == nil {
            readStories = [ids[indexPath.row]]
        } else {
            readStories!.append(ids[indexPath.row])
        }
        NSUserDefaults.standardUserDefaults().setObject(readStories, forKey: "readStories")
        
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        for cell in dateSeperator {
            if let cellRow = tableView.indexPathForCell(cell) {
                let rect = tableView.rectForRowAtIndexPath(cellRow)
                let rectInSuperView = tableView.convertRect(rect, toView: tableView.superview)
                if rectInSuperView.minY <= 64 {
                    dateLabel.text = cell.dateLabel.text
                } else {
                    dateLabel.text = dateLabels[dateLabels.indexOf(cell.dateLabel.text!)! - 1]
                }
                if dateLabel.text == dateLabels[1] {
                    dateLabel.text = "今日热闻"
                }
            }
        }
    }

    //prepare for segue to story content view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArticle" {
            let destVC = segue.destinationViewController as! ContentViewController
            // disable segue when tap on date seperator cell
            if dateHeadeIndexArray.contains(tableView.indexPathForSelectedRow!.row) {
                return
            } else {
                //pass story id
                destVC.url += ids[tableView.indexPathForSelectedRow!.row]
                destVC.id += ids[tableView.indexPathForSelectedRow!.row]
            }
            
        }
    }

}

