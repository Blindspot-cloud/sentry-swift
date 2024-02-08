import XCTest
@testable import SentrySwift


final class sentry_swiftTests: XCTestCase {
    func testExample() async throws {
        let dsn = try Dsn(
            fromString: "http://ba3bd47ce2ec3f5ee5a8bb17797a30ba@localhost:3000/13"
        )
        let sentryGuard = try Sentry.initialize(dsn: dsn, options: .init(debug: true))
        
        assert(Hub.current().client != nil)
        
        
        let tr = Sentry.start_transaction(name: "GET /bar", op: .http_server)
        tr.set_request(Request(method: "GET", url: "/bar"))
        
        try await Task.sleep(nanoseconds: 1000000000)
        
        var span = tr.start_child(op: .http_client, description: "client request")
        try await Task.sleep(nanoseconds: 1000000000)
        span.finish()
        
        tr.set_status(.ok)
        tr.finish()
        
        try await sentryGuard.close()
    }
}
