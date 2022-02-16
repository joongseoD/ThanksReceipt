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
                                       components: [.date]) { _ in showDatePicker = false }
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
                .background(Color.background)
                .cornerRadius(7)
                .padding(.horizontal, 25)
                .clipShape(ZigZag())
                .position(x: proxy.frame(in: .global).width / 2, y: proxy.frame(in: .global).height / 2)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 0.15), value: scale)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                InputBottomToolBar(isEditMode: model.inputMode != .create,
                                   didTapDelete: model.deleteReceipt,
                                   didTapSave: model.saveReceipt)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 1
            }
            focusField = .text
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
        ReceiptInputView(dependency: ReceiptInputModelComponents(mode: .create), listener: nil)
    }
}
