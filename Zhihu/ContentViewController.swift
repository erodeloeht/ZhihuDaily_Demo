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

class ContentViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var imageView = UIImageView()
    var url = "http://news-at.zhihu.com/api/4/news/"
    var css = ""
    var html = "<html>"
    var imageURL = ""
    var loading = UIActivityIndicatorView()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // add loading indicator
        loading.color = UIColor.grayColor()
        loading.center = self.view.center
        self.view.addSubview(loading)
        loading.startAnimating()
        
        //request story content and image
        Alamofire.request(.GET, url).responseJSON { (response) -> Void in
            //get json data
            let jsonDict = response.result.value as? [String: AnyObject]
            //get content body
            let body = jsonDict!["body"] as! String
            //get content css style link
            if let css = jsonDict!["css"] as? [String] {
                self.css = css[0]
            }
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
            self.html += self.css
            self.html += "\""
            self.html += "</head>"
            self.html += "<body>"
            self.html += body
            self.html += "</body>"
            self.html += "</html>"
            //load content
            self.webView.loadHTMLString(self.html, baseURL: nil)
            self.loading.stopAnimating()
        }
    }
}
