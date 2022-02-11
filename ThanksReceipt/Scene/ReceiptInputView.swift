//
//  ReceiptInputView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptInputView: View {
    @StateObject var model = ReceiptInputModel()
    @State private var showDatePicker = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if showDatePicker {
                    datePicker
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                } else {
                    Group {
                        HStack(spacing: 3) {
                            Text(model.dateString)
                            Image(systemName: "chevron.compact.down")
                                .resizable()
                                .frame(width: 10, height: 5)
                        }
                        .customFont(.DungGeunMo, size: 17)
                        .padding(.bottom, 7)
                        .onTapGesture {
                            showDatePicker = true
                        }
                        
                        Text("어떤 감사한 일이 있었나요?")
                            .customFont(.DungGeunMo, size: 19)
                            .padding(.bottom, 15)
                        
                        TextField("", text: $model.text)
                            .lineLimit(2)
                            .customFont(.DungGeunMo, size: 16)
                        
                        LineStroke()
                        
                        HStack {
                            Spacer()
                            
                            Text(model.textCount)
                                .customFont(.DungGeunMo, size: 15)
                        }
                        .padding(.bottom, 0)
                    }
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .padding(.top, 25)
            .padding(.bottom, 10)
            .padding(.horizontal, 25)
            .background(Color.gray)
            .cornerRadius(7)
            .padding(.horizontal, 25)
            .position(x: proxy.frame(in: .global).width / 2, y: proxy.frame(in: .global).height / 2)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button(action: model.saveReceipt) {
                            VStack(spacing: 2) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("Thanks?")
                                    .customFont(.DungGeunMo, size: 17)
                            }
                        }
                        .foregroundColor(.black)
                        .padding(.trailing, 25)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
                    .padding(.bottom, 10)
                }
            )
        }
    }
    
    var datePicker: some View {
        DatePicker("", selection: $model.date, in: ...Date(), displayedComponents: [.date])
            .datePickerStyle(GraphicalDatePickerStyle())
            .environment(\.locale, Locale(identifier: "Ko"))
            .labelsHidden()
            .accentColor(.black)
            .frame(maxHeight: 300)
            .onChange(of: model.date, perform: { newValue in
                showDatePicker = false
            })
    }
}

struct ReceiptInputView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptInputView()
    }
}
