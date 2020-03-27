//
//  WebViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var url = ""
    
    //activity idicator
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        webView.navigationDelegate = self
        
        //activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.isHidden = true
        view.addSubview(activityIndicator)
        
        //webkit load
        let loadURL = URL (string: url)
        let request = URLRequest(url: loadURL!)
        webView.load(request)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         activityIndicator.isHidden = false
         activityIndicator.startAnimating()
     }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
         activityIndicator.stopAnimating()
         activityIndicator.isHidden = true
     }

    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

