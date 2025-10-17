import SwiftUI

struct PhoneInputView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            AppLogoView()
            
            Text("Вход")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Номер телефона", text: $viewModel.phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .padding(.horizontal)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await viewModel.checkUser()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Продолжить")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.phone.isEmpty || viewModel.isLoading)
            
            Spacer()
        }
        .padding()
    }
}

struct PasswordInputView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            AppLogoView()
            
            Text("Введите пароль")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Войти")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.password.isEmpty || viewModel.isLoading)
            
            Button("Назад") {
                viewModel.currentScreen = .phone
                viewModel.errorMessage = ""
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
    }
}

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AppLogoView()
                
                Text("Регистрация")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Group {
                    TextField("ФИО", text: $viewModel.fullName)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Пароль", text: $viewModel.password)
                    DatePicker("Дата рождения", selection: $viewModel.birthDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        await viewModel.register()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Зарегистрироваться")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .disabled(viewModel.fullName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                
                Button("Назад") {
                    viewModel.currentScreen = .phone
                    viewModel.errorMessage = ""
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct AppLogoView: View {
    @State private var logoImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let image = logoImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .overlay(
                        Text("Лого")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            loadLogoImage()
        }
    }
    
    private func loadLogoImage() {
        // Здесь можно загрузить изображение из сети или локальных ресурсов
        // Для примера создаем простое изображение программно
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        let image = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            UIColor.white.setFill()
            let rect = CGRect(x: 25, y: 25, width: 50, height: 50)
            context.fill(rect)
        }
        self.logoImage = image
    }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainAppView(user: authViewModel.user!)
            } else {
                switch authViewModel.currentScreen {
                case .phone:
                    PhoneInputView(viewModel: authViewModel)
                case .password:
                    PasswordInputView(viewModel: authViewModel)
                case .register:
                    RegisterView(viewModel: authViewModel)
                }
            }
        }
        .animation(.easeInOut, value: authViewModel.currentScreen)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct MainAppView: View {
    let user: User
    
    var body: some View {
        VStack {
            AppLogoView()
            
            Text("Добро пожаловать!")
                .font(.title)
            
            Text(user.fullName ?? "Пользователь")
                .font(.headline)
            
            Text(user.phone)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

@main
struct LoginApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}