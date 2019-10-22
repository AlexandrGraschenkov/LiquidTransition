//
//  GithubAPIService.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit

class GithubAPIService: NSObject {
    typealias Completion<T> = (_ result: T?, _ error: Error?)->()
    
    
    func getFollowers(login: String, completion: @escaping Completion<[GUser]>) -> Cancelable {
        let url = URL(string: "https://api.github.com/users/\(login)/following")!
        
        let task = session.dataTask(with: url) { (data, _, err) in
            let result: ParseRes<[GUser]> = self.jsonDecode(data: data, err: err)
            completion(result.obj, result.err)
        }
        task.resume()
        
        return { task.cancel() }
    }
    
    
    func getFullUser(login: String, completion: @escaping Completion<[GUserFull]>) -> Cancelable {
        let url = URL(string: "https://api.github.com/users/\(login)")!
        
        let task = session.dataTask(with: url) { (data, _, err) in
            let result: ParseRes<[GUserFull]> = self.jsonDecode(data: data, err: err)
            completion(result.obj, result.err)
        }
        task.resume()
        
        return { task.cancel() }
    }
    
    func getAvatar(id: Int64, size: Int?, completion: @escaping Completion<UIImage?>) -> Cancelable {
        var urlPath = "https://avatars3.githubusercontent.com/u/\(id)?v=4"
        if let size = size {
            urlPath += "&s=\(size)"
        }
        let url = URL(string: urlPath)!
        let task = session.dataTask(with: url) { (data, _, err) in
            var img: UIImage? = nil
            if let data = data {
                img = UIImage(data: data)
            }
            completion(img, err)
        }
        task.resume()
        
        return { task.cancel() }
    }
    
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
