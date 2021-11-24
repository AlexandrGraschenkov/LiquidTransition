//
//  GithubAPIService.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit

class GithubAPIService: NSObject {
    static var shared = GithubAPIService()
    typealias Completion<T> = (_ result: T?, _ error: Error?)->()
    
    fileprivate override init() {
        super.init()
    }
    
    
    @discardableResult
    func get<T: Decodable>(url: URL, completion: @escaping Completion<T>) -> Cancelable {
        let task = session.dataTask(with: url) { (data, _, err) in
            let result: ParseRes<T> = self.jsonDecode(data: data, err: err)
            performInMain {
                completion(result.obj, result.err)
            }
        }
        task.resume()
        
        return { task.cancel() }
    }
    
    @discardableResult
    func getUser(login: String, completion: @escaping Completion<GUserFull>) -> Cancelable {
        let url = URL(string: "https://api.github.com/users/\(login)")!
        
        return get(url: url, completion: completion)
    }
    
    @discardableResult
    func getFollowing(login: String, completion: @escaping Completion<[GUser]>) -> Cancelable {
        let url = URL(string: "https://api.github.com/users/\(login)/following")!
        
        return get(url: url, completion: completion)
    }
    
    @discardableResult
    func getFullUser(login: String, completion: @escaping Completion<[GUserFull]>) -> Cancelable {
        let url = URL(string: "https://api.github.com/users/\(login)")!
        
        return get(url: url, completion: completion)
    }
    
    func avatarUrl(id: Int64, size: Int?) -> URL {
        var urlPath = "https://avatars3.githubusercontent.com/u/\(id)?v=4"
        if var size = size {
            size = Int(CGFloat(size) * UIScreen.main.scale)
            urlPath += "&s=\(size)"
        }
        let url = URL(string: urlPath)!
        return url
    }
//    
//    func getAvatar(id: Int64, size: Int?, completion: @escaping Completion<UIImage?>) -> Cancelable {
//        var urlPath = "https://avatars3.githubusercontent.com/u/\(id)?v=4"
//        if let size = size {
//            urlPath += "&s=\(size)"
//        }
//        let url = URL(string: urlPath)!
//        let task = session.dataTask(with: url) { (data, _, err) in
//            var img: UIImage? = nil
//            if let data = data {
//                img = UIImage(data: data)
//            }
//            performInMain {
//                completion(img, err)
//            }
//        }
//        task.resume()
//        
//        return { task.cancel() }
//    }
    
    // MARK: - private
    private let session: URLSession = URLSession.shared
    private typealias ParseRes<T> = (obj: T?, err: Error?)
    
    private func jsonDecode<T: Decodable>(data: Data?, err: Error?) -> ParseRes<T> {
        var err = err
        var result: T? = nil
        do {
            if let data = data {
                result = try JSONDecoder().decode(T.self, from: data)
            }
        } catch {
            err = error
        }
        return (result, err)
    }
}
