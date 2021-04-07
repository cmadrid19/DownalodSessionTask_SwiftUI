//
//  DownloadTaskModel.swift
//  DownloadTask
//
//  Created by Maxim Macari on 7/4/21.
//

import SwiftUI

class DownloadTaskModel: NSObject,ObservableObject, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {

    @Published var downloadURL: URL!
    
    //Alert
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    
    //Saving download task rference for cancelling
    @Published var downloadtaskSession: URLSessionDownloadTask!
    
    //Progress
    @Published var downloadProgress: CGFloat = 0
    
    //Show progressView
    @Published var showDownloadProgress: Bool = false
    
    @Published var downloadedFiles: [String] = []
    
    //download function
    func startDownload(urlString: String) {
        
        guard let url = URL(string: urlString) else {
            reportError(error: "Invalid url.")
            return
        }
        
        //preventing downloading the same efile again
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if FileManager.default.fileExists(atPath: directoryPath.appendingPathComponent(url.lastPathComponent).path){
            print("There is a copy of this video already downloaded")
            downloadedFiles.append(url.lastPathComponent)
            //Presnting the file
            let controller = UIDocumentInteractionController(url: directoryPath.appendingPathComponent(url.lastPathComponent))
            
            //it nds a delegate
            controller.delegate = self
            controller.presentPreview(animated: true)
        }else{
            
            downloadProgress = 0
            withAnimation{
                showDownloadProgress = true
            }
            
            //Download task
            //since we are going to get the progress as well as the location of the file, we use delegate
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            downloadtaskSession = session.downloadTask(with: url)
            downloadtaskSession.resume()
            
            
        }
    }
    
    //report error function
    func reportError(error: String) {
        alertMsg = error
        showAlert.toggle()
    }
    
    //Implmnting urlSession
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //since it will download it as temporary data, we ned to save it.
        
        guard let url = downloadTask.originalRequest?.url else{
            DispatchQueue.main.async {
                self.reportError(error: "Something went wrong please try again or later.")
            }
            return
        }
        
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        //creating storing file
        //destinaiton url
        let destinationURL = directoryPath.appendingPathComponent(url.lastPathComponent)
        
        //if file already exists, remove it
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            //copying temp file to directory
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            // if success
            print("success, saving the video")
            DispatchQueue.main.async {
                withAnimation{
                    self.showDownloadProgress = false
                }
                //Presnting the file
                let controller = UIDocumentInteractionController(url: destinationURL)
                
                //it nds a delegate
                controller.delegate = self
                controller.presentPreview(animated: true)
            }
        }
        catch{
            DispatchQueue.main.async {
                self.reportError(error: "Please try again or later.")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //getting progress
        let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        //download is on BG Thread and UI updatees in th main thread.
        DispatchQueue.main.async {
            self.downloadProgress = progress
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                withAnimation{
                    self.showDownloadProgress = false
                }
                self.reportError(error: error.localizedDescription)
                return
            }
        }
    }
    
    //cancel task
    func cancelTask(){
        if let task = downloadtaskSession, task.state == .running {
            //cancelling
            downloadtaskSession.cancel()
            //closing view
            withAnimation{
                self.showDownloadProgress = false
            }
        }
    }
    
    
    //sub functions for presenting video
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    //do any of the files donloaded exists in this string
    func checkFileExists(toDownload download: String) -> Bool{
        return downloadedFiles.contains(where: download.contains)
    }
}
