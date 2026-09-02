import Foundation
import DatadogCore
import DatadogLogs
import DatadogRUM

final class DatadogService {
    static let shared = DatadogService()
    private init() {}

    private var initialized = false
    private var logger: (any LoggerProtocol)?
    // Stored when applyTenancyAttribute is called from @MainActor context
    private var tenancyName: String = ""

    // MARK: - Credentials

    private enum Credentials {
        static let clientToken   = "pub8e945826488415fcfc9e1a4521cb1ba6"
        static let applicationId = "83159002-94cb-473d-b551-56d302810fc6"
        static let env           = "staging"
        static let serviceName   = "vlens-ios-sdk"
    }

    // MARK: - Initialization

    func initialize() {
        guard !initialized else { return }

        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: Credentials.clientToken,
                env: Credentials.env,
                site: .us5,
                service: Credentials.serviceName
            ),
            trackingConsent: .granted
        )

        Logs.enable(with: Logs.Configuration())

        RUM.enable(with: RUM.Configuration(applicationID: Credentials.applicationId))

        // Fully qualified to avoid conflict with os.Logger
        logger = DatadogLogs.Logger.create(
            with: DatadogLogs.Logger.Configuration(
                name: "VLensLib",
                networkInfoEnabled: true,
                bundleWithRumEnabled: true
            )
        )

        initialized = true
        debugPrint("[VLens][Datadog] Initialized — isInitialized=\(Datadog.isInitialized()), logger=\(logger != nil), site=us5, service=\(Credentials.serviceName)")
        logger?.info("vlens iOS SDK Datadog initialized")
    }

    // Called from @MainActor context — tenancyName value passed in so we avoid
    // accessing CachedData from a non-isolated context here.
    func applyTenancyAttribute(tenancyName: String) {
        guard initialized, !tenancyName.isEmpty else { return }
        self.tenancyName = tenancyName
        logger?.addAttribute(forKey: "tenancy_name", value: tenancyName)
        RUMMonitor.shared().addAttribute(forKey: "tenancy_name", value: tenancyName)
    }

    // MARK: - Logging

    func info(_ message: String, attributes: [String: Encodable] = [:]) {
        guard initialized else { return }
        logger?.info(message, error: nil, attributes: attributes)
    }

    func warn(_ message: String, attributes: [String: Encodable] = [:]) {
        guard initialized else { return }
        logger?.warn(message, error: nil, attributes: attributes)
    }

    func error(_ message: String, error: Error? = nil, attributes: [String: Encodable] = [:]) {
        guard initialized else { return }
        logger?.error(message, error: error, attributes: attributes)
    }

    // MARK: - RUM Views

    func rumStartView(key: String, name: String) {
        guard initialized else { return }
        RUMMonitor.shared().startView(key: key, name: name)
    }

    func rumStopView(key: String) {
        guard initialized else { return }
        RUMMonitor.shared().stopView(key: key)
    }

    // MARK: - RUM Actions

    func rumAddAction(_ name: String, type: RUMActionType = .custom, attributes: [String: Encodable] = [:]) {
        guard initialized else { return }
        RUMMonitor.shared().addAction(type: type, name: name, attributes: attributes)
    }

    // MARK: - RUM Errors

    func rumAddError(_ message: String, source: RUMErrorSource = .custom, attributes: [String: Encodable] = [:]) {
        guard initialized else { return }
        let prefixed = tenancyName.isEmpty ? message : "[\(tenancyName)] \(message)"
        RUMMonitor.shared().addError(message: prefixed, source: source, attributes: attributes)
    }

    // MARK: - Feature Operations (mapped to RUM actions + logs)

    func rumStartFeatureOperation(_ name: String) {
        rumAddAction("feature_start_\(name)")
        info("\(name) started")
    }

    func rumSucceedFeatureOperation(_ name: String) {
        rumAddAction("feature_success_\(name)")
        info("\(name) succeeded")
    }

    func rumFailFeatureOperation(_ name: String, reason: String = "") {
        let msg = reason.isEmpty ? "\(name) failed" : "\(name) failed: \(reason)"
        rumAddError(msg)
        rumAddAction("feature_failure_\(name)")
        error(msg, attributes: reason.isEmpty ? [:] : ["reason": reason])
    }
}
