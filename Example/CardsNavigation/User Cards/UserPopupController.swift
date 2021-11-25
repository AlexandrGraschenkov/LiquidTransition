//
//  UserPopupController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 24.05.2021.
//  Copyright © 2021 Alex Development. All rights reserved.
//

import UIKit
import Kingfisher

class UserPopupController: UIViewController {

    func presentOn(controller: UIViewController) {
        guard let presentView = controller.view.window else {
            return
        }
        
        let closeButton = UIButton()
        closeButton.frame = presentView.bounds
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        closeButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        self.closeButton = closeButton
        
        let size = CGSize(width: 300, height: 161)
        let bounds = presentView.bounds
        let container = UIView(frame: CGRect(x: bounds.midX - size.width/2, y: bounds.midY - size.height/2, width: size.width, height: size.height))
        container.backgroundColor = .white
        container.layer.cornerRadius = 30
        container.clipsToBounds = true
        container.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        closeButton.addSubview(container)
        self.container = container
        
        self.view.frame = container.bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(self.view)
        
        controller.addChild(self)
        
        container.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).translatedBy(x: 0, y: 100)
        closeButton.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            closeButton.alpha = 1
            container.transform = .identity
        } completion: { (_) in }
    }
    
    var user: GUser?
    var fullUser: GUserFull?
    var api = GithubAPIService.shared
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var repositoriesLabel: UILabel!
    
    @IBOutlet weak var imgLeft: NSLayoutConstraint!
    @IBOutlet weak var imgTop: NSLayoutConstraint!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    var closeButton: UIButton?
    var container: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    @objc
    func closePressed() {
        UIView.animate(withDuration: 0.4) {
            self.closeButton?.alpha = 0
            //.backgroundColor = closeButton?.backgroundColor?.withAlphaComponent(0)
            self.container?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { (_) in
            self.closeButton?.removeFromSuperview()
            self.removeFromParent()
        }

        closeButton?.backgroundColor = closeButton?.backgroundColor?.withAlphaComponent(0)
    }
    
    func reloadData() {
        guard let user = user else {
            return
        }
        
        api.getUser(login: user.login) { (user, err) in
            guard let user = user else {
                return
            }
            
            self.fullUser = user
            self.display(fullUser: user)
        }
    }
    
    func display(fullUser: GUserFull) {
        let forceSize: CGFloat = 150
        let requestSize = Int(forceSize)
        let avatarUrl = api.avatarUrl(id: fullUser.id, size: requestSize)
        let scale = CGFloat(UIScreen.main.scale)
        let size = CGSize(width: forceSize * scale,
                          height: forceSize * scale)
        let processor = ResizingImageProcessor(referenceSize: size) |> RoundCornerImageProcessor(cornerRadius: 300)
        avatarImgView.kf.setImage(with: avatarUrl, options: [.processor(processor)])
        
        nameLabel.text = fullUser.name
        loginLabel.text = fullUser.login
        bioLabel.text = fullUser.bio
        
        var attr = NSMutableAttributedString(string: "Repositories: \(fullUser.publicRepos)")
        attr.addAttributes([.font: UIFont.boldSystemFont(ofSize: 15)], range: NSRange(location: 0, length: 13))
        repositoriesLabel.attributedText = attr
        
        attr = NSMutableAttributedString(string: "Followers(ing): \(fullUser.followers)/\(fullUser.following)")
        attr.addAttributes([.font: UIFont.boldSystemFont(ofSize: 15)], range: NSRange(location: 0, length: 15))
        followersLabel.attributedText = attr
        
        let textHeight = bioLabel.text?.height(withConstrainedWidth: bioLabel.bounds.width, font: bioLabel.font) ?? 0
        let center = container!.center
        
        var height: CGFloat = bioLabel.frame.minY + textHeight + 2
        if textHeight > 0 {
            height += 14
        }
        
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.container?.frame.size.height = height
            self.container?.center = center
        }
    }

}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
