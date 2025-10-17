import Foundation

struct User: Codable {
    let id: Int
    let phone: String
    let fullName: String?
    let email: String?
    let birthDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case fullName = "full_name"
        case email
        case birthDate = "birth_date"
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct CheckUserResponse: Codable {
    let exists: Bool
    let requiresPassword: Bool
}