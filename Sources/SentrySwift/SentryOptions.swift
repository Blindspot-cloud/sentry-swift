//
//  SentryOptions.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


public struct SentryOptions {
    public let release: String?
    public let environment: String
    public let server_name: String?
    
    public let debug: Bool
    public let disabled: Bool
    
    public let sample_rate: Float
    public let traces_sample_rate: Float
    
    public let transport_factory: TransportFactory
    
    public init(release: String? = nil, environment: String = "production", sample_rate: Float = 1.0, traces_sample_rate: Float = 0.0, server_name: String? = nil, debug: Bool = false, disabled: Bool = false, transport_factory: TransportFactory = TransporterFactory()) throws {
        self.release = release
        self.environment = environment
        
        guard sample_rate >= 0.0 && sample_rate <= 1.0 else {
            throw SentryError.InvalidArgumentException("sample_rate must be betweeen 0.0..1.0")
        }
        self.sample_rate = sample_rate
        
        guard traces_sample_rate >= 0.0 && traces_sample_rate <= 1.0 else {
            throw SentryError.InvalidArgumentException("traces_sample_rate must be betweeen 0.0..1.0")
        }
        self.traces_sample_rate = traces_sample_rate
        
        self.server_name = server_name
        self.debug = debug
        self.disabled = disabled
        self.transport_factory = transport_factory
    }
    
    internal init() {
        self.release = nil
        self.environment = "production"
        self.sample_rate = 1.0
        self.traces_sample_rate = 0.0
        
        self.server_name = nil
        self.debug = false
        self.disabled = true
        self.transport_factory = DummyTransporterFactory()
    }
    
}
