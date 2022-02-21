//
//  MonthPicker.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/21.
//

import SwiftUI

struct MonthPicker: View {
    @StateObject var model: MonthPickerModel
    
    init(dependency: MonthPickerModelDependency, listener: MonthPickerModelListener?) {
        _model = StateObject(wrappedValue: MonthPickerModel(dependency: dependency, listener: listener))
    }
    
    var body: some View {
        VStack {
            Group {
                switch model.state {
                case .month:
                    monthPicker()
                case .year:
                    yearPicker()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.receipt)
            .clipShape(ZigZag())
            .padding()
            
            Button(action: model.didTapComplete) {
                Text("완료")
                    .customFont(.DungGeunMo, size: 18)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(7)
                    .padding(.horizontal)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: model.state)
    }
    
    private func yearPicker() -> some View {
        VStack {
            toggleButton(model.selectedMonth, action: model.toggleViewState)
            
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10, alignment: .bottom), count: 4), spacing: 0) {
                ForEach(model.years, id: \.self) { year in
                    Button(action: { model.didSelectYear(year) }) {
                        Text(year)
                            .customFont(.DungGeunMo, size: 18)
                            .foregroundColor(year == model.selectedYear ? .white : .black)
                            .padding()
                            .background(year == model.selectedYear ? Color.black : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func monthPicker() -> some View {
        VStack {
            toggleButton(model.selectedYear, action: model.toggleViewState)
            
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 16, alignment: .bottom), count: 4), spacing: 0) {
                ForEach(model.months, id: \.self) { month in
                    Button(action: { model.didSelectMonth(month) }) {
                        Text(month)
                            .customFont(.DungGeunMo, size: 18)
                            .foregroundColor(model.selectedMonth == month ? .white : .black)
                            .padding()
                            .background(model.selectedMonth == month ? Color.black : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func toggleButton(_ text: String, action: @escaping (() -> Void)) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 2) {
                Text(text)
                    .customFont(.DungGeunMo, size: 22)
                
                Image(symbol: .next)
                    .font(.system(size: 10))
                    .offset(y: 1.5)
            }
            .offset(x: 2)
            .foregroundColor(.black)
        }
    }
}

struct MonthPicker_Previews: PreviewProvider {
    static var previews: some View {
        MonthPicker(
            dependency: MonthPickerModelComponents(currentDate: Date()),
            listener: nil
        )
    }
}
