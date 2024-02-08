//
//  Event.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation
import Logging

// docs at https://develop.sentry.dev/sdk/event-payloads/
public struct Event: Encodable {
    /// Unique identifier of this event.
    /// Hexadecimal string representing a uuid4 value. The length is exactly 32 characters. Dashes are not allowed. Has to be lowercase.
    /// Even though this field is backfilled on the server with a new uuid4, it is strongly recommended to generate that uuid4 clientside.
    /// There are some features like user feedback which are easier to implement that way, and debugging in case events get lost in your Sentry installation is also easier.
    @UUIDHexadecimalEncoded
    var event_id: UUID

    /// Indicates when the event was created in the Sentry SDK. The format is a numeric (integer or float) value representing the number of seconds that have elapsed since the Unix epoch.
    let timestamp: Double

    /// Platform identifier of this event (defaults to "other").
    /// A string representing the platform the SDK is submitting from. This will be used by the Sentry interface to customize various components in the interface.
    /// Acceptable values are: `as3`, `c`, `cfml`, `cocoa`, `csharp`, `elixir`, `haskell`, `go`, `groovy`, `java`, `javascript`, `native`, `node`, `objc`, `other`, `perl`, `php`, `python`, `ruby`
    let platform: String = "other"

    /// The record severity. Defaults to `error`.
    let level: Level?

    /// The name of the logger which created the record.
    let logger: String?

    /// The name of the transaction which caused this exception.
    /// For example, in a web app, this might be the route name.
    let transaction: String?

    /// Server or device name the event was generated on.
    /// This is supposed to be a hostname.
    let server_name: String?

    /// The release version of the application. Release versions must be unique across all projects in your organization.
    let release: String?
    
    /// Distributions are used to disambiguate build or deployment variants of the same release of an application.
    let dist: String?

    /// Optional. A map or list of tags for this event. Each tag must be less than 200 characters.
    let tags: [String: String]?

    /// The environment name, such as `production` or `staging`.
    let environment: String?
    
    /// A list of relevant modules and their versions.
    let modules: [String: String]?
    
    let extra: [String: Value]?

    /// The Message Interface carries a log message that describes an event or error.
    let message: Message?

    /// One or multiple chained (nested) exceptions.
    let exception: Exceptions?

    /// List of breadcrumbs recorded before this event.
    let breadcrumbs: Breadcrumbs?

    /// Information about the user who triggered this event.
    let user: User?
    
    /// Information about incoming request
    let request: Request?
    
    /// Informaction about the SDK
    let sdk: SDK?
    
    /// Contexts describing the environment (e.g. device, os or browser).
    let contexts: [String : Context]?
    
    /// Type of event. Must be set for transactions
    let type: EventType?
    
    /// Spans if type of event is transaction
    let spans: [Span]?
    
    /// Start time of this event
    let start_timestamp: Double?
    
    let transaction_info: TransactionInfo?
    
    public init(event_id: UUID, timestamp: Double, level: Level?, logger: String?, transaction: String?, server_name: String?, release: String?, dist: String?, tags: [String : String]?, environment: String?, modules: [String : String]?, extra: [String : Value]?, message: Message?, exception: Exceptions?, breadcrumbs: Breadcrumbs?, user: User?, request: Request?, sdk: SDK?, contexts: [String : Context]?, type: EventType?, spans: [Span]?, start_timestamp: Double?, transaction_info: TransactionInfo?) {
        self._event_id = UUIDHexadecimalEncoded(wrappedValue: event_id)
        self.timestamp = timestamp
        self.level = level
        self.logger = logger
        self.transaction = transaction
        self.server_name = server_name
        self.release = release
        self.dist = dist
        self.tags = tags
        self.environment = environment
        self.modules = modules
        self.extra = extra
        self.message = message
        self.exception = exception
        self.breadcrumbs = breadcrumbs
        self.user = user
        self.request = request
        self.sdk = sdk
        self.contexts = contexts
        self.type = type
        self.spans = spans
        self.start_timestamp = start_timestamp
        self.transaction_info = transaction_info
    }
}

public struct Span: Encodable {
    let span_id: String
    let trace_id: String
    let parent_span_id: String?
    let op: OperationType
    let timestamp: Double
    let start_timestamp: Double?
    let data: [String: Value]?
    let spans: [Span]?
    let description: String?
    let status: SpanStatus?
}

public struct TransactionInfo: Encodable {
    let source: TransactionInfoSource
}

public enum TransactionInfoSource: String, Encodable {
    case custom
    case url
    case route
    case view
    case component
    case task
}

public enum Context: Encodable {
    case trace(TraceContext)
    
    enum CodingKeys: CodingKey {
        case trace
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .trace(let a0):
            try a0.encode(to: encoder)
        }
    }
}

public struct TraceContext: Encodable {
    let op: OperationType?
    let span_id: String?
    let trace_id: String?
    let status: SpanStatus?
    let description: String?
    let parent_span_id: String?
}

public enum SpanStatus: String, Encodable {
    case aborted
    case already_exists
    case cancelled
    case data_loss
    case deadline_exceeded
    case failed_precondition
    case internal_error
    case invalid_argument
    case not_found
    case ok
    case out_of_range
    case permission_denied
    case resource_exhausted
    case unauthenticated
    case unavailable
    case unimplemented
    case unknown
}

public enum OperationType: String, Encodable {
    case mark
    case function
    case websocket_server = "websocket.server"
    case rpc
    case grpc
    case graphql_execute = "graphql.execute"
    case graphql_parse = "graphql.parse"
    case graphql_resolve = "graphql.resolve"
    case graphql_request = "graphql.request"
    case graphql_query = "graphql.query"
    case graphql_mutation = "graphql.mutation"
    case graphql_subscription = "graphql.subscription"
    case graohql_validate = "graphql.validate"
    case subprocess_wait = "subprocess.wait"
    case subprocess_communicate = "subprocess.communicate"
    case middleware_handle = "middleware.handle"
    case view_render = "view.render"
    case template_init = "template.init"
    case template_parse = "template.parse"
    case file = "file"
    case app_bootstrap = "app.bootstrap"
    case db_query = "db.query"
    case db_redis = "db.redis"
    case cache_get_item = "cache.get_item"
    case cache_delete_item = "cache.delete_item"
    case topic_send = "topic.send"
    case topic_receive = "topic.receive"
    case queue_task = "queue.task"
    case http_server = "http.server"
    case http_client = "http.client"
}

public enum EventType: String, Encodable {
    case transaction
    case error
    case csp
    case nel
    case hpkp
    case expectct
    case expectstaple
    case userreportv2
}

public struct SDK: Encodable {
    let integrations: [String]?
    let name: String?
    let version: String?
}

public enum ApiTarget: String, Encodable {
    case graphql
    case rest
    case grpc
}

public struct Request: Encodable {
    let method: String?
    let url: String?
    let query_string: String?
    let body_size: UInt64?
    let api_target: ApiTarget?
    let cookies: String?
    let data: Value?
    let env: [String: Value]?
    let fragment: String?
    let headers: [String: String]?
    let _protocol: String?
    
    init(method: String? = nil, url: String? = nil, query_string: String? = nil, body_size: UInt64? = nil, api_target: ApiTarget? = nil, cookies: String? = nil, data: Value? = nil, env: [String : Value]? = nil, fragment: String? = nil, headers: [String : String]? = nil, _protocol: String? = nil) {
        self.method = method
        self.url = url
        self.query_string = query_string
        self.body_size = body_size
        self.api_target = api_target
        self.cookies = cookies
        self.data = data
        self.env = env
        self.fragment = fragment
        self.headers = headers
        self._protocol = _protocol
    }
    
    
    private enum CodingKeys : String, CodingKey {
        case method, url, query_string, body_size, api_target, cookies, data, env, fragment, headers
        case _protocol = "protocol"
    }
}

public enum Level: String, Encodable {
    case fatal
    case error
    case warning
    case info
    case debug

    init(from: Logger.Level) {
        switch from {
        case .trace, .debug:
            self = .debug
        case .info, .notice:
            self = .info
        case .warning:
            self = .warning
        case .error:
            self = .error
        case .critical:
            self = .fatal
        }
    }
}

public enum Message: Encodable {
    enum CodingKeys: String, CodingKey {
        case message
        case params
    }

    case raw(message: String)
    case format(message: String, params: [String])

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .raw(let message):
            var container = encoder.singleValueContainer()
            try container.encode(message)
        case .format(let message, let params):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(message, forKey: .message)
            try container.encode(params, forKey: .params)
        }
    }
}

public struct Exceptions: Encodable {
    let values: [ExceptionDataBag]
}

public struct ExceptionDataBag: Encodable {
    /// The type of exception, e.g. `ValueError`.
    /// At least one of `type` or `value` is required, otherwise the exception is discarded.
    let type: String?

    /// Human readable display value.
    /// At least one of `type` or `value` is required, otherwise the exception is discarded.
    let value: String?

    /// Stack trace containing frames of this exception.
    let stacktrace: Stacktrace?
}

public struct Stacktrace: Encodable, Equatable {
    /// A non-empty list of stack frames. The list is ordered from caller to callee, or oldest to youngest. The last frame is the one creating the exception.
    let frames: [Frame]
}

public struct Frame: Encodable, Equatable {
    /// The source file name (basename only).
    let filename: String?

    /// Name of the frame's function. This might include the name of a class.
    /// This function name may be shortened or demangled. If not, Sentry will demangle and shorten it for some platforms. The original function name will be stored in `raw_function`.
    let function: String?

    /// A raw (but potentially truncated) function value.
    let raw_function: String?

    /// Line number within the source file, starting at 1.
    let lineno: Int?

    /// Column number within the source file, starting at 1.
    let colno: Int?

    /// Absolute path to the source file.
    let abs_path: String?

    /// An optional instruction address for symbolication. This should be a string with a hexadecimal number that includes a `0x` prefix. If this is set and a known image is defined in the Debug Meta Interface, then symbolication can take place.
    let instruction_addr: String?
}

public struct Breadcrumbs: Encodable {
    var values: [Breadcrumb]
}

public struct Breadcrumb: Encodable {
    let message: String?
    let level: Level?
    let category: String?
    let timestamp: Double?

    init(message: String? = nil, level: Level? = nil, timestamp: Double? = nil, category: String? = nil) {
        self.message = message
        self.level = level
        self.timestamp = timestamp
        self.category = category
    }
}

public struct User: Encodable {
    let id: String?
    let ip_address: String?
    let email: String?
    let name: String?
    let segment: String?
    let username: String?
}
