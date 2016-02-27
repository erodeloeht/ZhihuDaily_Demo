//
//  CommentsTableViewController.swift
//  Zhihu
//
//  Created by Lisong Xu on 2/26/16.
//  Copyright © 2016 Lisong Xu. All rights reserved.
//

import UIKit
import Alamofire

class CommentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var id = ""
    var commentList = [AnyObject]()
    var commenterList = [AnyObject]()

    @IBOutlet weak var tableView: UITableView!
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let commentsUrl = "http://news-at.zhihu.com/api/4/story/" + id + "/long-comments"

        Alamofire.request(.GET, commentsUrl).responseJSON { (response) -> Void in
            let jsonDict = response.result.value as? [String: AnyObject]
            //get content body
            if let comments = jsonDict?["comments"] as? [[String: AnyObject]] {
                if comments.count > 0 {
                    for comment in comments {
                        self.commentList.append(comment["content"]!)
                        self.commenterList.append(comment["author"]!)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CommentTableViewCell
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            cell.author.text = self.commenterList[indexPath.row] as? String
            cell.comment.text = self.commentList[indexPath.row] as? String
        }
        
        return cell
    }


}
