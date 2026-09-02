#if !SWIFT_PACKAGE
import Foundation

private final class BundleLocator {}
extension Bundle {
    static var module: Bundle {
        let bundleName = "VLensLib"
        let frameworkBundle = Bundle(for: BundleLocator.self)
        if let url = frameworkBundle.url(forResource: bundleName, withExtension: "bundle"),
           let bundle = Bundle(url: url) {
            return bundle
        }
        return frameworkBundle
    }
}
#endif
