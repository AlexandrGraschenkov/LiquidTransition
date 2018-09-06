//
//  UIImageRetriever.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 08.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


protocol UIImageRetriever: Codable {
    func getImage(completion: @escaping (UIImage)->()) -> Cancelable
}

struct FileImage: Codable {
    
    fileprivate var relativePath: String?
    fileprivate var absolutePath: String?
    fileprivate var cache: UIImage?
    
    enum CodingKeys: String, CodingKey
    {
        case relativePath
        case absolutePath
    }
    
    var path: String {
        get {
            if let relPath = relativePath {
                return FileImage.appDir.appendingPathComponent(relPath)
            } else {
                return absolutePath ?? ""
            }
        }
        set {
            if newValue.hasPrefix(FileImage.appDir as String) {
                let fromIdx = newValue.index(newValue.startIndex, offsetBy: FileImage.appDir.length)
                relativePath = String(newValue[fromIdx...])
                absolutePath = nil
            } else {
                relativePath = nil
                absolutePath = newValue
            }
        }
    }
    
    
    static fileprivate let appDir: NSString = {
        NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)[0] as NSString
    }()
}

extension FileImage: UIImageRetriever {
    func getImage(completion: @escaping (UIImage) -> ()) -> Cancelable {
        if let img = cache {
            completion(img)
            return {}
        }
        let filePath = path
        
        DispatchQueue.global(qos: .background).async {
            let img = UIImage(contentsOfFile: filePath)?.forceDecode() ?? UIImage()
            
            DispatchQueue.main.async {
                completion(img)
            }
        }
        return {}
    }
}
