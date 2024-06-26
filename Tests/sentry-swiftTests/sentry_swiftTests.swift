import XCTest
@testable import SentrySwift


enum MyError: Error {
    case runtimeError(String)
}

class Bar {
    static func x() -> Int {
        Sentry.capture_error(error: MyError.runtimeError("abc"))
        
        return 1
    }
    
    func y() -> Int {
        return Bar.x()
    }
}

func foo() -> String? {
    return String(Bar().y())
}

final class sentry_swiftTests: XCTestCase {
    func testExample() async throws {
        let dsn = try Dsn(
            fromString: "http://19f890c7ea3b29048ddcba4aafd79cd1@localhost:9999/2"
        )
        let sentryGuard = try Sentry.initialize(dsn: dsn, options: .init(debug: true))
        
        assert(Hub.current().client != nil)
        

        foo() // test callstack
        
        
        let tr = Sentry.start_transaction(name: "GET /bar", op: .http_server)
        Sentry.configure_scope { scope in
            scope.set_span(span: tr)
        }
        
        tr.set_request(Request(method: "GET", url: "/bar"))
        
        try await Task.sleep(nanoseconds: 1000000000)
        
        var span = tr.start_child(op: .http_client, description: "client request")
        try await Task.sleep(nanoseconds: 1000000000)
        
    
        let header = Sentry.configure_scope { scope in
            assert(scope.span != nil)
            return scope.span?.get_header()
        }.flatMap { $0 }
        
        assert(header?.0 == "sentry-trace")
        assert(header?.1 != nil)
        
        span.finish()
        
        tr.set_status(.ok)
        tr.finish()
        
        try await sentryGuard.close()
    }
}
