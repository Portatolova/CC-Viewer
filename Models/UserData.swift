import Foundation

struct UserData: Codable {
    let token: String;
    let id: String;
    let profilePic: String;
    let email: String;
    let uname: String;
    let dname: String;
    
    init(id: String, email: String, uname: String, dname: String, profilePic: String, token: String) {
        self.id = id;
        self.token = token;
        self.email = email;
        self.uname = uname;
        self.dname = dname;
        self.profilePic = profilePic;
    }
}

class UserDataStore: ObservableObject {
    @Published var token: String = ""
    @Published var id: String = ""
    @Published var profilePic: String = ""
    @Published var email: String = ""
    @Published var uname: String = ""
    @Published var dname: String = ""
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("user.data")
    }
    
    static func load(onComplete: @escaping (Result<UserData, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        onComplete(.success(UserData(id: "", email: "", uname: "", dname: "", profilePic: "", token: "")))
                    }
                    return
                }
                
                let userData = try JSONDecoder().decode(UserData.self, from: file.availableData)
                DispatchQueue.main.async {
                    onComplete(.success(userData))
                }
            } catch {
                DispatchQueue.main.async {
                    onComplete(.failure(error))
                }
            }
        }
    }
    
    func getUserData() -> UserData {
        return UserData(id: self.id, email: self.email, uname: self.uname, dname: self.dname, profilePic: self.profilePic, token: self.token);
    }
    
    func setUserData(userData: UserData) {
        self.id = userData.id;
        self.uname = userData.uname;
        self.email = userData.email;
        self.dname = userData.dname;
        self.token = userData.token;
        self.profilePic = userData.profilePic;
    }
    
    static func save(userData: UserData, onComplete: @escaping (Result<UserData, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(userData);
                let out = try fileURL();
                try data.write(to: out);
                DispatchQueue.main.async {
                    onComplete(.success(userData))
                }
            } catch {
                DispatchQueue.main.async {
                    onComplete(.failure(error))
                }
            }
        }
    }
}
