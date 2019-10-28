//
//  SupportFunctions.swift
//  
//
//  Created by Jan Tomec on 28/10/2019.
//

import CoreGraphics
import NumKit

func fitTransform(dataX x: [CGFloat], y: [CGFloat], size: CGSize, padding: CGVector) -> CGAffineTransform {
    let sx: CGFloat
    let sy: CGFloat
    let tx: CGFloat
    let ty: CGFloat
    if let xmin = x.min(), let xmax = x.max() {
        sx = 0.9*size.width/(xmax - xmin)
        tx = 0.05*size.width + padding.dx
    } else {
        sx = 0.9
        tx = 0.05 + padding.dx
    }
    if let ymin = y.min(), let ymax = y.max() {
        sy = 0.9*size.height/(ymax - ymin)
        ty = 0.05*size.height + padding.dy
    } else {
        sy = 0.9
        ty = 0.05 + padding.dy
    }
    
    return CGAffineTransform(scaleX: sx, y: sy).concatenating(
        CGAffineTransform(translationX: tx, y: ty)
    )
}

func ticks(dataX x: [CGFloat], y: [CGFloat]) -> ([CGFloat], [CGFloat]) {
    // in future try to normalize numbers first and then choose appropriate ticks
    let x0: CGFloat, y0: CGFloat
    let Dx: CGFloat, Dy: CGFloat
    if let xmax = x.max(), let xmin = x.min() {
        Dx = xmax - xmin
        x0 = xmin
    } else {
        Dx = 1
        x0 = 0
    }
    if let ymax = y.max(), let ymin = y.min()  {
        Dy = ymax - ymin
        y0 = ymin
    } else {
        Dy = 1
        y0 = 0
    }
    
    let nticksCandidates = [5, 6, 7, 8]
    
    let dx = nticksCandidates.map {
        (candidate) in
        (Dx / CGFloat(candidate))
    }
    let dy = nticksCandidates.map {
        (candidate) in
        (Dy / CGFloat(candidate))
    }
    
    let xticksCF = dx.indices.map {
        (i) in
        arange(from: x0, to: dx[i]*CGFloat(nticksCandidates[i]),
               step: dx[i], includeLast: true).map({
                CGFloat($0.description.count)
            }).mean
    }
    let yticksCF = dy.indices.map {
        (i) in
        arange(from: y0, to: dy[i]*CGFloat(nticksCandidates[i]),
               step: dy[i], includeLast: true).map({
                CGFloat($0.description.count)
            }).mean
    }
    
    let nxi = xticksCF.argmin() ?? 0
    let nyi = yticksCF.argmin() ?? 0
    
    let xticks = arange(from: x0, to: dx[nxi]*CGFloat(nticksCandidates[nxi]),
                        step: dx[nxi], includeLast: true)
    let yticks = arange(from: y0, to: dy[nyi]*CGFloat(nticksCandidates[nyi]),
                        step: dy[nyi], includeLast: true)

    
    return (xticks, yticks)
}
