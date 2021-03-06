//
//  MonthPicker.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/21.
//

import SwiftUI

struct MonthPicker: View {
    @StateObject var model: MonthPickerModel
    @State private var scale: CGFloat = 0
    
    init(dependency: MonthPickerModelDependency, listener: MonthPickerModelListener?) {
        _model = StateObject(wrappedValue: MonthPickerModel(dependency: dependency, listener: listener))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            toolBar()
            
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
            
            Button(action: {
                scale = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    model.didTapComplete()
                }
            }) {
                Text("변경하기")
                    .customFont(.DungGeunMo, size: 18)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(7)
            }
        }
        .padding()
        .transition(.opacity.animation(.easeInOut))
        .scaleEffect(y: scale)
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 1.0), value: scale)
        .onAppear {
            Haptic.trigger()
            scale = 1
        }
    }
    
    private func toolBar() -> some View {
        HStack {
            Button(action: model.didTapAll) {
                HStack(spacing: 2) {
                    Text("all")
                        .customFont(.DungGeunMo, size: 18)
                    
                    Image(symbol: .next)
                        .font(.system(size: 10))
                        .offset(y: 1.5)
                }
            }
            .padding(.leading, 5)
            
            Spacer()
            
            Button(action: model.reset) {
                HStack(spacing: 2) {
                    Text("today")
                        .customFont(.DungGeunMo, size: 18)
                    
                    Image(symbol: .next)
                        .font(.system(size: 10))
                        .offset(y: 1.5)
                }
            }
            .padding(.trailing, 5)
        }
        .background(Color.white.opacity(0.01))
        .padding(.top, 15)
        .foregroundColor(.black)
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
            dependency: MonthPickerModelComponents(currentDate: .init(Date())),
            listener: nil
        )
    }
}
