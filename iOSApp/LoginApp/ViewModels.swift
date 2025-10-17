import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen = .phone
    @Published var phone: String = ""
    @Published var password: String = ""
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var birthDate: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    
    enum AuthScreen {
        case phone
        case password
        case register
    }
    
    func checkUser() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await APIService.shared.checkUser(phone: phone)
            if response.exists {
                currentScreen = .password
            } else {
                currentScreen = .register
            }
        } catch {
            errorMessage = "Failed to check user: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func login() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await APIService.shared.login(phone: phone, password: password)
            self.user = response.user
            self.isAuthenticated = true
            // Save token to Keychain
            saveToken(response.token)
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func register() async {
        isLoading = true
        errorMessage = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let userData: [String: Any] = [
            "phone": phone,
            "password": password,
            "full_name": fullName,
            "email": email,
            "birth_date": dateFormatter.string(from: birthDate)
        ]
        
        do {
            let response = try await APIService.shared.register(userData: userData)
            self.user = response.user
            self.isAuthenticated = true
            // Save token to Keychain
            saveToken(response.token)
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveToken(_ token: String) {
        // Implement token saving to Keychain
        UserDefaults.standard.set(token, forKey: "authToken")
    }
}