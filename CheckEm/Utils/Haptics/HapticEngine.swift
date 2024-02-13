//
//  HapticEngine.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 13/02/2024.
//

import CoreHaptics

final class HapticEngine {
    
    enum Haptic: String {
        
        case refresh
        
        var intensity: CHHapticEventParameter {
            switch self {
            case .refresh: return CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            }
        }
        
        var sharpness: CHHapticEventParameter {
            switch self {
            case .refresh: return CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
            }
        }
        
        var duration: TimeInterval {
            switch self {
            case .refresh: return 0.3
            }
        }
        
        var events: [CHHapticEvent] {
            [CHHapticEvent(eventType: .hapticContinuous,
                           parameters: [intensity, sharpness],
                           relativeTime: 0,
                           duration: duration)]
        }
    }
    
    static let shared = HapticEngine()
    
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            
        } catch {
            print("There was an error creating the engine: \(error)")
        }
    }
    
    func play(haptic: Haptic) {
        DispatchQueue.main.async { [weak self] in
            self?._play(haptic: haptic)
        }
    }
    
    private func _play(haptic: Haptic) {
        
        guard let engine = engine else { return }
        
        do {
            let pattern = try CHHapticPattern(events: haptic.events, parameters: [])
            try engine.start()
            player = try engine.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            engine.notifyWhenPlayersFinished { _ in
                .stopEngine
            }
            
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
}
