//
//  CapturePreview.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct CapturePreview: View {
    @StateObject var model = CapturePreviewModel()
    @Binding var showPreview: Bool
    @State private var willDisapper = false
    @FocusState private var focusField: ReceiptInputView.Field?
    @State private var scale: CGFloat = 1
    @State private var headerText: String = Constants.headerText
    @State private var footerText: String = Constants.footerText
    @EnvironmentObject var receiptModel: ReceiptModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                model.selectedColor
                    .ignoresSafeArea()
                    .onTapGesture { focusField = nil }
                
                VStack {
                    headerView
                    
                    VStack {
                        ReceiptHeader(date: receiptModel.monthText) {
                            VStack {
                                TextField("", text: $headerText)
                                    .customFont(.DungGeunMo, size: 30)
                                    .focused($focusField, equals: .text)
                                    .multilineTextAlignment(.center)
                                
                                LineStroke()
                            }
                            .padding(.horizontal, 35)
                        }
                        .padding(.horizontal, 20)
                        
                        ReceiptList(items: receiptModel.receiptItems,
                                    didTapRow: { model.didSelectItem($0) })
                        
                        ReceiptFooter(totalCount: receiptModel.totalCount) {
                            VStack {
                                TextField("", text: $footerText)
                                    .customFont(.DungGeunMo, size: 20)
                                    .focused($focusField, equals: .text)
                                    .multilineTextAlignment(.center)
                                
                                LineStroke()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                    .background(Color.background)
                    .clipShape(ZigZag())
                    .scaleEffect(scale)
                    
                    Button(action: saveImage) { saveButton }
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.1)) {
                scale = 0.87
            }
//            focusField = .text
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
    
    private var headerView: some View {
        HStack {
            Button(action: { willDisapper = true }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .regular))
            }
            
            ColorPicker(selection: $model.selectedColor) {
                HStack {
                    Spacer()
                    Text("배경색 변경")
                        .customFont(.DungGeunMo, size: 19)
                }
            }
        }
        .foregroundColor(.black)
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(Color.background)
    }
    
    private var saveButton: some View {
        Color.black
            .ignoresSafeArea()
            .overlay(
                Text("이미지 저장")
                    .customFont(.DungGeunMo, size: 17)
                    .foregroundColor(.white)
            )
            .frame(height: 40)
    }
    
    private func saveImage() {
        let snapshot = snapshotView.takeScreenshot(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 500, height: 500))
        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
    }
    
    private var snapshotView: some View {
        ZStack {
            model.selectedColor
                .frame(width: 500, height: 500)
            
            VStack {
                ReceiptHeader(date: receiptModel.monthText) {
                    Text(headerText)
                }
                .padding(.horizontal, 20)
                
                ReceiptList(items: model.sectionModels)
                
                ReceiptFooter(totalCount: model.totalCount) {
                    Text(footerText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 15)
            .background(Color.background)
            .clipShape(ZigZag())
            .frame(width: 340, height: 450)
        }
        .ignoresSafeArea()
    }
}

final class CapturePreviewModel: ObservableObject {
    private let maxSelectableCount = 7
    @Published var selectedColor: Color = .white
    
    var selectedItems: [ReceiptItemModel] = []
    
    var totalCount: String { sectionModels.totalCount }
        
    var sectionModels: [ReceiptSectionModel] { selectedItems.mapToSectionModel() }
    
    func didSelectItem(_ item: ReceiptItemModel) {
        guard selectedItems.count <= maxSelectableCount else {
            print("## 7가지만 선택해라")
            return
        }
        selectedItems.append(item)
    }
}

struct CapturePreview_Previews: PreviewProvider {
    static var previews: some View {
        CapturePreview(showPreview: .constant(false))
    }
}
