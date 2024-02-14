//
//  Transporter.swift
//  
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation
import AsyncHTTPClient
import NIOCore

public protocol TransportFactory {
    func createTransport(dsn: Dsn, eventLoop: EventLoopGroup, options: SentryOptions) -> Transport
}

public protocol Transport {
    func send_envelope(envelope: Envelope)
    
    func flush() async throws
    func close() throws
}


internal class Transporter: Transport {
    let envelopeApi: String
    let authHeader: String
    
    let jsonEncode: JSONEncoder
    let jsonDecode: JSONDecoder
    let httpClient: HTTPClient
    let option: SentryOptions
    
    init(dsn: Dsn, jsonEncode: JSONEncoder, jsonDecode: JSONDecoder, httpClient: HTTPClient, option: SentryOptions) {
        self.envelopeApi = dsn.getEnvelopeApiEndpointUrl()
        self.authHeader = dsn.getAuthHeader()
        
        self.jsonEncode = jsonEncode
        self.jsonDecode = jsonDecode
        self.httpClient = httpClient
        self.option = option
    }
    
    func send_envelope(envelope: Envelope) {
        Task {
            while true {
                do {
                    let uid = try await send(envelope: envelope)
                    
                    if uid == nil {
                        try await Task.sleep(nanoseconds: 60 * 1000000000)
                        continue
                    } else if option.debug && uid != nil {
                        print("[SWIFT-SENTRY] Transporter sentry response: \(uid ?? "")")
                    }
                } catch where option.debug {
                    print("[SWIFT-SENTRY] Transporter error: \(error)")
                } catch {}
                return
            }
        }
    }
    
    func close() throws {
        try httpClient.syncShutdown()
    }
    
    func flush() async throws {
        try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
    }
    
    @discardableResult
    public func send(envelope: Envelope) async throws -> String? {
        let data = try envelope.dump(encoder: jsonEncode)
        
        var request = HTTPClientRequest(url: self.envelopeApi)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/x-sentry-envelope")
        request.headers.replaceOrAdd(name: "User-Agent", value: Sentry.version)
        request.headers.replaceOrAdd(name: "X-Sentry-Auth", value: self.authHeader)
        request.body = .bytes(ByteBuffer(data: data))
        
        let resp = try await httpClient.execute(request, timeout: .seconds(10))
        
        if resp.status == .tooManyRequests {
            return nil
        }
    
        return try jsonDecode.decode(SentryUUIDResponse.self, from: try await resp.body.collect(upTo: Int.max)).id
    }
}

public struct TransporterFactory: TransportFactory {
    public init() {}
    
    public func createTransport(dsn: Dsn, eventLoop: EventLoopGroup, options: SentryOptions) -> Transport {
        return Transporter(dsn: dsn, jsonEncode: JSONEncoder(), jsonDecode: JSONDecoder(), httpClient: HTTPClient(eventLoopGroupProvider: .shared(eventLoop)), option: options)
    }
}

struct SentryUUIDResponse: Codable {
    let id: String
}


internal struct DummyTransporter: Transport {
    func send_envelope(envelope: Envelope) {}
    
    func flush() async throws {}
    func close() throws {}
}

internal struct DummyTransporterFactory: TransportFactory {
    func createTransport(dsn: Dsn, eventLoop: NIOCore.EventLoopGroup, options: SentryOptions) -> Transport {
        return DummyTransporter()
    }
}
