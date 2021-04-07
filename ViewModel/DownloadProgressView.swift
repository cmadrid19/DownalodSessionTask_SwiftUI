//
//  DownloadProgressView.swift
//  DownloadTask
//
//  Created by Maxim Macari on 7/4/21.
//

import SwiftUI

struct DownloadProgressView: View {
    
    @Binding var progress: CGFloat
    @EnvironmentObject var downloadModel: DownloadTaskModel
    
    var body: some View {
        ZStack{
            Color.primary
                .opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 15){
                ZStack{
                    //Custom circle progressview
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    
                    ProgressShape(progress: progress)
                        .fill(Color.gray.opacity(0.45))
                        .rotationEffect(.init(degrees: -90))
                }
                .frame(width: 70, height: 70)
                
                //Cancel button
                Button(action: {
                    downloadModel.cancelTask()
                }, label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                })
                .padding(.top)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

//Custom progress shape
struct ProgressShape: Shape {
    
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            
            
            //radius = half the height
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: 35, startAngle: .zero, endAngle: .init(degrees: Double(progress * 360)), clockwise: false)
        }
    }
}
