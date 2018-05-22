//
//  TapBodyModel.swift
//  TapNetworkManager/Core
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

/// Tap body model.
public struct TapBodyModel {

    // MARK: - Public -
    // MARK: Properties
    
    /// Serialization type.
    public var serializationType: TapSerializationType = .json

    /// Body dictionary.
    public var body: [String: Any]

    /// Initializes the model with body dictionary and serialization type.
    ///
    /// - Parameters:
    ///   - body: Body dictionary.
    ///   - serializationType: Serialization type.
    public init(body: [String: Any], serializationType: TapSerializationType = .json) {

        self.serializationType = serializationType
        self.body = body
    }
}
