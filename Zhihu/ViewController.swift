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


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    let baseurl = "http://news-at.zhihu.com/api/4/news"
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

    //get dotay's stories
    func getArticles(url: String) {

        do {
            let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments)
            if let date = jsonDict["date"] as? String {
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
                
            }
            if let stories = jsonDict["stories"] as? [Dictionary<String, AnyObject>] {
                self.previousStories += stories.count
                self.dateHeadeIndexArray.append(previousStories + self.refreshTimes)
                for story in stories {
                    titles.append(story["title"]! as! String)

                    ids.append(String(story["id"]!))
                   if let image = story["images"] as? [String] {
                        images += image
                    }
                }
            }
            
            
        } catch {
            
        }
        tableView.reloadData()
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
        tableView.reloadData()
        
    }
    
    // more stories button
    @IBAction func moreButton(sender: AnyObject) {
        getoldArticles(self.date)
        
    }

    // pull to refresh function
    func refresh() {
        titles = [String]()
        ids = [String]()
        images = [String]()
        refreshTimes = 1
        dateHeadeIndexArray = [0]
        previousStories = 0
        getArticles(todayurl)
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.addSubview(refreshControl)
        tableView.reloadData()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //set automatic row height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 76
        
        //get today's stories
        getArticles(todayurl)
        getoldArticles(date)
        
        
        //add pull to refresh
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.grayColor()
        
 
    }

    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let readStories = NSUserDefaults.standardUserDefaults().objectForKey("readStories") as? [String]
        //set dateseperator cell
        if dateHeadeIndexArray.contains(indexPath.row)  {
            let cell = tableView.dequeueReusableCellWithIdentifier("dateCell") as! DateTableViewCell
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.dateLabel.text = self.titles[indexPath.row]
            })
            return cell
        }
        //set stories cell
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ArticleTableViewCell
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.titleLabel.text = self.titles[indexPath.row]
                cell.thumbNail.hnk_setImageFromURL(NSURL(string: self.images[indexPath.row])!)
                //set read stories text color to gray
                if readStories?.count > 0 {
                    if readStories!.contains(self.ids[indexPath.row]) {
                        cell.titleLabel.textColor = UIColor.grayColor()
                    } else {
                        cell.titleLabel.textColor = UIColor.blackColor()
                    }
                }
            })
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
    
    let threshold = CGFloat(100.0) // threshold from bottom of tableView
    var isLoadingMore = false // flag
    
    //load new stories when scroll to end
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !isLoadingMore && (maximumOffset - contentOffset <= threshold) {
            // Get more data - API call
            self.isLoadingMore = true
            
            // Update UI
            dispatch_async(dispatch_get_main_queue()) {
                self.getoldArticles(self.date)
                self.isLoadingMore = false
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
                
                
            }
            
        }
    }

}

