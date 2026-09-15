import Foundation

enum Constants {
    static var host: String {
        Bundle.main.object(forInfoDictionaryKey: "AssociatedDomainHost") as? String ?? ""
    }
}
