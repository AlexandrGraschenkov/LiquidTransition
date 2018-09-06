//
//  UIImage+Decoder.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 14.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

extension UIImage {

    func forceDecode() -> UIImage {
        guard let imageRef = self.cgImage else {
            return UIImage()
        }
        
        // System only supports RGB, set explicitly and prevent context error
        // if the downloaded image is not the supported format
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        
        let bimapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            .union(.byteOrder32Little)
        guard let context = CGContext(data: nil,
                                      width: imageRef.width,
                                      height: imageRef.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: imageRef.width * 4,
                                      space: colorSpace,
                                      bitmapInfo: bimapInfo.rawValue) else {
            return UIImage()
        }
        
        let rect = CGRect(x: 0, y: 0, width: imageRef.width, height: imageRef.height)
        context.draw(imageRef, in: rect)
        
        guard let decompressedImageRef = context.makeImage() else { return UIImage() }
        let img = UIImage(cgImage: decompressedImageRef)
        return img
    }

}
