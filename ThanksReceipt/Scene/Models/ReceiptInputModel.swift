//
//  ReceiptInputModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine

struct Haptic {
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

protocol ReceiptInputModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptInputModelComponents: ReceiptInputModelDependency {
    var provider: DataProviding = DataProvider()
    // TODO: - Scheduler
}

final class ReceiptInputModel: ObservableObject {
    @Published private(set) var errorMessage: String = ""
    @Published private(set) var textCount: String = ""
    @Published private(set) var dateString: String = ""
    @Published var date: Date = Date() {
        didSet {
            dateString = dateFormatter.string(from: date)
        }
    }
    @Published var text: String = "" {
        didSet {
            if text.count > maxCount {
                DispatchQueue.main.async {
                    self.text = String(self.text.prefix(self.maxCount))
                }
                Haptic.trigger(.medium)
            } else {
                Haptic.trigger(.soft)
            }

            textCount = "\(text.count)/\(maxCount)"
        }
    }
    
    private var provider: DataProviding
    private let maxCount: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "Ko")
        return formatter
    }()
    
    init(dependency: ReceiptInputModelDependency = ReceiptInputModelComponents()) {
        self.provider = dependency.provider
        textCount = "\(text.count)/\(maxCount)"
        dateString = dateFormatter.string(from: date)
    }
    
    func saveReceipt() {
        guard text.isEmpty == false else { return }
        let receiptItem = ReceiptItem(text: text, date: date)
        do {
            try provider.create(receiptItem: receiptItem)
        } catch {
            errorMessage = "생성 에러\n\(error.localizedDescription)"
        }
    }
    
}
