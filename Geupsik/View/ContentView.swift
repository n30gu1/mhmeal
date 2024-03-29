//
//  ContentView.swift
//  Geupsik
//
//  Created by 박성헌 on 2019/12/15.
//  Copyright © 2019 n30gu1. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @State var showCalendar = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Picker("", selection: $viewModel.mealType) {
                        Text("Breakfast").tag(MealType.breakfast)
                        Text("Lunch").tag(MealType.lunch)
                        Text("Dinner").tag(MealType.dinner)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    ForEach(viewModel.mealList.filter {
                        $0.MMEAL_SC_CODE == viewModel.mealType &&
                        $0.MLSV_YMD == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: viewModel.date)
                    }, id: \.MLSV_YMD) { meal in
                        MealListCell(meal: meal)
                            .listRowSeparator(.hidden)
                    }.padding()
                }
                List {
                    if viewModel.didLoad {
                        ForEach(viewModel.mealList.filter {
                            $0.MMEAL_SC_CODE == viewModel.mealType &&
                            $0.MLSV_YMD != Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: viewModel.date)
                        }, id: \.MLSV_YMD) { meal in
                            MealListCell(meal: meal)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        HStack {
                            Spacer()
                            ProgressView("Loading")
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                    
                    if !viewModel.isNotiPhone {
                        Rectangle()
                            .listRowSeparator(.hidden)
                            .foregroundColor(.clear)
                            .frame(height: 60)
                    }
                    
                }
                .listStyle(InsetListStyle())
                .refreshable {
                    viewModel.refresh()
                }
                .navigationBarTitle("Meals")
                .navigationBarItems(
                    leading: viewModel.isNotiPhone ? AnyView(showCalendarButton) : AnyView(EmptyView()),
                    trailing: Button(action: {
                        self.viewModel.showAllergyInfo.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
            }
            if !viewModel.isNotiPhone {
                DateSelBoxView(date: $viewModel.date)
                    .onChange(of: viewModel.date) { newDate in
                        viewModel.changeDate(newDate)
                    }
            }
        }
        .onAppear {
            viewModel.fetch()
        }
        .sheet(isPresented: $viewModel.showAllergyInfo) {
            AllergyInfoView()
        }
    }
    
    var calendarSelector: some View {
        DatePicker("", selection: $viewModel.date, displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .onChange(of: viewModel.date) { newDate in
                viewModel.changeDate(newDate)
            }
            .frame(width: 340)
            .padding()
    }
    
    var showCalendarButton: some View {
        Button(action: {
            withAnimation {
                self.showCalendar.toggle()
            }
        }) {
            Image(systemName: "calendar")
        }
        .popover(isPresented: $showCalendar, content: {
            calendarSelector
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.locale, Locale(identifier: "ko"))
            ContentView()
                .environment(\.colorScheme, .dark)
                .previewDevice("iPhone SE (2nd generation)")
            ContentView()
                .environment(\.locale, Locale(identifier: "ko"))
                .previewDevice("iPhone 15 Pro")
            ContentView()
                .environment(\.locale, Locale(identifier: "ko"))
                .previewDevice("iPhone 15 Pro Max")
            ContentView()
                .environment(\.locale, Locale(identifier: "ko"))
                .previewDevice("iPhone 8 Plus")
            ContentView()
                .environment(\.locale, Locale(identifier: "ko"))
                .previewDevice("iPad14,6")
//            ContentView()
//                .environment(\.locale, Locale(identifier: "ko"))
//                .previewDevice("iPad Pro (12.9-inch) (2nd generation)")
        }
    }
}
