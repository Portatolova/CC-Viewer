import SwiftUI
import MaterialDesignSymbol

struct ProjectsView: View {
    
    @State var projectsList: [String: Any] = [:];
    @State var foldersList: [String: String] = [:];
    @EnvironmentObject var userDataStore: UserDataStore;
    @Environment(\.openURL) var openURL;
    
    func getProjects() async {
        
        let data: [String: Any] = ["path": "/app"];
        
        await Request(urlstring: "https://api.codecollab.io/projs/get", method: .post, data: data, onComplete: { response in 
            if let folders = response["folders"] as? [String: String] {
                print(folders);
                self.foldersList = folders;
            }
            
            print(response["projects"])
            print("a")
            if let projects = response["projects"] as? [String: Any] {
                
                var projectsList: [String: Any] = [:]
                for (key, value) in projects {
                    let project = value as! [String: Any]
                    if let langNum = project["lang"] as? Int {
                        if langNum == 7 || langNum == 20 {
                            projectsList[key] = project
                        }
                    }
                }
                self.projectsList = projectsList;
            }
            
            
        }, onError: { error in 
            print(error)
        }, userDataStore: userDataStore);
        
    }
    
    func openWebpage(id: String) {
        let project = projectsList[id] as! [String: Any];
        let owner = project["owner"] as! [String: Any];
        UIApplication.shared.open(URL(string: "https://\(project["country"] as! String).cclb.me")!)
        print(id)
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
                    Text("Projects")
                        .bold()
                        .tracking(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(Font.custom("Montserrat", size: 35))
                }.padding(.leading)
                VStack() {
                    List {
                        Section(header: Text("Folders")) {
                            ForEach(foldersList.sorted(by: >), id: \.key) { key, value in
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 25))
                                    Text(value)
                                }.padding(.top, 10)
                                    .padding(.bottom, 10)
                            }
                        }
                        
                        Section(header: Text("HTML and Flask Projects")) {
                            ForEach(Array(projectsList.keys.sorted(by: >)), id: \.self) { key in
                                Button(action: { openWebpage(id: key) }) {
                                    HStack {
                                        Image(systemName: "link")
                                            .font(.system(size: 25))
                                        Text((projectsList[key]! as! [String: Any])["name"] as! String)
                                    }.padding(.top, 10)
                                        .padding(.bottom, 10)
                                }
                            }
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 400)
                    Text("Inside: /\(userDataStore.uname)/")
                        .foregroundColor(Color.gray)
                        .padding()
                }
            }.padding()
        }.ignoresSafeArea()
            .onAppear(perform: {
                Task {
                    await getProjects()
                }
            })
    }
}
