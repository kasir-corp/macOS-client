//
//  RisingCasesTable.swift
//  Natics
//
//  Created by Christian Adiputra on 06/11/21.
//

import SwiftUI
import AppKit


struct RisingCasesTable: View {
    @ObservedObject var viewModel: TrendingRisingCaseViewModel
    
    var body: some View {
        VStack() {
            HStack {
                HStack(alignment: .center){
                    Text("Rising Cases")
                        .foregroundColor(Color.colorTheme.MCBlack)
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                    Button(action: {
                        print("Clicked")
                    }, label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .foregroundColor(Color.gray)
                    })
                        .frame(width: 18, height: 18)
                        .buttonStyle(.plain)
                        .foregroundColor(Color.colorTheme.MCDarkGrey)
                }
                Spacer()
                Button(action: {}){
                    Text("Export")
                }
                    .frame(width: 73, height: 28)
                    .buttonStyle(.plain)
                    .background(Color.colorTheme.MCDarkGreen)
                    .cornerRadius(4)
            }
            .padding(.horizontal,24)
            .padding(.top, 24)
            .padding(.bottom, 46)
            VStack(alignment: .leading, spacing: -15){
                RisingHeader()
                List {
//                    ForEach(viewModel.risingCasesTopTrending, id: \.id) { risingCase in
//                        RisingRow(risingCaseModel: risingCase, rowID: 1)
//                            .frame(height: 33)
//                    }
                    
                    ForEach(Array(viewModel.risingCasesTopTrending.enumerated()), id: \.offset) { index, element in
                        RisingRow(risingCaseModel: element, rowID: index+1)
                            .frame(height: 33)
                        
                    }
                }
            }
        }
        .background(Color.colorTheme.MCLightGrey)
        .frame(width: 610, height: 420)
        .border(Color.colorTheme.MCOutline, width: 1)
        .cornerRadius(4)
        .padding()
    }
}

struct RisingCasesTable_Previews: PreviewProvider {
    static var previews: some View {
        RisingCasesTable(viewModel: TrendingRisingCaseViewModel())
            
    }
}
