//
//  LinTag.swift
//  App
//
//  Created by Lahari Ganti on 8/14/19.
//

import Foundation
import Async
import Leaf

public final class LinkTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(1)

        return EventLoopFuture.map(on: tag.container) {
            if
                let dict = tag.parameters[0].dictionary,
                let id = dict["id"]?.string,
                let slug = dict["slug"]?.string
            {
                return .string("/read/\(id)/\(slug)")
            } else {
                return .null
            }
        }
    }
}
