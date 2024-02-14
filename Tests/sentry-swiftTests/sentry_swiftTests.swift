import XCTest
@testable import SentrySwift


final class sentry_swiftTests: XCTestCase {
    func testExample() async throws {
        let dsn = try Dsn(
            fromString: "http://19f890c7ea3b29048ddcba4aafd79cd1@localhost:9999/2"
        )
        let sentryGuard = try Sentry.initialize(dsn: dsn, options: .init(debug: true))
        
        assert(Hub.current().client != nil)
        
        
        let tr = Sentry.start_transaction(name: "GET /bar", op: .http_server)
        Sentry.configure_scope { scope in
            scope.set_span(span: tr)
        }
        tr.set_request(Request(method: "GET", url: "/bar"))
        
        try await Task.sleep(nanoseconds: 1000000000)
        
        var span = tr.start_child(op: .http_client, description: "client request")
        try await Task.sleep(nanoseconds: 1000000000)
        
    
        var header = Sentry.configure_scope { scope in
            scope.span?.get_header()
        }
        assert(header??.0 == "sentry-trace")
        assert(header??.1 != nil)
        
        span.finish()
        
        tr.set_status(.ok)
        tr.finish()
        
        try await sentryGuard.close()
    }
}
