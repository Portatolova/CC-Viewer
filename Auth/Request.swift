import SwiftUI

enum Methods: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    
    func getValue() -> String {
        return self.rawValue;
    }
}

func Request(urlstring: String, method: Methods, data: [String: Any], onComplete: @escaping ([String: Any]) -> Void, onError: @escaping (String) -> Void, userDataStore: UserDataStore) async {
    
    let url = URL(string: urlstring);
    let session = URLSession.shared;
    
    print(url)
    
    var request = URLRequest(url: url!);
    request.setValue("application/json", forHTTPHeaderField: "Content-Type");
    request.setValue("application/json", forHTTPHeaderField: "Accept");
    request.httpMethod = method.getValue();
    
    if userDataStore.token != "" {
        if let cookies = session.configuration.httpCookieStorage {
            let name = HTTPCookiePropertyKey("name");
            let value = HTTPCookiePropertyKey("value");
            
            if let cookie = HTTPCookie(properties: [name: "token", value: userDataStore.token]) {
                cookies.setCookie(cookie);
            }
        }
    }
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted);
    } catch let error {
        print(error.localizedDescription);
        return;
    }
    
    let task = session.dataTask(with: request) { data, response, error in
        
        if let error = error {
            onError("POST Request Error: \(error.localizedDescription)");
            return;
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else {
            print((response as? HTTPURLResponse)!.statusCode)
            onError("Invalid Response received frm server.");
            return;
        }
        
        print(httpResponse.statusCode)
        
        guard let responseData = data else {
            onError("nil data received from the server");
            return;
        }
        
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                print(urlstring)
                guard let cookieStorage = session.configuration.httpCookieStorage else {
                    onError("CookieStorage is nil");
                    return;
                }
                
                print("A")
                
                var cookie: HTTPCookie = HTTPCookie();
                
                guard let cookies = cookieStorage.cookies else {
                    onError("Cookie does not exist");
                    return;
                }
                
                if cookies.indices.contains(0) {
                    cookie = cookies[0]
                }
                
                print("B")
                
                if urlstring.contains("/auth/login") || urlstring.contains("/auth/verifyToken") {
                    
                    var ui = jsonResponse;
                    
                    if jsonResponse["ui"] != nil {
                        ui = jsonResponse["ui"] as! [String : Any];
                    }
                    
                    if let isValid = jsonResponse["isValid"] as? Int {
                        if isValid == 0 {
                            userDataStore.token = "";
                            userDataStore.uname = "";
                            userDataStore.email = "";
                            userDataStore.dname = "";
                            print("Invalid Token!")
                            UserDataStore.save(userData: userDataStore.getUserData(), onComplete: { result in
                                switch result {
                                case .failure(let error):
                                    print(error)
                                case .success(_):
                                    print("UserData stored successfully!")
                                }
                            });
                            onComplete(jsonResponse)
                        }
                    }
                    
                    userDataStore.token = cookie.value;
                    userDataStore.uname = ui["uname"] as? String ?? "";
                    userDataStore.dname = ui["dname"] as? String ?? "";
                    userDataStore.email = ui["email"] as? String ?? "";
                    UserDataStore.save(userData: userDataStore.getUserData(), onComplete: { result in 
                        switch result {
                            case .failure(let error):
                            print(error)
                            case .success(_):
                            print("UserData stored successfully!")
                        }
                    })
                }
                
                onComplete(jsonResponse);
            } else {
                onError("data maybe corrupted or in wrong format");
                throw URLError(.badServerResponse);
            }
        } catch let error {
            print(error)
            onError(error.localizedDescription);
        }
    }
    task.resume()
}
