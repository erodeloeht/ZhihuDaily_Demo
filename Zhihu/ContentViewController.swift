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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clearColor()
//        self.navigationController?.navigationBarHidden = true
        
        Alamofire.request(.GET, url).responseJSON { (response) -> Void in
            let jsonDict = response.result.value as? [String: AnyObject]
            let body = jsonDict!["body"] as! String
            
            
            if let css = jsonDict!["css"] as? [String] {
                self.css = css[0]
            }
            if let imgURL = jsonDict!["image"] as? String {
                self.imageURL = imgURL
                
                self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
                self.imageView.contentMode = .ScaleAspectFill
                self.imageView.clipsToBounds = true
                self.imageView.hnk_setImageFromURL(NSURL(string: self.imageURL)!)
                self.webView.scrollView.addSubview(self.imageView)
            }
            
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

            self.webView.loadHTMLString(self.html, baseURL: nil)
        }
        
        

    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
