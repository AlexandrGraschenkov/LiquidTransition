//
//  UIImage+Ex.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 06.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

extension UIImage {
    
    func preloadedImage() -> UIImage {
        
        guard let cgImage = cgImage else {
            return self
        }
        
        // make a bitmap context of a suitable size to draw to, forcing decode
        let width = cgImage.width
        let height = cgImage.height
        
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let imageContext =  CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colourSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        // draw the image to the context, release it
        imageContext?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height), byTiling: false)
        
        // now get an image ref from the context
        if let outputImage = imageContext?.makeImage() {
            return UIImage(cgImage: outputImage, scale: scale, orientation: imageOrientation)
        }
        
        return self
    }
    
}
