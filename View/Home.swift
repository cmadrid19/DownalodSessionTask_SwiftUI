//
//  Home.swift
//  DownloadTask
//
//  Created by Maxim Macari on 7/4/21.
//

import SwiftUI

struct Home: View {
    
    @StateObject var downloadModel = DownloadTaskModel()
    @State var urlText = ""
    
    var body: some View {
        NavigationView{
            VStack(spacing: 15){
                TextField("URL", text: $urlText)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: -5, y: -5)
                
                Button(action: {
                    downloadModel.startDownload(urlString: urlText)
                }, label: {
                    Text("Download URL")
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                    
                })
                .padding(.top)
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    ForEach(listVideos, id: \.self) { video in
                        Button(action: {
                            withAnimation(.spring()){
                                urlText = video
                            }
                        }, label: {
                            Text("\(video)")
                                .font(.caption2)
                                .foregroundColor(Color.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                                .background(downloadModel.checkFileExists(toDownload: video) ? Color.blue.opacity(0.4) : Color.gray.opacity(0.6))
                                .cornerRadius(15)
                        })
                    }
                })
                .frame(width: UIScreen.main.bounds.width, height: 200)
            }
            .padding()
            //Navigation bar title
            .navigationTitle("Download task")
            .navigationBarTitleDisplayMode(.automatic)
        }
        .preferredColorScheme(.light)
        //Alert
        .alert(isPresented: $downloadModel.showAlert, content: {
            Alert(title: Text("Error"), message: Text("\(downloadModel.alertMsg)"), dismissButton: .destructive(Text("Ok"), action: {
                
            }))
        })
        .overlay(
            ZStack{
                if downloadModel.showDownloadProgress {
                    DownloadProgressView(progress: $downloadModel.downloadProgress)
                        .environmentObject(downloadModel)
                }
            }
        )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
