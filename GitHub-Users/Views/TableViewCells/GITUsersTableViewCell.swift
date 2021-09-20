//
//  UsersTableViewCell.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 17/09/21.
//

import UIKit

class GITUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure (title: String?, imageUrl: String?) {
        if let title = title, title != "" {
            titleLabel.text = title
        }
        if let avatarUrl = imageUrl {       // set image
            CacheImage.shared.imageFromImageURL(urlString: avatarUrl, imageView: userImage)
        }
    }
}
