//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Lawrence Chen on 2/18/16.
//  Copyright © 2016 Lawrence Chen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet var webview: UIWebView!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        // Checks to see if detailItem exist
        // Then checks if webview item exists
        // Then loads content html string in it
        if let detail = self.detailItem {
            if let postWebView = self.webview {
                postWebView.loadHTMLString(detail.valueForKey("content")!.description, baseURL: NSURL(string:"http://googleblog.blogspot.com/"))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

