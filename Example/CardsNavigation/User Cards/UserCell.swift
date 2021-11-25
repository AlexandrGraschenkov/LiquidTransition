//
//  UserCell.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 23.05.2021.
//  Copyright © 2021 Alex Development. All rights reserved.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var onLongPress: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected(_:)))
        contentView.addGestureRecognizer(gesture)
    }

    func display(user: GUser) {
        nameLabel.text = user.login
        
        let requestSize = Int(avatarImgView.bounds.width)
        let avatarUrl = GithubAPIService.shared.avatarUrl(id: user.id, size: requestSize)
        let scale = CGFloat(UIScreen.main.scale)
        let size = CGSize(width: avatarImgView.bounds.width * scale,
                          height: avatarImgView.bounds.height * scale)
        let processor = ResizingImageProcessor(referenceSize: size) |> RoundCornerImageProcessor(cornerRadius: avatarImgView.bounds.width)
        avatarImgView.kf.setImage(with: avatarUrl, options: [
            .backgroundDecode,
            .cacheSerializer(FormatIndicatedCacheSerializer.png),
            .processor(processor)])
    }

    @objc
    func longPressDetected(_ long: UILongPressGestureRecognizer) {
        if long.state == .began {
            onLongPress?()
        }
    }
}
