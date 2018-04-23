//
//  TapDecoder.swift
//  TapNetworkManager/Core
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

internal protocol TapDecoder {

    associatedtype DecodedType

    func decode(_ data: Any) throws -> DecodedType
}
