//
//  MarkdownTag.swift
//  App
//
//  Created by Lahari Ganti on 8/14/19.
//

import Foundation
import Async
import Leaf
import Markdown

public final class MarkdownTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(1)

        return EventLoopFuture.map(on: tag.container) {
            if let str = tag.parameters[0].string {
                let trimmed = str.replacingOccurrences(of: "\r\n", with: "\n")

                if let md = Markdown(string: trimmed) {
                    return .string(md.html)
                } else {
                    return .null
                }
            } else {
                return .null
            }
        }
    }
}
