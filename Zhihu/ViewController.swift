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

    let baseurl = "http://news-at.zhihu.com/api/4/news"
    
    let todayurl = "http://news-at.zhihu.com/api/4/news/latest"
    
    let olderurl = "http://news.at.zhihu.com/api/4/news/before/"
    var date = ""
//    var articles = [[String:AnyObject]]()
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
    
    @IBAction func moreButton(sender: AnyObject) {
        getoldArticles(self.date)
        
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        titles = [String]()
        ids = [String]()
        images = [String]()
        getArticles(todayurl)
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 76
        getArticles(todayurl)
 
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
        

        
        if dateHeadeIndexArray.contains(indexPath.row)  {
            let cell = tableView.dequeueReusableCellWithIdentifier("dateCell") as! DateTableViewCell
            cell.dateLabel.text = titles[indexPath.row]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ArticleTableViewCell
            cell.titleLabel.text = titles[indexPath.row]
            cell.thumbNail.hnk_setImageFromURL(NSURL(string: images[indexPath.row])!)
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArticle" {
            let destVC = segue.destinationViewController as! ContentViewController
            if dateHeadeIndexArray.contains(tableView.indexPathForSelectedRow!.row) {
                return
            } else {
                destVC.url += ids[tableView.indexPathForSelectedRow!.row]
            }
            
        }
    }

}

