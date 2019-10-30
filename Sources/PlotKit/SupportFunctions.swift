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

func ticks(dataX x: [CGFloat], y: [CGFloat],
           xlimit: (CGFloat, CGFloat)?,
           ylimit: (CGFloat, CGFloat)?) -> ([CGFloat], [CGFloat]) {
    // in future try to normalize numbers first and then choose appropriate ticks
    
    let xmax: CGFloat = xlimit?.1 ?? x.max() ?? 1
    let xmin: CGFloat = xlimit?.0 ?? x.min() ?? 0
    let ymax: CGFloat = ylimit?.1 ?? y.max() ?? 1
    let ymin: CGFloat = ylimit?.0 ?? y.min() ?? 0
    let x0 = xmin
    let Dx = xmax - xmin
    let y0 = ymin
    let Dy = ymax - ymin
    
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

    
    return (xaxis: xticks, yaxis: yticks)
}
