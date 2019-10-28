//
//  SupportFunctions.swift
//  
//
//  Created by Jan Tomec on 28/10/2019.
//

import CoreGraphics

func fitTransform(dataX x: [CGFloat], y: [CGFloat]) -> CGAffineTransform {
    let sx: CGFloat
    let sy: CGFloat
    let tx: CGFloat
    let ty: CGFloat
    if let xmin = x.min(), let xmax = x.max() {
        sx = 0.9*size.width/(xmax - xmin)
        tx = 0.05*size.width
    } else {
        sx = 0.9
        tx = 0.05
    }
    if let ymin = y.min(), let ymax = y.max() {
        sy = 0.9*size.height/(ymax - ymin)
        ty = 0.05*size.height
    } else {
        sy = 0.9
        ty = 0.05
    }
    
    return CGAffineTransform(scaleX: sx, y: sy).concatenating(
        CGAffineTransform(translationX: tx, y: ty)
    )
}
