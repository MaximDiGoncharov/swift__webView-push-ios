import SwiftUI
import WebKit
import UserNotifications

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var deviceToken: String = ""
    @State private var isWebViewPresented: Bool = false

    var body: some View {
        VStack {
            if isWebViewPresented {
                WebView(token: deviceToken)
            } else {
                Text("Ожидание получения токена...")
                    .onAppear {
                        requestNotificationAuthorization()
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DeviceTokenReceived"))) { notification in
            if let token = notification.userInfo?["token"] as? String {
                self.deviceToken = token
                self.isWebViewPresented = true // Переход к WebView после получения токена
            }
        }
    }

    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications() // Регистрация для удаленных уведомлений
                }
            } else if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
}

// Определяем AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let tokenString = tokenParts.joined()

        // Уведомляем SwiftUI о новом токене
        NotificationCenter.default.post(name: Notification.Name("DeviceTokenReceived"), object: nil, userInfo: ["token": tokenString])
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

struct WebView: UIViewRepresentable {
    var token: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Устанавливаем делегат
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if !token.isEmpty {
            // Формируем URL с токеном
             let urlString = "https://universal.laxo.one/enter/\(token)"
            
//              let urlString = "https://universal.laxo.one/web/index.php?token=\(token)"
//              let urlString = "https://universal.laxo.one/web/index.php?token=222"


            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Error loading page: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Provisional navigation failed: \(error.localizedDescription)")
        }
    }
}
