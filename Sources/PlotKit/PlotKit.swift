import Foundation
import CoreGraphics
import CoreText

public func plot(x: [CGFloat], y: [CGFloat], size: CGSize,
                 options: [PKPlotOption : Any] = [:]) -> CGImage? {
    
    var bitmapContext = createCGContext(size: size)
    
    pkplot(x: x, y: y, size: size, bitmapContext: &bitmapContext)
    
    return bitmapContext.makeImage()
    
}

func pkplot(x: [CGFloat], y: [CGFloat], size: CGSize,
          options: [PKPlotOption : Any] = [:], bitmapContext: inout CGContext) {
    
    // PREFERENCES - colors, fonts, ...
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let annotationColor = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 1])!
    let plotColor = CGColor(colorSpace: colorSpace, components: [0.8, 0.4, 0.2, 1])!
    let fontAttributes = [
        kCTFontFamilyNameAttribute : "Arial",
//        kCTFontStyleNameAttribute : "Bold",
        kCTFontSizeAttribute : 18.0
    ] as NSDictionary
    
    let descriptor = CTFontDescriptorCreateWithAttributes(fontAttributes)
    let font = CTFontCreateWithFontDescriptor(descriptor, 0.0, nil)
    let attributes = [kCTFontAttributeName : font] as CFDictionary
    
    // ANNOTATIONS - labels, legends, ticks...
    
    let (xticks, yticks) = ticks(dataX: x, y: y,
                                 xlimit: options[.xlimit] as? (CGFloat, CGFloat),
                                 ylimit: options[.ylimit] as? (CGFloat, CGFloat))
    
    let tallestXtickLabel: CGFloat
    let widestYtickLabel: CGFloat
    tallestXtickLabel = xticks.map({
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        return labelSize.height
    }).max() ?? 0
    widestYtickLabel = yticks.map({
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        return labelSize.width
    }).max() ?? 0
    
    // TRANSFORMATION OF COORDINATES
    
    let transform = fitTransform(dataX: x, y: y,
                                 size: size,
                                 padding: CGVector(dx: widestYtickLabel, dy: tallestXtickLabel),
                                 xlimit: options[.xlimit] as? (CGFloat, CGFloat),
                                 ylimit: options[.ylimit] as? (CGFloat, CGFloat))
    
    // AXES
    
    bitmapContext.setFillColor(annotationColor)
    bitmapContext.setStrokeColor(annotationColor)
    
    bitmapContext.beginPath()
    
    let origin = CGPoint.zero.applying(transform)
    
    bitmapContext.move(to: CGPoint(x: 0, y: origin.y))  // x axis
    bitmapContext.addLine(to: CGPoint(x: size.width, y: origin.y))
    bitmapContext.move(to: CGPoint(x: origin.x, y: 0))
    bitmapContext.addLine(to: CGPoint(x: origin.x, y: size.height))  // y axis
    bitmapContext.strokePath()
    
    xticks.dropFirst().forEach {
        // tick
        bitmapContext.move(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x, y: origin.y))
        bitmapContext.addLine(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x, y: origin.y+6))
        bitmapContext.strokePath()
        // tick label
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        bitmapContext.textPosition = CGPoint(
            x: CGPoint(x: $0, y: 0).applying(transform).x - labelSize.width/2,
            y: origin.y - labelSize.height-4
        )
        CTLineDraw(textLine, bitmapContext)
        
    }
    yticks.dropFirst().forEach {
        // tick
        bitmapContext.move(to: CGPoint(x: origin.x, y: CGPoint(x: 0, y: $0).applying(transform).y))
        bitmapContext.addLine(to: CGPoint(x: origin.x+6, y: CGPoint(x: 0, y: $0).applying(transform).y))
        bitmapContext.strokePath()
        // tick label
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        bitmapContext.textPosition = CGPoint(
            x: origin.x - labelSize.width-4,
            y: CGPoint(x: 0, y: $0).applying(transform).y - labelSize.height/2
        )
        CTLineDraw(textLine, bitmapContext)
        
    }
    
    // DRAW POINTS
    
    let points = x.indices.map { CGPoint(x: x[$0], y: y[$0]) }
    
    bitmapContext.setFillColor(plotColor)
    bitmapContext.setStrokeColor(plotColor)
    bitmapContext.setLineWidth(2) // default is 1
    
    if let connected = options[.connected] as? Bool {
        if connected {
            points.dropLast().indices.forEach {
                (i) in
                bitmapContext.beginPath()
                bitmapContext.move(to: points[i].applying(transform))
                bitmapContext.addLine(to: points[i+1].applying(transform))
                bitmapContext.strokePath()
            }
        }
    }
    points.forEach {
        (p) in
        bitmapContext.beginPath()
        bitmapContext.addArc(center: p.applying(transform), radius: 3, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        bitmapContext.closePath()
        bitmapContext.drawPath(using: .eoFillStroke)
    }
    
}
