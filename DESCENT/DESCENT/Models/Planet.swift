//
//  Planet.swift
//  DESCENT
//
//  Created by Colin Watson on 10/4/25.
//

import Foundation

/// Represents the different planets you can mine on
enum Planet: String, CaseIterable {
    case mars = "Mars"
    case luna = "Luna"
    case io = "Io"
    case europa = "Europa"
    case titan = "Titan"
    case venus = "Venus"
    case mercury = "Mercury"
    case enceladus = "Enceladus"

    /// Value multiplier for materials on this planet
    var multiplier: Double {
        switch self {
        case .mars: return 1.0
        case .luna: return 2.0
        case .io: return 5.0
        case .europa: return 8.0
        case .titan: return 15.0
        case .venus: return 25.0
        case .mercury: return 50.0
        case .enceladus: return 100.0
        }
    }

    /// Core depth in meters
    var coreDepth: Double {
        switch self {
        case .mars: return 500
        case .luna: return 600
        case .io: return 700
        case .europa: return 800
        case .titan: return 900
        case .venus: return 1000
        case .mercury: return 1100
        case .enceladus: return 1200
        }
    }

    /// Gravity strength (affects falling speed)
    var gravity: Double {
        switch self {
        case .mars: return 0.38
        case .luna: return 0.165
        case .io: return 0.183
        case .europa: return 0.134
        case .titan: return 0.14
        case .venus: return 0.9
        case .mercury: return 0.38
        case .enceladus: return 0.011
        }
    }
}
