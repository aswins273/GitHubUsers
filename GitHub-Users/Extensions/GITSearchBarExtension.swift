//
//  GITSearchBarExtension.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 17/09/21.
//

import Foundation
import UIKit

extension UISearchBar {     // Extension to show loading indicator in search box
    public var textField: UITextField? {
        if #available(iOS 13, *) {
            return searchTextField
        }
        let subViews = self.subviews.flatMap {  $0.subviews }
        guard let textField  = (subViews.filter { $0 is UITextField}).first as? UITextField? else {
            return nil
        }
        return textField
    }
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{$0 as? UIActivityIndicatorView}.first
    }
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let activityIndicator = UIActivityIndicatorView(style: .medium)
                    activityIndicator.startAnimating()
                    activityIndicator.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
                    textField?.leftView?.addSubview(activityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    activityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            }
            else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
