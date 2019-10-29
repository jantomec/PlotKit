# PlotKit

Swift package for ploting. Works on MacOS and on iOS. Main function plot creates a CGImage that can be used then as the data source for UIImage.

Demo:

```swift
let x: [CGFloat] = [1, 2, 3, 4, 5, 6]
let y = x.map { pow($0, 2) }

let p = plot(x: x, y: y, size: CGSize(width: 100, height: 100), connected: true)

UIImage(cgImage: p!)
```
