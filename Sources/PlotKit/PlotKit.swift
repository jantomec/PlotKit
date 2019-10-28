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
    
    let points = x.indices.map { CGPoint(x: x[$0], y: y[$0]) }
    
    let sx: CGFloat
    let sy: CGFloat
    let tx: CGFloat
    let ty: CGFloat
    if let xmin = x.min(), let xmax = x.max() {
        sx = 0.9*size.width/(xmax - xmin)
        tx = 0.05*size.width/(xmax - xmin)
    } else {
        sx = 0.9
        tx = 0.05
    }
    if let ymin = y.min(), let ymax = y.max() {
        sy = 0.9*size.height/(ymax - ymin)
        ty = 0.05*size.height/(ymax - ymin)
    } else {
        sy = 0.9
        ty = 0.05
    }
    
    //bitmapContext?.scaleBy(x: sx, y: sy)
    //bitmapContext?.translateBy(x: tx, y: ty)
    let transform = CGAffineTransform(translationX: -tx, y: -ty).concatenating(
        CGAffineTransform(scaleX: sx, y: sy)
    )
    
    let color = CGColor(colorSpace: colorSpace, components: [0.8, 0.4, 0.2, 1])!
    
    bitmapContext?.setFillColor(color)
    bitmapContext?.setStrokeColor(color)
    
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
