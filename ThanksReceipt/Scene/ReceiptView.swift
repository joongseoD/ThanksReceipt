//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model: ReceiptModel
    
    init(dependency: ReceiptModelDependency, service: ReceiptModelServicing) {
        _model = StateObject(wrappedValue: ReceiptModel(dependency: dependency, service: service))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    ToolBar(didTapSave: model.didTapSave,
                            didTapAdd: model.addItem)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    ReceiptContentView()
                        .padding(.horizontal, 7)
                        .padding(.bottom, 10)
                }
                .toast(message: $model.message)
                .alert(model: $model.alert)
                
                if let viewState = model.viewState {
                    switch viewState {
                    case let .monthPicker(dependency):
                        MonthPicker(
                            dependency: dependency,
                            listener: model
                        )
                        .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                    case let .input(dependency):
                        ReceiptInputView(
                            dependency: dependency,
                            listener: model
                        )
                        .backgroundBlur(onTapBackground: model.didTapBackgroundView)
                        .transition(.opacity.animation(.easeInOut))
                    case let .snapshotPreview(dependency):
                        ReceiptSnapshotPreview(
                            dependency: dependency,
                            closeSnapshotPreview: model.didTapBackgroundView
                        )
                    }
                }
            }
            .environmentObject(model)
        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let components = AppRootComponents()
        ReceiptView(
            dependency: components,
            service: ReceiptModelService(
                dependency: components
            )
        )
    }
}
