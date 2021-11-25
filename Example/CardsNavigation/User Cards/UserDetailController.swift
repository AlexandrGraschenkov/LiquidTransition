//
//  UserListController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit
import Kingfisher
import Liquid
import TouchVisualizer



class UserDetailController: UIViewController {

    var user: GUser?
    var fullUser: GUserFull?
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var repositoriesLabel: UILabel!
    var users: [GUser] = []
    var api = GithubAPIService.shared
    var popup: UserPopupController?
    var animateVC: UserDetailController?
    var srcAnimate: AnimCornerRect?
    var fullDistProgress: CGFloat = 200
    var dstAnimate: AnimCornerRect?
    var touchView: TouchView?
    var lastProgress: CGFloat = .zero
    var imgAnimate = AnimCornerRect(fromRect: CGRect(x: 16, y: 16, width: 100, height: 100), toRect: CGRect(x: 10, y: 10, width: 150, height: 150), fromCorner: Corners(), toCorner: Corners())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
        table.deselectRows()
        
    }
    
    func reloadData() {
        guard let user = user else {
            return
        }
        
        api.getFollowing(login: user.login) { (users, err) in
            guard let users = users else {
                self.showError(err: err?.localizedDescription ?? "Can't load users")
                return
            }
            
            self.users = users
            self.table.reloadData()
        }
        
        if let fullUser = fullUser {
            display(fullUser: fullUser)
        } else {
            api.getUser(login: user.login) { (user, err) in
                guard let user = user else {
                    self.showError(err: err?.localizedDescription ?? "Can't load detail user info")
                    return
                }
                
                self.fullUser = user
                self.display(fullUser: user)
            }
        }
    }
    
    func display(fullUser: GUserFull) {
        let requestSize = Int(avatarImgView.bounds.height)
        let avatarUrl = api.avatarUrl(id: fullUser.id, size: requestSize)
        let scale = CGFloat(UIScreen.main.scale)
        let size = CGSize(width: avatarImgView.bounds.width * scale,
                          height: avatarImgView.bounds.height * scale)
        let processor = ResizingImageProcessor(referenceSize: size) |> RoundCornerImageProcessor(cornerRadius: avatarImgView.bounds.width)
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
        if let header = table.tableHeaderView {
            let height = 10 + textHeight + bioLabel.frame.minY
            header.frame.size.height = height
            table.tableHeaderView = header
        }
    }
    
    func showError(err: String) {
        let alert = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension UserDetailController {
    func showPopup(user: GUser) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "user_popup") as? UserPopupController else {
            return
        }
        table.isUserInteractionEnabled = false
        table.isUserInteractionEnabled = true
        popup = vc
        
        vc.user = user
        vc.presentOn(controller: self)
        
        vc.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
        
//        delay(1.5) {
//            self.simulateSwipe()
//        }
    }
    
    @objc
    func onPan(_ pan: UIPanGestureRecognizer) {
        let offset = pan.translation(in: view.window)
        if pan.state == .began && abs(offset.x) > -offset.y {
            pan.isEnabled = false
            pan.isEnabled = true
        }
        
        switch pan.state {
        case .began:
            setupTransition()
//            vc.modalPresentationStyle = .custom
            
            
//            vc?.modalPresentationStyle = .automatic
//            present(vc, animated: false) {
//            }
        case .changed:
            let progress = min(max(-offset.y / fullDistProgress, 0), 1)
            updateTransition(progress: progress)
//            Liquid.shared.update(progress: progress)
        
        case .cancelled:
            finishTransition(complete: false)
            
        default:
            let progress = min(max(-offset.y / 200.0, 0), 1)
            let complete = progress > 0.2
            finishTransition(complete: complete)
        }
    }
    
    func setupTransition() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "user_detail") as? UserDetailController else {
            return
        }
        vc.user = popup?.user
        vc.fullUser = popup?.fullUser
        self.animateVC = vc
        
        vc.view.frame = popup!.container!.bounds
        var srcAnim = AnimCornerRect(fromRect: .zero, toRect: .zero, fromCorner: Corners(), toCorner: Corners())
        srcAnim.fromRect = view.convert(view.bounds, to: view.window)
        if srcAnim.fromRect.minY == 0 {
            srcAnim.fromCorner = Corners()
        } else {
            srcAnim.fromCorner = Corners(tl: 10, tr: 10)
        }
        srcAnim.toCorner = Corners(tl: 10, tr: 10)
        
        var dstAnim = AnimCornerRect(fromRect: .zero, toRect: .zero, fromCorner: Corners(), toCorner: Corners())
        dstAnim.fromCorner = Corners(tl: 30, tr: 30, bl: 30, br: 30)
        dstAnim.toCorner = Corners(tl: 10, tr: 10)
        dstAnim.fromRect = popup!.container!.frame
        dstAnim.toRect = view.window!.bounds.inset(top: 40)
        
        self.srcAnimate = srcAnim
        self.dstAnimate = dstAnim
        fullDistProgress = abs(dstAnim.fromRect.minY - dstAnim.toRect.minY)
    }
    
    func finishTransition(complete: Bool) {
        let from = lastProgress
        let to: CGFloat = complete ? 1 : 0
        let duration = abs(Double(to-from)) * 0.4
        
        _ = DisplayLinkAnimator.animate(duration: duration) { (progress) in
            
            let prog = (to - from) * progress + from
            self.updateTransition(progress: prog)
            
            if progress == 1 {
                DispatchQueue.main.async {
                    let sup = self.view.superview?.superview
                    if complete {
                        self.present(self.animateVC!, animated: false, completion: {
                            self.popup?.container?.removeFromSuperview()
                            self.popup?.closeButton?.removeFromSuperview()
                            
                        })
                        
                    }
                    self.animateVC = nil
                    sup?.transform = .identity
                    
                    UIView.transition(with: self.view.window!,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: nil,
                                      completion: nil)
                }
            }
        }
    }
    
    func updateTransition(progress: CGFloat) {
        print("Progress: \(progress)")
        lastProgress = progress
        let fromAlpha: CGFloat = 0.3
        let toAlpha: CGFloat = 0.12
        let currAlpha = interpolate(a: fromAlpha, b: toAlpha, p: progress)
        popup?.closeButton?.backgroundColor = UIColor.black.withAlphaComponent(currAlpha)
//        let rrr = dstAnimate!.generateRect(progress: progress)
        popup?.container?.frame = dstAnimate!.generateRect(progress: progress)
        popup?.container?.layer.cornerRadius = 0
        let mask = CAShapeLayer()
        mask.frame = view.window!.bounds
        mask.path = dstAnimate!.generateBezier(progress: progress).cgPath
        popup?.container?.layer.mask = mask
        
        let imgRect = imgAnimate.generateRect(progress: progress)
        popup?.imgLeft.constant = imgRect.minX
        popup?.imgTop.constant = imgRect.minY
        popup?.imgWidth.constant = imgRect.width
        popup?.imgHeight.constant = imgRect.height
        let fontSize = interpolate(a: 17, b: nameLabel.font.pointSize, p: pow(progress, 2.5))
        popup?.nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        
        let fromScale: CGFloat = 1, toScale: CGFloat = 0.91
        let offset = progress * (-38)
        let scale = interpolate(a: fromScale, b: toScale, p: progress)
        view.superview?.superview?.transform = CGAffineTransform(translationX: 0, y: offset).scaledBy(x: scale, y: scale)
    }
    
    // --- Debug purpose only! ---
    // It's used for generate same user interaction
    func simulateSwipe() {
        guard let popup = popup else {
            return
        }
        
        touchView = TouchView()
        touchView!.config = Configuration()
        touchView!.beginTouch()
        touchView!.center = popup.container!.convert(CGPoint(x: 180, y: popup.container!.bounds.height * 0.4), to: view.window)
        view.window?.addSubview(touchView!)
//        return
        
        UIView.animate(withDuration: 1.0, animations: {})
        let fixPercent: CGFloat = 1.0
        let startCener = touchView!.center
        setupTransition() // аналог Timer
        let timing = Timing.easeInOut
        _ = DisplayLinkAnimator.animate(duration: 1.5, closure: { (progress) in
//            if progress < 0.9 {
                var progress = timing.getValue(x: progress)
                let offset = self.fullDistProgress * fixPercent * progress
                self.touchView?.center = CGPoint(x: startCener.x, y: startCener.y - offset)
                if progress > 0.26 {
                    if progress < 0.5 {
                        progress = (progress - 0.26) / (0.5 - 0.26)
                        progress *= 0.5
                    }
                    self.updateTransition(progress: progress * fixPercent)
                }
//            }
            
            if progress == 1 {
                let touch = self.touchView
                touch?.endTouch()
                delay(0.6) {
                    touch?.removeFromSuperview()
                    self.finishTransition(complete: true)
                }
//                self.touchView?.removeFromSuperview()
//                self.finishTransition(complete: true)
            }
        })
    }
}


extension UserDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.display(user: user)
        cell.onLongPress = { [weak self] in
            self?.showPopup(user: user)
            print("••")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "following"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserDetailController,
           let idx = table.indexPathForSelectedRow?.row {
            vc.user = users[idx]
        }
    }
}

