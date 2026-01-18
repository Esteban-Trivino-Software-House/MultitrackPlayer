import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

class GoogleAuthViewModel: ObservableObject {
    @Published var user: GIDGoogleUser?

    func signIn() {
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("❌ Error al iniciar sesión con Google: \(error.localizedDescription)")
                return
            }

            self.user = result?.user
            print("✅ Usuario: \(self.user?.profile?.email ?? "Sin email")")
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        user = nil
    }
}
