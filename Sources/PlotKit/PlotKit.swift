import CoreGraphics

public func plot(x: [CGFloat], y: [CGFloat], size: CGSize) -> CGImage? {
    
    let bitsPerComponent = 8
    let bytesPerRow = 0 // 0 means automatic calculation if data == nil
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapContext = CGContext(data: nil,
                                  width: Int(size.width),
                                  height: Int(size.height),
                                  bitsPerComponent: Int(bitsPerComponent),
                                  bytesPerRow: Int(bytesPerRow),
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    // TRANSFORMATION OF COORDINATES
    
    let transform = fitTransform(dataX: x, y: y, size: size)
    
    // COLORS
    
    let annotationColor = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 1])!
    let plotColor = CGColor(colorSpace: colorSpace, components: [0.8, 0.4, 0.2, 1])!
    
    // AXES
    
    bitmapContext?.setFillColor(annotationColor)
    bitmapContext?.setStrokeColor(annotationColor)
    
    if let ctx = bitmapContext {
        ctx.beginPath()
        let origin = CGPoint.zero.applying(transform)
        ctx.move(to: CGPoint(x: 0, y: origin.y))
        ctx.addLine(to: CGPoint(x: size.width, y: origin.y))
        ctx.move(to: CGPoint(x: origin.x, y: 0))
        ctx.addLine(to: CGPoint(x: origin.x, y: size.height))
        ctx.strokePath()
    }
    
    // DRAW POINTS
    
    let points = x.indices.map { CGPoint(x: x[$0], y: y[$0]) }
    
    bitmapContext?.setFillColor(plotColor)
    bitmapContext?.setStrokeColor(plotColor)
    
    if let ctx = bitmapContext {
        points.forEach {
            (p) in
            ctx.beginPath()
            ctx.addArc(center: p.applying(transform), radius: 2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            ctx.closePath()
            ctx.drawPath(using: .eoFillStroke)
        }
    }
    
    return bitmapContext?.makeImage()
}
