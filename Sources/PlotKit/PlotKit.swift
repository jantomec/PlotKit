import CoreText
import Foundation
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
    
    // PREFERENCES - colors, fonts, ...
    
    let annotationColor = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 1])!
    let plotColor = CGColor(colorSpace: colorSpace, components: [0.8, 0.4, 0.2, 1])!
    let annotationFont = CGFont(NSString(string: "Arial"))!
    let fontSize: CGFloat = 18
    
    // ANNOTATIONS - labels, legends, ticks...
    let (xticks, yticks) = ticks(dataX: x, y: y)
    
    let tallestXtickLabel: CGFloat
    let widestYtickLabel: CGFloat
    if let ctx = bitmapContext {
        tallestXtickLabel = xticks.map({
            let attrString = NSAttributedString(string: $0.description)
            let textLine = CTLineCreateWithAttributedString(attrString)
            return CTLineGetImageBounds(textLine, ctx).height
        }).max() ?? 0
        widestYtickLabel = yticks.map({
            let attrString = NSAttributedString(string: $0.description)
            let textLine = CTLineCreateWithAttributedString(attrString)
            return CTLineGetImageBounds(textLine, ctx).width
        }).max() ?? 0
    } else {
        tallestXtickLabel = 0
        widestYtickLabel = 0
    }
    
    // TRANSFORMATION OF COORDINATES
    
    let transform = fitTransform(dataX: x, y: y, size: size, padding: CGVector(dx: widestYtickLabel,
                                                                               dy: tallestXtickLabel))
    
    
    
    // AXES
    
    bitmapContext?.setFillColor(annotationColor)
    bitmapContext?.setStrokeColor(annotationColor)
//    bitmapContext?.setFont(annotationFont)
//    bitmapContext?.setFontSize(fontSize)
    // bitmapContext?.setLineWidth(1)  // default is 1
    
    if let ctx = bitmapContext {
        
        ctx.beginPath()
        
        let origin = CGPoint.zero.applying(transform)
        
        ctx.move(to: CGPoint(x: 0, y: origin.y))  // x axis
        ctx.addLine(to: CGPoint(x: size.width, y: origin.y))
        ctx.move(to: CGPoint(x: origin.x, y: 0))
        ctx.addLine(to: CGPoint(x: origin.x, y: size.height))  // y axis
        ctx.strokePath()
        
        xticks.dropFirst().forEach {
            // tick
            ctx.move(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x, y: origin.y))
            ctx.addLine(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x, y: origin.y+6))
            ctx.strokePath()
            // tick label
            let attrString = NSAttributedString(string: $0.description)
            let textLine = CTLineCreateWithAttributedString(attrString)
            let labelSize = CTLineGetImageBounds(textLine, ctx)
            ctx.textPosition = CGPoint(
                x: CGPoint(x: $0, y: 0).applying(transform).x - labelSize.width/2,
                y: origin.y - labelSize.height-4
            )
            CTLineDraw(textLine, ctx)
            
        }
        yticks.dropFirst().forEach {
            // tick
            ctx.move(to: CGPoint(x: origin.x, y: CGPoint(x: 0, y: $0).applying(transform).y))
            ctx.addLine(to: CGPoint(x: origin.x+6, y: CGPoint(x: 0, y: $0).applying(transform).y))
            ctx.strokePath()
            // tick label
            let attrString = NSAttributedString(string: $0.description)
            let textLine = CTLineCreateWithAttributedString(attrString)
            let labelSize = CTLineGetImageBounds(textLine, ctx)
            ctx.textPosition = CGPoint(
                x: origin.x - labelSize.width-4,
                y: CGPoint(x: 0, y: $0).applying(transform).y - labelSize.height/2
            )
            CTLineDraw(textLine, ctx)
        }
        
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
