import AuthenticationServices
import UIKit

enum CredentialManager {
    static func saveCredentials(
        username: String,
        password: String,
        anchor: ASPresentationAnchor,
        title: String? = nil
    ) async throws {
        let host = Constants.host
        print("saveCredentials - username: \(username), password: \(password), host: \(host)")
        let credential = ASPasswordCredential(user: username, password: password)
        let scope = ASAutoFillURLScope(scheme: .https, host: host)
        let credentialTitle = title ?? "Password for \(username)"
        try await ASCredentialDataManager().save(
            password: credential,
            for: scope,
            title: credentialTitle,
            anchor: anchor
        )
    }
}
