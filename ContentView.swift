import SwiftUI
import FloatingLabelTextFieldSwiftUI

extension Color {
    static let oldPrimaryColor = Color(UIColor.systemIndigo)
    static let primaryColor = Color(red: 195/255, green: 7/255, blue: 63/255);
    static let bgColor = Color(red: 21/255, green: 21/255, blue: 21/255);
}

struct ContentView: View {
    
    @EnvironmentObject var userDataStore: UserDataStore;
    
    var body: some View {
        
        if userDataStore.token == "" {
            LoginView()
        } else {
            ProjectsView()
        }
    }
}
