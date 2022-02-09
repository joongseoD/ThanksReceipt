//
//  ReceiptModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation
import Combine

protocol ReceiptModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptModelComponents: ReceiptModelDependency {
    var provider: DataProviding = DataProvider()
}

final class ReceiptModel: ObservableObject {
    @Published var receiptItems: [ReceiptItemModel] = []
    
    private var provider: DataProviding
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        
        setup()
    }
    
    private func setup() {
        receiptItems = [.init(text: "0", date: Date()),
                        .init(text: "0", date: Date())]
            .map { ReceiptItemModel(model: $0)}
    }
}

extension ReceiptModel {
    func saveAsImage() {
        
    }
    
    func addItem() {
        
    }
}

struct ReceiptItemModel {
    var date: String
    var text: String
    var count: String = ""
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d (E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
    init(date: String, text: String, count: String) {
        self.date = date
        self.text = text
        self.count = count
    }
    
    init(model: ReceiptItem) {
        self.text = model.text
        self.count = ""
        self.date = dateFormatter.string(from: model.date)
    }
    
    func setup() {
        
    }
}
