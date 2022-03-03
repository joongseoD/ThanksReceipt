//
//  ReceiptInputView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptInputView: View {
    @StateObject private var model: ReceiptInputModel
    @State private var showDatePicker = false
    @State private var scale: CGFloat = 0.5
    @FocusState private var focusField: Field?

    init(dependency: ReceiptInputModelDependency, listener: ReceiptInputModelListener?) {
        _model = StateObject(wrappedValue: ReceiptInputModel(dependency: dependency, listener: listener))
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack {
                    if showDatePicker {
                        DatePickerView(selection: $model.date,
                                       pickerStyle: GraphicalDatePickerStyle(),
                                       components: [.date]) { _ in
                            showDatePicker = false
                            focusField = .text
                        }
                    } else {
                        Group {
                            HStack(spacing: 3) {
                                Text(model.dateString)
                                Image(symbol: .selectDown)
                                    .resizable()
                                    .frame(width: 10, height: 5)
                            }
                            .customFont(.DungGeunMo, size: 17)
                            .padding(.bottom, 7)
                            .onTapGesture {
                                focusField = nil
                                showDatePicker = true
                            }
                            
                            Text("어떤 감사한 일이 있었나요?")
                                .customFont(.DungGeunMo, size: 19)
                                .padding(.bottom, 15)
                            
                            TextField("", text: $model.text)
                                .submitLabel(.done)
                                .customFont(.DungGeunMo, size: 16)
                                .focused($focusField, equals: .text)
                            
                            LineStroke()
                            
                            HStack {
                                Spacer()
                                
                                Text(model.textCount)
                                    .customFont(.DungGeunMo, size: 15)
                            }
                            .padding(.bottom, 7)
                        }
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 10)
                .padding(.horizontal, 25)
                .background(Color.receipt)
                .cornerRadius(7)
                .padding(.horizontal, 25)
                .clipShape(ZigZag())
                .position(x: proxy.frame(in: .global).width / 2, y: proxy.frame(in: .global).height / 2)
                .scaleEffect(scale)
                .animation(.spring(response: 0.19, dampingFraction: 0.7, blendDuration: 1.0))
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
                
                InputBottomToolBar(isEditMode: model.inputMode != .create,
                                   didTapDelete: model.deleteReceipt,
                                   didTapSave: model.saveReceipt)
                    .background(Color.white.opacity(0.01))
                    .padding(.top, 20)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .toast(message: $model.message, anchor: .center)
            .alert(model: $model.alert)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 1
            }
            focusField = .text
            Haptic.trigger()
        }
        .onDisappear {
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 0
            }
        }
    }
}

extension ReceiptInputView {
    enum Field {
        case text
    }
}

struct ReceiptInputView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptInputView(
            dependency: ReceiptInputModelComponents(
                dependency: AppRootComponents(),
                mode: .create
            ),
            listener: nil
        )
    }
}
