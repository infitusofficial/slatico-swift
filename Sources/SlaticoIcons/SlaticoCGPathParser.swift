import CoreGraphics
import Foundation

/// Thread-safe W3C SVG 1.1 Path Data (`d` attribute) to Core Graphics `CGPath` parser.
public enum SlaticoCGPathParser {
    private static let lock = NSLock()
    private static var cache: [String: CGPath] = [:]

    /// Parses an SVG path data string (`d`) into an immutable Core Graphics `CGPath` in 24×24 coordinates.
    public static func cgPath(from pathData: String) -> CGPath {
        lock.lock()
        if let cached = cache[pathData] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        let parsed = parse(pathData: pathData)

        lock.lock()
        cache[pathData] = parsed
        lock.unlock()

        return parsed
    }

    private static func parse(pathData: String) -> CGPath {
        let path = CGMutablePath()
        var scanner = SVGPathScanner(pathData)

        var currentPoint = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastControlPoint: CGPoint?
        var lastCommand: Character = " "

        while let cmd = scanner.nextCommand(fallbackCommand: lastCommand) {
            let isRelative = cmd.isLowercase
            let upperCmd = Character(cmd.uppercased())

            switch upperCmd {
            case "M":
                guard let x = scanner.nextNumber(), let y = scanner.nextNumber() else { break }
                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                path.move(to: target)
                currentPoint = target
                subpathStart = target
                lastControlPoint = nil
                // Subsequent coordinate pairs after M/m are treated as implicit L/l
                lastCommand = isRelative ? "l" : "L"

            case "L":
                guard let x = scanner.nextNumber(), let y = scanner.nextNumber() else { break }
                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                path.addLine(to: target)
                currentPoint = target
                lastControlPoint = nil
                lastCommand = cmd

            case "H":
                guard let x = scanner.nextNumber() else { break }
                let targetX = isRelative ? currentPoint.x + x : x
                let target = CGPoint(x: targetX, y: currentPoint.y)
                path.addLine(to: target)
                currentPoint = target
                lastControlPoint = nil
                lastCommand = cmd

            case "V":
                guard let y = scanner.nextNumber() else { break }
                let targetY = isRelative ? currentPoint.y + y : y
                let target = CGPoint(x: currentPoint.x, y: targetY)
                path.addLine(to: target)
                currentPoint = target
                lastControlPoint = nil
                lastCommand = cmd

            case "C":
                guard
                    let x1 = scanner.nextNumber(),
                    let y1 = scanner.nextNumber(),
                    let x2 = scanner.nextNumber(),
                    let y2 = scanner.nextNumber(),
                    let x = scanner.nextNumber(),
                    let y = scanner.nextNumber()
                else { break }

                let cp1 = isRelative
                    ? CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1)
                    : CGPoint(x: x1, y: y1)
                let cp2 = isRelative
                    ? CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2)
                    : CGPoint(x: x2, y: y2)
                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)

                path.addCurve(to: target, control1: cp1, control2: cp2)
                lastControlPoint = cp2
                currentPoint = target
                lastCommand = cmd

            case "S":
                guard
                    let x2 = scanner.nextNumber(),
                    let y2 = scanner.nextNumber(),
                    let x = scanner.nextNumber(),
                    let y = scanner.nextNumber()
                else { break }

                let prevUpper = Character(lastCommand.uppercased())
                let cp1: CGPoint
                if (prevUpper == "C" || prevUpper == "S"), let lastCP = lastControlPoint {
                    cp1 = CGPoint(
                        x: 2 * currentPoint.x - lastCP.x,
                        y: 2 * currentPoint.y - lastCP.y
                    )
                } else {
                    cp1 = currentPoint
                }

                let cp2 = isRelative
                    ? CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2)
                    : CGPoint(x: x2, y: y2)
                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)

                path.addCurve(to: target, control1: cp1, control2: cp2)
                lastControlPoint = cp2
                currentPoint = target
                lastCommand = cmd

            case "Q":
                guard
                    let x1 = scanner.nextNumber(),
                    let y1 = scanner.nextNumber(),
                    let x = scanner.nextNumber(),
                    let y = scanner.nextNumber()
                else { break }

                let cp = isRelative
                    ? CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1)
                    : CGPoint(x: x1, y: y1)
                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)

                path.addQuadCurve(to: target, control: cp)
                lastControlPoint = cp
                currentPoint = target
                lastCommand = cmd

            case "T":
                guard let x = scanner.nextNumber(), let y = scanner.nextNumber() else { break }

                let prevUpper = Character(lastCommand.uppercased())
                let cp: CGPoint
                if (prevUpper == "Q" || prevUpper == "T"), let lastCP = lastControlPoint {
                    cp = CGPoint(
                        x: 2 * currentPoint.x - lastCP.x,
                        y: 2 * currentPoint.y - lastCP.y
                    )
                } else {
                    cp = currentPoint
                }

                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)

                path.addQuadCurve(to: target, control: cp)
                lastControlPoint = cp
                currentPoint = target
                lastCommand = cmd

            case "A":
                guard
                    let rx = scanner.nextNumber(),
                    let ry = scanner.nextNumber(),
                    let xAxisRotation = scanner.nextNumber(),
                    let largeArcFlag = scanner.nextFlag(),
                    let sweepFlag = scanner.nextFlag(),
                    let x = scanner.nextNumber(),
                    let y = scanner.nextNumber()
                else { break }

                let target = isRelative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)

                addSVGArc(
                    to: path,
                    from: currentPoint,
                    to: target,
                    rx: abs(rx),
                    ry: abs(ry),
                    xAxisRotationDegrees: xAxisRotation,
                    largeArcFlag: largeArcFlag,
                    sweepFlag: sweepFlag
                )
                currentPoint = target
                lastControlPoint = nil
                lastCommand = cmd

            case "Z":
                path.closeSubpath()
                currentPoint = subpathStart
                lastControlPoint = nil
                lastCommand = cmd

            default:
                break
            }
        }

        return path.copy() ?? path
    }

    /// Converts an SVG elliptical arc (`A`/`a`) into cubic Bézier curves per W3C SVG 1.1 Appendix F.6.5 & F.6.6.
    private static func addSVGArc(
        to path: CGMutablePath,
        from p1: CGPoint,
        to p2: CGPoint,
        rx inputRx: CGFloat,
        ry inputRy: CGFloat,
        xAxisRotationDegrees: CGFloat,
        largeArcFlag: Bool,
        sweepFlag: Bool
    ) {
        if p1 == p2 {
            return
        }
        if inputRx == 0 || inputRy == 0 {
            path.addLine(to: p2)
            return
        }

        var rx = inputRx
        var ry = inputRy
        let phi = xAxisRotationDegrees * .pi / 180.0
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        let dx2 = (p1.x - p2.x) / 2.0
        let dy2 = (p1.y - p2.y) / 2.0
        let x1p = cosPhi * dx2 + sinPhi * dy2
        let y1p = -sinPhi * dx2 + cosPhi * dy2

        var rxSq = rx * rx
        var rySq = ry * ry
        let x1pSq = x1p * x1p
        let y1pSq = y1p * y1p

        // Ensure radii are large enough (F.6.6.3)
        let lambda = (x1pSq / rxSq) + (y1pSq / rySq)
        if lambda > 1.0 {
            let scale = sqrt(lambda)
            rx *= scale
            ry *= scale
            rxSq = rx * rx
            rySq = ry * ry
        }

        let sign: CGFloat = (largeArcFlag == sweepFlag) ? -1.0 : 1.0
        let numerator = max(0.0, rxSq * rySq - rxSq * y1pSq - rySq * x1pSq)
        let denominator = rxSq * y1pSq + rySq * x1pSq
        let factor = denominator > 0 ? sign * sqrt(numerator / denominator) : 0.0

        let cxp = factor * ((rx * y1p) / ry)
        let cyp = factor * (-(ry * x1p) / rx)

        let cx = cosPhi * cxp - sinPhi * cyp + (p1.x + p2.x) / 2.0
        let cy = sinPhi * cxp + cosPhi * cyp + (p1.y + p2.y) / 2.0

        let ux = (x1p - cxp) / rx
        let uy = (y1p - cyp) / ry
        let vx = (-x1p - cxp) / rx
        let vy = (-y1p - cyp) / ry

        let theta1 = vectorAngle(ux: 1.0, uy: 0.0, vx: ux, vy: uy)
        var deltaTheta = vectorAngle(ux: ux, uy: uy, vx: vx, vy: vy)

        if !sweepFlag && deltaTheta > 0 {
            deltaTheta -= 2.0 * .pi
        } else if sweepFlag && deltaTheta < 0 {
            deltaTheta += 2.0 * .pi
        }

        let segments = max(1, Int(ceil(abs(deltaTheta) / (.pi / 2.0))))
        let delta = deltaTheta / CGFloat(segments)
        let alpha = (4.0 / 3.0) * tan(delta / 4.0)

        var currentAngle = theta1
        for _ in 0..<segments {
            let nextAngle = currentAngle + delta
            let cos1 = cos(currentAngle)
            let sin1 = sin(currentAngle)
            let cos2 = cos(nextAngle)
            let sin2 = sin(nextAngle)

            let q1x = cos1 - alpha * sin1
            let q1y = sin1 + alpha * cos1
            let q2x = cos2 + alpha * sin2
            let q2y = sin2 - alpha * cos2

            let cp1 = CGPoint(
                x: cosPhi * rx * q1x - sinPhi * ry * q1y + cx,
                y: sinPhi * rx * q1x + cosPhi * ry * q1y + cy
            )
            let cp2 = CGPoint(
                x: cosPhi * rx * q2x - sinPhi * ry * q2y + cx,
                y: sinPhi * rx * q2x + cosPhi * ry * q2y + cy
            )
            let endPoint = CGPoint(
                x: cosPhi * rx * cos2 - sinPhi * ry * sin2 + cx,
                y: sinPhi * rx * cos2 + cosPhi * ry * sin2 + cy
            )

            path.addCurve(to: endPoint, control1: cp1, control2: cp2)
            currentAngle = nextAngle
        }
    }

    private static func vectorAngle(ux: CGFloat, uy: CGFloat, vx: CGFloat, vy: CGFloat) -> CGFloat {
        let dot = ux * vx + uy * vy
        let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
        guard len > 0 else { return 0 }
        let clamped = max(-1.0, min(1.0, dot / len))
        let angle = acos(clamped)
        return (ux * vy - uy * vx) < 0 ? -angle : angle
    }
}

private struct SVGPathScanner {
    private let chars: [Character]
    private var index: Int = 0

    init(_ string: String) {
        self.chars = Array(string)
    }

    private mutating func skipSeparators() {
        while index < chars.count {
            let c = chars[index]
            if c == " " || c == "\t" || c == "\n" || c == "\r" || c == "," {
                index += 1
            } else {
                break
            }
        }
    }

    mutating func nextCommand(fallbackCommand: Character) -> Character? {
        skipSeparators()
        guard index < chars.count else { return nil }
        let c = chars[index]
        if c.isLetter && c != "e" && c != "E" {
            index += 1
            return c
        }
        return fallbackCommand != " " ? fallbackCommand : nil
    }

    mutating func nextFlag() -> Bool? {
        skipSeparators()
        guard index < chars.count else { return nil }
        let c = chars[index]
        if c == "0" {
            index += 1
            return false
        }
        if c == "1" {
            index += 1
            return true
        }
        return nil
    }

    mutating func nextNumber() -> CGFloat? {
        skipSeparators()
        guard index < chars.count else { return nil }

        let start = index
        var hasDecimal = false
        var hasExponent = false

        if chars[index] == "+" || chars[index] == "-" {
            index += 1
        }

        while index < chars.count {
            let c = chars[index]
            if c >= "0" && c <= "9" {
                index += 1
            } else if c == "." && !hasDecimal && !hasExponent {
                hasDecimal = true
                index += 1
            } else if (c == "e" || c == "E") && !hasExponent {
                hasExponent = true
                index += 1
                if index < chars.count && (chars[index] == "+" || chars[index] == "-") {
                    index += 1
                }
            } else {
                break
            }
        }

        guard index > start else { return nil }
        let token = String(chars[start..<index])
        guard let value = Double(token) else { return nil }
        return CGFloat(value)
    }
}
