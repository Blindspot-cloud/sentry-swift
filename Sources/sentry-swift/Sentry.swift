//
//  Sentry.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOPosix

public class Sentry {
    internal static let version = "SentrySwift/1.0.0"
    
    // Set by Sentry
    internal static let maxEnvelopeCompressedSize = 20_000_000
    internal static let maxEnvelopeUncompressedSize = 100_000_000
    internal static let maxAllAtachmentsCombined = 100_000_000
    internal static let maxEachAtachment = 100_000_000
    internal static let maxEventAndTransaction = 1_000_000
    internal static let maxSessionsPerEnvelope = 100
    internal static let maxSessionBucketPerSessions = 100
    
    // Default value
    internal static var maxAttachmentSize = 20_971_520

    
    internal static var instance: Sentry = Sentry(dsn: Dsn.localhost, options: SentryOptions(), transport: DummyTransporter())
    
    internal let dsn: Dsn
    internal let options: SentryOptions
    internal let transport: Transport
    internal let sdk: SDK = SDK(integrations: nil, name: "hell.swift", version: "0.0.1")
    
    private init(dsn: Dsn, options: SentryOptions, transport: Transport) {
        self.dsn = dsn
        self.options = options
        self.transport = transport
    }

    public static func initialize(
        dsn: Dsn,
        eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup.singleton,
        options: SentryOptions? = nil
    ) throws -> SentryGuard {
        let def = try SentryOptions(disabled: false)
        let options_merged = options ?? def
        
        let transport = options_merged.transport_factory.createTransport(dsn: dsn, eventLoop: eventLoopGroup, options: options_merged)
        
        instance = Sentry(dsn: dsn, options: options_merged, transport: transport)
        
        // Initialize main hub client
        Hub.current().bind_client(client: Client(options: options_merged))

        return SentryGuard(transport: transport)
    }
    
    
    public static func capture_event(event: Event) {
        Hub.hub.capture_event(event: event)
    }
    
    public static func capture_error(error: Error) {
        Hub.hub.capture_error(error: error)
    }
    
    public static func configure_scope(_ cb: (inout Scope) -> Void) {
        Hub.hub.configure_scope(cb)
    }
    
    public static func start_transaction(name: String, op: OperationType) -> Transaction {
        return Hub.hub.start_transaction(name: name, op: op)
    }
}

public struct SentryGuard {
    internal let transport: Transport
    
    public func close() async throws {
        try await self.transport.flush()
        try self.transport.close()
    }
}
