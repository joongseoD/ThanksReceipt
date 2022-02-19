//
//  CapturePreview.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct ReceiptSnapshotPreview: View {
    @StateObject var model = ReceiptSnapshotPreviewModel()
    @EnvironmentObject var receiptModel: ReceiptModel
    @Binding var showPreview: Bool
    @State private var willDisapper = false
    @State private var scale: CGFloat = 1
    @State private var headerText: String = Constants.headerText
    @State private var footerText: String = Constants.footerText
    @State private var headerCursor = true
    @State private var footerCursor = true
    @FocusState private var focusField: Field?
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                model.selectedColor
                    .ignoresSafeArea()
                    .onTapGesture { focusField = nil }
                
                VStack(spacing: 0) {
                    navigationBarView
                    
                    VStack {
                        ReceiptHeader(date: receiptModel.monthText) {
                            VStack {
                                TextField("", text: $headerText)
                                    .customFont(.DungGeunMo, size: 30)
                                    .focused($focusField, equals: .header)
                                    .multilineTextAlignment(.center)
                                    .cursor(show: headerCursor)
                                    .onTapGesture { headerCursor = false }
                                
                                LineStroke()
                            }
                            .padding(.horizontal, 30)
                            .frame(height: 35)
                        }
                        .padding(.horizontal, 20)
                        
                        ReceiptList(items: receiptModel.receiptItems,
                                    didTapSection: model.didSelectSection(_:),
                                    selectedSections: model.selectedSections)
                        
                        ReceiptFooter(totalCount: receiptModel.totalCount) {
                            VStack {
                                TextField("", text: $footerText)
                                    .customFont(.DungGeunMo, size: 20)
                                    .focused($focusField, equals: .footer)
                                    .multilineTextAlignment(.center)
                                    .cursor(show: footerCursor)
                                    .onTapGesture { footerCursor = false }
                                
                                LineStroke()
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 35)
                        }
                        .padding(.horizontal, 20)
                        .overlay(
                            HStack {
                                VStack {
                                    Text(model.selectedCountText)
                                        .customFont(.DungGeunMo, size: 25)
                                        .foregroundColor(.black.opacity(0.3))
                                    
                                    Spacer()
                                }
                                .padding(.leading, 15)
                                .padding(.top, 15)
                                
                                Spacer()
                            }
                        )
                    }
                    .padding(.vertical, 15)
                    .background(Color.background)
                    .clipShape(ZigZag())
                    .scaleEffect(scale)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
                    
                    ColorPallete(selection: $model.selectedColor,
                                 colorList: model.colorList)
                    
                    saveButton
                }
            }
        }
        .toast(message: $model.message, duration: 3, anchor: .center, fontSize: 12)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 0.87
            }
            model.onAppear()
        }
        .onChange(of: willDisapper) { newValue in
            guard newValue else { return }
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showPreview = false
            }
        }
        .transition(.opacity)
    }
    
    private var navigationBarView: some View {
        HStack {
            Button(action: { willDisapper = true }) {
                Image(symbol: .back)
                    .font(.system(size: 20, weight: .regular))
            }
            .frame(width: 50, height: 20, alignment: .leading)
            
            Spacer()
        }
        .foregroundColor(.black)
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(.white.opacity(0.25))
    }
}

extension ReceiptSnapshotPreview {
    private var saveButton: some View {
        Button(action: saveImage) {
            Color.black
                .ignoresSafeArea()
                .overlay(
                    Text("이미지 저장")
                        .customFont(.DungGeunMo, size: 17)
                        .foregroundColor(.white)
                )
                .frame(height: 40)
        }
    }
    
    private func saveImage() {
        let screenWidth = Constants.screenWidth
        let padding: CGFloat = 25
        let dummy = SnapshotDummy(backgroundColor: model.selectedColor,
                      date: receiptModel.monthText,
                      headerText: headerText,
                      receipts: model.selectedSections,
                      totalCount: model.totalCount,
                      footerText: footerText,
                      width: screenWidth - (padding * 2))
        
        let snapshotWidth = screenWidth - padding
        dummy.takeScreenshot(size: .init(width: snapshotWidth,
                                         height: snapshotWidth))
    }
}

extension ReceiptSnapshotPreview {
    enum Field {
        case header
        case footer
    }
}

struct ReceiptSnapshotPreview_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptSnapshotPreview(showPreview: .constant(false))
    }
}
