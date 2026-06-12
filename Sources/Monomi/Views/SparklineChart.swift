import SwiftUI

/// メニューバーラベル用の小型履歴グラフ（0...1 の値列を塗りつぶし面で描画）
struct SparklineChart: View {
    let values: [Double]
    var color: Color = .accentColor

    var body: some View {
        Canvas { context, size in
            guard values.count > 1 else { return }
            let stepX = size.width / CGFloat(values.count - 1)

            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height))
            for (index, value) in values.enumerated() {
                let x = CGFloat(index) * stepX
                let y = size.height * (1 - CGFloat(min(max(value, 0), 1)))
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.closeSubpath()

            context.fill(path, with: .color(color.opacity(0.45)))

            var line = Path()
            for (index, value) in values.enumerated() {
                let x = CGFloat(index) * stepX
                let y = size.height * (1 - CGFloat(min(max(value, 0), 1)))
                if index == 0 {
                    line.move(to: CGPoint(x: x, y: y))
                } else {
                    line.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.stroke(line, with: .color(color), lineWidth: 1)
        }
    }
}
