import SwiftUI

@main
struct CodeCollabViewer: App {
    
    @State var isLoggedIn: Bool = false
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 2)
    @StateObject private var userDataStore = UserDataStore()
    
    func verifyToken() async {
        
        let data: [String: Any] = [:];
        
        await Request(urlstring: "https://api.codecollab.io/auth/verifyToken", method: .post, data: data, onComplete: { response in
            if let isValid = response["isValid"] as? Int {
                if isValid == 0 {
                    userDataStore.token = "";
                    self.isLoggedIn = false;
                } else {
                    print("Token is Valid");
                    self.isLoggedIn = true;
                }
            }
        }, onError: { error in
            print(error)
        }, userDataStore: userDataStore);
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await verifyToken()
                    }
                    UserDataStore.load { result in
                        switch result {
                            case .failure(let error):
                            print(error.localizedDescription)
                            case .success(let userData):
                            userDataStore.token = userData.token;
                            userDataStore.uname = userData.uname;
                            userDataStore.email = userData.email;
                            userDataStore.id = userData.id;
                            userDataStore.profilePic = userData.profilePic;
                            userDataStore.dname = userData.dname;
                        }
                    }
                }
                .environmentObject(userDataStore)
                .offset(y: kGuardian.slide).animation(.easeInOut(duration: 1.0))
        }
    }
}
