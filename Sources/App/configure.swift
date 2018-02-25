import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)
//    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Directory
    let directory = DirectoryConfig.detect()
    services.register(directory)

    // Configure a SQLite database
    var databases = DatabaseConfig()
    try databases.add(database: SQLiteDatabase(storage: .file(path: "\(directory.workDir)forums.db")), as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Forum.self, database: .sqlite)
    migrations.add(model: Message.self, database: .sqlite)
    migrations.add(model: User.self, database: .sqlite)
    services.register(migrations)

    // Configure the rest of your application here
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

}
