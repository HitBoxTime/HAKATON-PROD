import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:5000/api"
    
    func checkUser(phone: String) async throws -> CheckUserResponse {
        let url = URL(string: "\(baseURL)/check-user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["phone": phone]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(CheckUserResponse.self, from: data)
    }
    
    func login(phone: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["phone": phone, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, 
                         userInfo: [NSLocalizedDescriptionKey: errorResponse?["error"] ?? "Login failed"])
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func register(userData: [String: Any]) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 201 else {
            let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, 
                         userInfo: [NSLocalizedDescriptionKey: errorResponse?["error"] ?? "Registration failed"])
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
}