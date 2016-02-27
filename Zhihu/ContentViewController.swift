//
//  ContentViewController.swift
//  Zhihu
//
//  Created by Lisong Xu on 2/20/16.
//  Copyright © 2016 Lisong Xu. All rights reserved.
//

import UIKit
import Haneke
import Alamofire

class ContentViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func next(sender: AnyObject) {
        
    }
    
    
    
    var imageView = UIImageView()
    var id = ""
    var url = "http://news-at.zhihu.com/api/4/news/"
    var css = ""
    var html = "<html>"
    var imageURL = ""
    var loading = UIActivityIndicatorView()
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide navigation bar
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // add loading indicator
        loading.color = UIColor.grayColor()
        loading.center = self.view.center
        self.view.addSubview(loading)
        loading.startAnimating()
        //request story content and image
        
        if nightMode {
            self.webView.opaque = false
            self.webView.backgroundColor = UIColor.clearColor()
            toolbar.barTintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        } else {
            self.webView.opaque = false
            self.webView.backgroundColor = UIColor.whiteColor()
            toolbar.barTintColor = UIColor.lightGrayColor()
        }
        
        Alamofire.request(.GET, url).responseJSON { (response) -> Void in
            //get json data
            let jsonDict = response.result.value as? [String: AnyObject]
            //get content body
            let body = jsonDict!["body"] as! String
            //get content css style link
//            if let css = jsonDict!["css"] as? [String] {
//                self.css = css[0]
//            }
            //get image URL and pass on to imageView which is embedded in webView as scrollview
            if let imgURL = jsonDict!["image"] as? String {
                self.imageURL = imgURL
                
                self.imageView.frame = CGRect(x: 0, y: -20, width: self.view.frame.width, height: 220)
                self.imageView.contentMode = .ScaleAspectFill
                self.imageView.clipsToBounds = true
                self.imageView.hnk_setImageFromURL(NSURL(string: self.imageURL)!)
                self.webView.scrollView.addSubview(self.imageView)
            }
            //put content body and css together as html
            self.html += "<head>"
            self.html += "<link rel=\"stylesheet\" href="
            self.html += "\""
            self.html += "style.css"
            self.html += "\""
            self.html += "</head>"
            if !nightMode {
                self.view.backgroundColor = UIColor.whiteColor()
                self.html += "<body>"
            } else {
                self.view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                self.html += "<body class=\"night\">"
            }
            self.html += body
            self.html += "</body>"
            self.html += "</html>"
            let mainbundle = NSBundle.mainBundle().bundlePath
            let bundleURL = NSURL(fileURLWithPath: mainbundle)

            self.webView.loadHTMLString(self.html, baseURL: bundleURL)
            self.loading.stopAnimating()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if nightMode {
            webView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        } else {
            webView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showComments" {
            let destVC = segue.destinationViewController as! CommentsTableViewController
            destVC.id = self.id
        }
    }
    
}
