//
//  MonthPickerModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/21.
//

import SwiftUI
import Combine

protocol MonthPickerModelListener: AnyObject {
    func didSelectDate(_ date: Date?)
}

protocol MonthPickerModelDependency {
    var currentDate: CurrentValueSubject<Date, Never> { get }
}

final class MonthPickerModel: ObservableObject {
    @Published var state: ViewState = .month
    @Published var selectedMonth: String = ""
    @Published var months: [String] = []
    @Published var selectedYear: String = ""
    @Published var years: [String] = []
    
    private let currentDate: CurrentValueSubject<Date, Never>
    private let yearFormatter = DateFormatter(format: .year)
    private let monthFormatter = DateFormatter(format: .shortMonth)
    private var cancellables = Set<AnyCancellable>()
    
    private weak var listener: MonthPickerModelListener?
    
    init(dependency: MonthPickerModelDependency, listener: MonthPickerModelListener?) {
        self.currentDate = dependency.currentDate
        self.listener = listener
        
        currentDate
            .compactMap { [weak self] currentDate -> (year: String, month: String)? in
                guard let self = self else { return nil }
                return (self.yearFormatter.string(from: currentDate), self.monthFormatter.string(from: currentDate))
            }
            .sink { [weak self] in
                Haptic.trigger()
                self?.selectedYear = $0.year
                self?.selectedMonth = $0.month
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    func didSelectMonth(_ month: String) {
        monthFormatter.defaultDate = currentDate.value
        currentDate.send(monthFormatter.date(from: month) ?? Date())
    }
    
    func didSelectYear(_ year: String) {
        yearFormatter.defaultDate = currentDate.value
        currentDate.send(yearFormatter.date(from: year) ?? Date())
    }
    
    func reset() {
        Haptic.trigger()
        listener?.didSelectDate(Date())
    }
    
    func didTapAll() {
        Haptic.trigger()
        listener?.didSelectDate(nil)
    }
    
    func didTapComplete() {
        Haptic.trigger()
        listener?.didSelectDate(currentDate.value)
    }
    
    func toggleViewState() {
        Haptic.trigger()
        state = state == .month ? .year : .month
    }
    
    func didAppear() {
        setupMonth()
        setupYear()
    }
    
    private func setupMonth() {
        months = Array((1...12))
            .map { "\($0)" }
            .compactMap {
                let formatter = DateFormatter()
                formatter.dateFormat = "M"
                return formatter.date(from: $0)
            }
            .compactMap { monthFormatter.string(from: $0) }
    }
    
    private func setupYear() {
        years = Array((0..<12))
            .compactMap { Calendar.current.date(byAdding: .year, value: $0 * -1, to: Date()) }
            .compactMap { yearFormatter.string(from: $0) }
    }
}

extension MonthPickerModel {
    enum ViewState {
        case month
        case year
    }
}
