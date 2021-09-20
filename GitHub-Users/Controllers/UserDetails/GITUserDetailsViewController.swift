//
//  GITUserDetailsViewController.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 17/09/21.
//

import UIKit
import WebKit

class GITUserDetailsViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var gitUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let urlStirng = gitUrl else { return }
        guard let url = URL(string: urlStirng) else { return  }
        let request = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(request)       // load git hib url
    }
}

extension GITUserDetailsViewController:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
