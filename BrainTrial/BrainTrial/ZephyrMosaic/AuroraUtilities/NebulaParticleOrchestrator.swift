//
//  NebulaParticleOrchestrator.swift
//  BrainTrial
//
//  Particle effects and animations manager
//

import SpriteKit

class NebulaParticleOrchestrator {

    static let shared = NebulaParticleOrchestrator()

    private init() {}

    // MARK: - Victory Celebration Particles
    func synthesizeTriumphEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.5

        emitter.particlePositionRange = CGVector(dx: HorizonCanvasMeasure.canvasWidth, dy: 0)

        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.emissionAngle = .pi * 1.5
        emitter.emissionAngleRange = .pi * 0.3

        emitter.particleScale = 0.15
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.02

        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.3

        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 2

        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = .aureolaGoldShimmer
        emitter.particleColorSequence = createGoldenColorSequence()

        emitter.yAcceleration = -150

        // Use a simple circle shape
        let circleSize: CGFloat = 12
        UIGraphicsBeginImageContextWithOptions(CGSize(width: circleSize, height: circleSize), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        emitter.particleTexture = SKTexture(image: circleImage)

        return emitter
    }

    // MARK: - Sparkle Effect for Correct Placement
    func synthesizeAccuracySparkle(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position

        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = 30
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3

        emitter.particlePositionRange = CGVector(dx: 30, dy: 30)

        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        emitter.emissionAngleRange = .pi * 2

        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.15

        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.0

        emitter.particleColor = .celadonMintFresh
        emitter.particleColorBlendFactor = 1.0

        let starSize: CGFloat = 16
        UIGraphicsBeginImageContextWithOptions(CGSize(width: starSize, height: starSize), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        drawStar(in: ctx, size: starSize)
        let starImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        emitter.particleTexture = SKTexture(image: starImage)

        return emitter
    }

    // MARK: - Error Shake Particles
    func synthesizeErrorBurst(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position

        emitter.particleBirthRate = 60
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2

        emitter.particlePositionRange = CGVector(dx: 20, dy: 20)

        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 30
        emitter.emissionAngleRange = .pi * 2

        emitter.particleScale = 0.15
        emitter.particleScaleSpeed = -0.2

        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -1.2

        emitter.particleColor = .crimsonEmberGlow
        emitter.particleColorBlendFactor = 1.0

        let size: CGFloat = 10
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        emitter.particleTexture = SKTexture(image: image)

        return emitter
    }

    // MARK: - Ambient Background Particles
    func synthesizeAmbientMotes() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        emitter.particleBirthRate = 3
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 4

        emitter.particlePositionRange = CGVector(dx: HorizonCanvasMeasure.canvasWidth, dy: HorizonCanvasMeasure.canvasHeight)

        emitter.particleSpeed = 15
        emitter.particleSpeedRange = 10
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 4

        emitter.particleScale = 0.05
        emitter.particleScaleRange = 0.03
        emitter.particleScaleSpeed = 0.005

        emitter.particleAlpha = 0.3
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = 0

        emitter.particleColor = UIColor.mahjongAccentGold.withAlphaComponent(0.5)
        emitter.particleColorBlendFactor = 1.0

        let size: CGFloat = 20
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.drawRadialGradient(gradient, startCenter: CGPoint(x: size/2, y: size/2), startRadius: 0, endCenter: CGPoint(x: size/2, y: size/2), endRadius: size/2, options: [])
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        emitter.particleTexture = SKTexture(image: image)

        return emitter
    }

    // MARK: - Tile Selection Glow
    func synthesizeSelectionAura(diameter: CGFloat) -> SKShapeNode {
        let aura = SKShapeNode(circleOfRadius: diameter / 2)
        aura.fillColor = UIColor.aureolaGoldShimmer.withAlphaComponent(0.2)
        aura.strokeColor = .aureolaGoldShimmer
        aura.lineWidth = 2
        aura.glowWidth = 8

        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.15, duration: 0.6),
                SKAction.fadeAlpha(to: 0.5, duration: 0.6)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.6),
                SKAction.fadeAlpha(to: 1.0, duration: 0.6)
            ])
        ])
        aura.run(SKAction.repeatForever(pulse))

        return aura
    }

    // MARK: - Helper Methods
    private func createGoldenColorSequence() -> SKKeyframeSequence {
        let colors = [
            UIColor.aureolaGoldShimmer,
            UIColor.mahjongAccentGold,
            UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0),
            UIColor.aureolaGoldShimmer
        ]

        let times: [NSNumber] = [0, 0.33, 0.66, 1.0]
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }

    private func drawStar(in context: CGContext, size: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let outerRadius = size / 2
        let innerRadius = size / 4
        let points = 5

        var path = [CGPoint]()

        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            path.append(point)
        }

        context.move(to: path[0])
        for point in path.dropFirst() {
            context.addLine(to: point)
        }
        context.closePath()
        context.fillPath()
    }
}

// MARK: - Animation Presets
struct CelestialAnimationPresets {

    static func bounceIn() -> SKAction {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
        let scaleNormal = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        scaleNormal.timingMode = .easeInEaseOut
        return SKAction.sequence([SKAction.scale(to: 0.1, duration: 0), scaleUp, scaleNormal])
    }

    static func slideInFromBottom(height: CGFloat) -> SKAction {
        let initialPosition = SKAction.moveBy(x: 0, y: -height, duration: 0)
        let slideUp = SKAction.moveBy(x: 0, y: height, duration: 0.4)
        slideUp.timingMode = .easeOut
        return SKAction.sequence([initialPosition, slideUp])
    }

    static func slideInFromTop(height: CGFloat) -> SKAction {
        let initialPosition = SKAction.moveBy(x: 0, y: height, duration: 0)
        let slideDown = SKAction.moveBy(x: 0, y: -height, duration: 0.4)
        slideDown.timingMode = .easeOut
        return SKAction.sequence([initialPosition, slideDown])
    }

    static func fadeInWithScale() -> SKAction {
        let fade = SKAction.fadeIn(withDuration: 0.3)
        let scaleAction = SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 0),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        return SKAction.group([fade, scaleAction])
    }

    static func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.3) -> SKAction {
        let scaleUp = SKAction.scale(to: scale, duration: duration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration / 2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        return SKAction.sequence([scaleUp, scaleDown])
    }

    static func shake(intensity: CGFloat = 5, duration: TimeInterval = 0.3) -> SKAction {
        let shakes = 6
        let interval = duration / Double(shakes)
        var actions: [SKAction] = []

        for i in 0..<shakes {
            let offset = (i % 2 == 0 ? intensity : -intensity) * CGFloat(shakes - i) / CGFloat(shakes)
            actions.append(SKAction.moveBy(x: offset, y: 0, duration: interval))
        }

        return SKAction.sequence(actions)
    }

    static func countUp(from start: Int, to end: Int, duration: TimeInterval, label: SKLabelNode) -> SKAction {
        let steps = abs(end - start)
        guard steps > 0 else { return SKAction.run { label.text = "\(end)" } }

        let stepDuration = duration / Double(steps)
        var actions: [SKAction] = []

        for i in 0...steps {
            let value = start + (end > start ? i : -i)
            actions.append(SKAction.run { label.text = "\(value)" })
            if i < steps {
                actions.append(SKAction.wait(forDuration: stepDuration))
            }
        }

        return SKAction.sequence(actions)
    }
}
