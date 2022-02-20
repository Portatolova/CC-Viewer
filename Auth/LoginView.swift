import SwiftUI
import FloatingLabelTextFieldSwiftUI

struct LoginView: View {
    
    @State var email: String = "";
    @State var password: String = "";
    @EnvironmentObject var userDataStore: UserDataStore;
    
    func login() async {
        
        let data : [String: Any] = ["e": email, "p": password];
        
        await Request(urlstring: "https://api.codecollab.io/auth/login", method: .post, data: data, onComplete: { response in 
            print(response);
        }, onError: { error in 
            print(error);
        }, userDataStore: userDataStore)
        
    }
    
    var body: some View {
        ZStack {
            Color.bgColor
            VStack(alignment: .leading) {
                HStack {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                    Text("Login")
                        .bold()
                        .tracking(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(Font.custom("Montserrat", size: 40))
                }
                VStack() {
                    
                    FloatingLabelTextField($email, placeholder: "Email Address", editingChanged: {
                        (isChanged) in
                        print(isChanged)
                        print(email)
                    })
                        .titleColor(.white)
                        .selectedLineColor(.primaryColor)
                        .selectedTextColor(.white)
                        .selectedTitleColor(.primaryColor)
                        .textColor(.white)
                        .spaceBetweenTitleText(30)
                        .padding(.top, 50)
                        .frame(height: 40)
                    
                    FloatingLabelTextField($password, placeholder: "Password", editingChanged: {
                        (isChanged) in
                        print(isChanged)
                        print(email)
                    })
                        .isSecureTextEntry(true)
                        .titleColor(.white)
                        .selectedLineColor(.primaryColor)
                        .selectedTextColor(.white)
                        .selectedTitleColor(.primaryColor)
                        .textColor(.white)
                        .spaceBetweenTitleText(30)
                        .padding(.top, 70)
                        .frame(height: 40)
                }
                .padding()
                
                Button(action: {
                    Task {
                        await login()
                    }
                }, label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }).padding().frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            
        }
        .ignoresSafeArea()
    }
}
