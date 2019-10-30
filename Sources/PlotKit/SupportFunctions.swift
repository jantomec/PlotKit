//
//  SupportFunctions.swift
//  
//
//  Created by Jan Tomec on 28/10/2019.
//

import CoreGraphics
import NumKit

func fitTransform(dataX x: [CGFloat], y: [CGFloat], size: CGSize, padding: CGVector,
                  xlimit: (CGFloat, CGFloat)?,
                  ylimit: (CGFloat, CGFloat)?) -> CGAffineTransform {
    
    let xmax: CGFloat = xlimit?.1 ?? x.max() ?? 1
    let xmin: CGFloat = xlimit?.0 ?? x.min() ?? 0
    let ymax: CGFloat = ylimit?.1 ?? y.max() ?? 1
    let ymin: CGFloat = ylimit?.0 ?? y.min() ?? 0
    
    let sx = (0.9*size.width - padding.dx)/(xmax - xmin)
    let tx = 0.01*size.width + padding.dx
    let sy = (0.9*size.height - padding.dy)/(ymax - ymin)
    let ty = 0.01*size.height + padding.dy
    
    return CGAffineTransform(scaleX: sx, y: sy).concatenating(
        CGAffineTransform(translationX: tx, y: ty)
    )
}

func createCGContext(size: CGSize) -> CGContext {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitsPerComponent = 8
    let bytesPerRow = 0 // 0 means automatic calculation if data == nil
    let bitmapContext = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: Int(bitsPerComponent),
        bytesPerRow: Int(bytesPerRow),
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    return bitmapContext
}
