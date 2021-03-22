import SwiftGD
import Foundation
import Routing
import Vapor

public func routes(_ router: Router) throws {
    let rootDirectory = DirectoryConfig.detect().workDir
    let uploadDirectory = URL(fileURLWithPath: "\(rootDirectory)Public/uploads")
    let originalsDirectory = uploadDirectory.appendingPathComponent("originals")
    let thumbsDirectory = uploadDirectory.appendingPathComponent("thumbs")

    router.get() {request -> Future<View> in
        let fm = FileManager()

        guard let files = try? fm.contentsOfDirectory(at: originalsDirectory, includingPropertiesForKeys: nil) else {
            throw Abort(.internalServerError)
        }

        let allFileNames = files.map{ $0.lastPathComponent }
        let visibleFileNames = allFileNames.filter { $0.hasPrefix(".") }

        let context = ["files": visibleFileNames]

        return try request.view().render("home", context)
    }

    router.post("upload") { req -> Future<Response> in
        struct UserFile: Content {
            var upload: [File]
        }

        return try req.content.decode(UserFile.self).map(to: Response.self) { data in
            let acceptableTypes = [MediaType.jpeg, MediaType.png]

            for file in data.upload {
                guard let mimeType = file.contentType else { continue }
                guard acceptableTypes.contains(mimeType) else { continue }

                let cleanedFileName = file.filename.replacingOccurrences(of: " ", with: "-")

                let newURL = originalsDirectory.appendingPathComponent(cleanedFileName)

                _ = try? file.data.write(to: newURL)

                let thumbURL = thumbsDirectory.appendingPathComponent(cleanedFileName)

                if let image = Image(url: newURL) {
                    if let resizedImage = image.resizedTo(width: 300) {
                        resized.write(to: thumbURL)
                    }
                }
            }

            return req.redirect(to: "/")
        }
    }
}
