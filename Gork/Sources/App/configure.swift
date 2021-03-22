import Vapor
import Fluent
import FluentMySQL
import Leaf

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    var tags = LeafTagConfig.default()
    tags.use(MarkdownTag(), as: "markdown")
    tags.use(LinkTag(), as: "link")
    services.register(tags)
    
    try services.register(FluentMySQLProvider())
    let databaseConfig = MySQLDatabaseConfig(hostname: "127.0.0.1",
                                             port: 3306,
                                             username: "swift",
                                             password: "swift",
                                             database:"swift",
                                             transport: .unverifiedTLS)

    services.register(databaseConfig)

    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Category.self, database: .mysql)
    migrationConfig.add(model: Post.self, database: .mysql)
    services.register(migrationConfig)
}
