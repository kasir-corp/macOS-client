//
//  ExportButton.swift
//  Natics
//
//  Created by Jackie Leonardy on 02/11/21.
//

import SwiftUI

struct SharingButton: View {
    let label: String
    let action: () -> ()
    
    var body: some View {
        Button(action: self.action, label: {
           Text(self.label)
                .font(.system(size: 11))
                .fontWeight(.medium)
        }).padding([.leading, .trailing], 8)
        .opacity(0.85)
    }
}

struct SharingButton_Previews: PreviewProvider {
    static var previews: some View {
        SharingButton(label: "Export All") {
            
        }
        
        SharingButton(label: "Share") {
            
        }
        
    }
}
