//
//  Scope.swift
//  
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


public struct Scope {
    internal var tags: [String : String]
    internal var extra: [String : Value]
    internal var level: Level?
    internal var user: User?
    internal var transaction: String?
    internal var contexts: [String : Context]
    internal var breadcrumbs: Breadcrumbs?
    internal var span: SpanLike?
    
    init() {
        self.tags = [:]
        self.extra =  [:]
        self.level = nil
        self.user = nil
        self.transaction = nil
        self.contexts = [:]
        self.breadcrumbs = nil
    }
    
    internal mutating func add_breadcrumb(_ bc: Breadcrumb) {
        var br = self.breadcrumbs ?? Breadcrumbs(values: [])
        br.values.append(bc)
    }
    
    public mutating func set_span(span: SpanLike?) {
        self.span = span
    }
    
    public func get_span() -> SpanLike? {
        return self.span
    }
    
    public mutating func set_context(key: String, ctx: Context) {
        self.contexts[key] = ctx
    }
    
    public mutating func set_transaction(transaction: String) {
        self.transaction = transaction
    }
    
    public mutating func set_user(user: User?) {
        self.user = user
    }
    
    public mutating func set_level(level: Level?) {
        self.level = level
    }
    
    public mutating func set_tag(key: String, val: String?) {
        if val == nil {
            tags.removeValue(forKey: key)
        }else {
            tags[key] = val
        }
    }
    
    public mutating func set_extra(key: String, val: Value?) {
        if val == nil {
            extra.removeValue(forKey: key)
        }else {
            extra[key] = val
        }
    }
}
