//
//  Transaction.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


public class Transaction: SpanLike {
    let name: String
    let op: OperationType
    
    var name_source: TransactionInfoSource? = nil
    
    let span_id: String
    let trace_id: String
    let parent_span_id: String?
    let parent_sampled: Bool?
    let start_time: Double
    
    var status: SpanStatus? = nil
    var request: Request? = nil
    
    var spans: [Span] = []
    
    func add_span(_ span: Span) {
        self.spans.append(span)
    }
    
    init(name: String, op: OperationType, headers: [String : String]? = nil) {
        self.name = name
        self.op = op
        self.span_id = newSpanId()
        
        if let headers = headers, let header = headers.first(where: { $0.key == "sentry-trace" }) {
            let (trace_id, parent_span_id, parent_sampled) = parse_sentry_header(header: header.value)
            self.trace_id = trace_id
            self.parent_span_id = parent_span_id
            self.parent_sampled = parent_sampled
        }else {
            self.trace_id = UUID().hexadecimalEncoded
            self.parent_span_id = nil
            self.parent_sampled = nil
        }
        
        self.start_time = Date().timeIntervalSince1970
    }
    
    public func start_child(op: OperationType, description: String, direct_child: Bool = true) -> TransactionSpan {
        TransactionSpan(op: op, description: description, parent_span_id: direct_child ? self.span_id : nil, span_like: self)
    }
    
    public func set_status(_ status: SpanStatus) {
        self.status = status
    }
    
    public func get_status() -> SpanStatus? {
        return self.status
    }
    
    public func set_request(_ req: Request) {
        self.request = req
    }
    
    public func set_name_source(_ source: TransactionInfoSource) {
        self.name_source = source
    }
    
    
    public func finish() {
        let end_time = Date().timeIntervalSince1970
        
        Hub.hub.capture_event(event: Event(event_id: UUID(), timestamp: end_time, level: nil, logger: nil, transaction: name, server_name: nil, release: nil, dist: nil, tags: nil, environment: nil, modules: nil, extra: nil, message: nil, exception: nil, breadcrumbs: nil, user: nil, request: request, sdk: nil, contexts: [
            "trace": .trace(
                .init(op: op, span_id: span_id, trace_id: trace_id, status: status, description: nil, parent_span_id: parent_span_id)
            )
        ], type: .transaction, spans: spans, start_timestamp: start_time, transaction_info: name_source.map { TransactionInfo(source: $0) }))
    }
}

private func parse_sentry_header(header: String) -> (String, String, Bool) {
    let header = header.trimmingCharacters(in: .whitespaces)
    let parts = header.split(separator: "-")
    
    return (String(parts[0]), String(parts[1]), parts[3] == "1" ? true : false)
}


protocol SpanLike {
    mutating func add_span(_ span: Span)
}

public struct TransactionSpan: SpanLike {
    internal let op: OperationType
    internal let description: String
    internal let start_time: Double
    internal let parent_span_id: String?
    internal let span_id: String
    // TODO: Tags
    
    internal var span_like: SpanLike
    
    internal var spans: [Span] = []
    
    var status: SpanStatus? = nil
    var request: Request? = nil
    
    init(op: OperationType, description: String, parent_span_id: String?, span_like: SpanLike) {
        self.op = op
        self.description = description
        self.parent_span_id = parent_span_id
        self.span_like = span_like
        self.spans = []
        self.status = nil
        self.request = nil
        self.span_id = newSpanId()
        self.start_time = Date().timeIntervalSince1970
    }
    
    mutating func add_span(_ span: Span) {
        spans.append(span)
    }
    
    public func start_child(op: OperationType, description: String, direct_child: Bool = true) -> TransactionSpan {
        TransactionSpan(op: op, description: description, parent_span_id: direct_child ? self.span_id : nil, span_like: self)
    }
    
    public mutating func set_status(_ status: SpanStatus) {
        self.status = status
    }
    
    public func get_status() -> SpanStatus? {
        return self.status
    }
    
    public mutating func set_request(_ req: Request) {
        self.request = req
    }
    
    
    public mutating func finish() {
        let end_time = Date().timeIntervalSince1970
        let data_raw: [String: String?] =  [
            "method": request?.method,
            "url": request?.url,
            "query_string": request?.query_string
        ]
        let data: [String: Value] = Dictionary(uniqueKeysWithValues: data_raw.compactMapValues { $0 }.map { key, value in (key, .string(value)) })
        
        span_like.add_span(Span(span_id: span_id, trace_id: UUID().hexadecimalEncoded, parent_span_id: parent_span_id, op: op, timestamp: end_time, start_timestamp: start_time, data: data.isEmpty ? nil : data, spans: nil, description: description, status: status))
    }
}


func newSpanId() -> String {
    String(UUID().hexadecimalEncoded.prefix(16))
}
