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
    @State private var headerCursor = true
    @State private var footerCursor = true
    @State private var snapshotScale: CGFloat = 1.23
    @State private var snapshotOpacity: CGFloat = 1.0
    @FocusState private var focusField: Field?
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                model.selectedColor
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: model.selectedColor)
                    .onTapGesture { focusField = nil }
                
                VStack(spacing: 0) {
                    navigationBarView
                        .toast(message: $model.selectedCountText, animation: false, fontSize: 13)
                    
                    VStack {
                        ReceiptHeader(date: receiptModel.monthText) {
                            VStack {
                                TextField("", text: $model.headerText)
                                    .submitLabel(.done)
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
                                TextField("", text: $model.footerText)
                                    .submitLabel(.done)
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
                    }
                    .padding(.vertical, 15)
                    .background(Color.receipt)
                    .clipShape(ZigZag())
                    .scaleEffect(scale)
                    .opacity(scale)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
                    
                    ColorPallete(selection: $model.selectedColor,
                                 colorList: model.colorList)
                    
                    saveButton
                }
                
                if let snapshotImage = model.snapshotImage {
                    Image(uiImage: snapshotImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: proxy.size.width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .fixedSize(horizontal: true, vertical: false)
                        .scaleEffect(snapshotScale)
                        .overlay(Color.white.opacity(snapshotOpacity))
                        .background(
                            ZStack {
                                Color.white
                                model.selectedColor
                            }
                        )
                        .onChange(of: snapshotScale) { newValue in
                            guard newValue == 1 else { return }
                            Haptic.trigger(.rigid)
                        }
                }
            }
        }
        .toast(message: $model.message, duration: 3, anchor: .center, fontSize: 12)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.15)) {
                scale = 0.87
            }
            model.onAppear()
        }
        .onChange(of: willDisapper) { newValue in
            guard newValue else { return }
            withAnimation(Animation.easeInOut(duration: 0.15)) {
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showPreview = false
            }
        }
        .onChange(of: model.snapshotImage, perform: { newValue in
            withAnimation(.easeInOut(duration: 0.15)) {
                snapshotScale = newValue != nil ? 1 : 2
            }
            withAnimation(.linear(duration: 0.5)) {
                snapshotOpacity = newValue != nil ? 0 : 1
            }
        })
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
    
    private var saveButton: some View {
        Button(action: { model.saveImage(receiptModel.monthText) }) {
            Color.black
                .ignoresSafeArea()
                .overlay(
                    Text("영수증 출력하기")
                        .customFont(.DungGeunMo, size: 17)
                        .foregroundColor(model.receiptsEmpty ? .gray : .white)
                )
                .frame(height: 50)
        }
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
