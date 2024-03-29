//
//  mealWidget.swift
//  mealWidget
//
//  Created by 박성헌 on 2020/10/17.
//  Copyright © 2020 n30gu1. All rights reserved.
//

import WidgetKit
import SwiftUI
import ActivityKit

// MARK: Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MealEntry {
        MealEntry(
            date: Date(),
            meal: [
                Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
            ],
            mealType: [MealType.lunch, MealType.breakfast]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MealEntry) -> ()) {
        let entry = MealEntry(
            date: Date(),
            meal: [
                Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
            ],
            mealType: [MealType.lunch, MealType.breakfast]
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let mealType: [MealType] = {
            let zero = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            let breakfast = Calendar.current.date(bySettingHour: 7, minute: 00, second: 00, of: Date())!
            let lunch = Calendar.current.date(bySettingHour: 13, minute: 00, second: 00, of: Date())!
            let dinner = Calendar.current.date(bySettingHour: 19, minute: 00, second: 00, of: Date())!
            
            switch Date() {
            case zero...breakfast:
                return [MealType.breakfast, MealType.lunch]
            case breakfast...lunch:
                return [MealType.lunch, MealType.dinner]
            case lunch...dinner:
                return [MealType.dinner, MealType.breakfast]
            default:
                return [MealType.breakfast, MealType.lunch]
            }
        }()
        
        let isNextDay: [Bool] = {
            let zero = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            let lunch = Calendar.current.date(bySettingHour: 13, minute: 00, second: 00, of: Date())!
            let dinner = Calendar.current.date(bySettingHour: 19, minute: 00, second: 00, of: Date())!
            
            switch Date() {
            case zero...lunch:
                return [false, false]
            case lunch...dinner:
                return [false, true]
            default:
                return [true, true]
            }
        }()
        
        Task {
            let meal = await fetchMeal(mealType: mealType, isNextDay: isNextDay)
            
            var date = Date()
            
            if isNextDay[0] {
                date = date.addingTimeInterval(86400)
            }
            
            let entry = MealEntry(date: date, meal: meal, mealType: mealType)
            
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
}

// MARK: Entry

struct MealEntry: TimelineEntry {
    var date: Date
    let meal: [Meal]
    let mealType: [MealType]
}

// MARK: Entry View

struct mealWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        if widgetFamily == .systemSmall {
            SystemSmallWidgetView(entry: entry)
        } else if widgetFamily == .systemMedium {
            SystemMediumWidgetView(entry: entry)
        } else {
            Text("error")
        }
    }
}

struct SystemSmallWidgetView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .frame(height: 74)
                    .foregroundColor(Color("BoxColor"))
                    .shadow(radius: 2)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(entry.date.formatShort())
                        .fontWeight(.light)
                    Spacer()
                }
                Text(LocalizedStringKey(entry.mealType[0].rawValue))
                    .font(.title)
                    .fontWeight(.regular)
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    if entry.meal.count != 0 {
                        ForEach(entry.meal[0].DDISH_NM.prefix(3), id: \.self) {
                            Text($0)
                                .font(.system(size: 16))
                        }
                    } else {
                        Text("Loading")
                    }
                }
            }
            .padding(13)
        }
        .background(Color("WidgetBackground"))
    }
}

struct SystemMediumWidgetView : View {
    var entry: Provider.Entry
    
    let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()
    let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Rectangle()
                        .frame(height: 30)
                        .foregroundColor(Color("BoxColor"))
                        .shadow(radius: 2)
                    Spacer()
                }
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(monthFormatter.string(from: entry.date))
                            .font(.system(size: 14))
                            .padding(.bottom, 4)
                        Text(dayFormatter.string(from: entry.date))
                            .font(.system(size: 50))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(LocalizedStringKey(entry.mealType[0].rawValue))
                            .font(.system(size: 14))
                            .bold()
                            .padding(.bottom, 12)
                        ForEach(entry.meal[0].DDISH_NM.prefix(6), id: \.self) {
                            Text($0)
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(LocalizedStringKey(entry.mealType[1].rawValue))
                            .font(.system(size: 14))
                            .bold()
                            .padding(.bottom, 12)
                        ForEach(entry.meal[1].DDISH_NM.prefix(6), id: \.self) {
                            Text($0)
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .padding(.horizontal, 8)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: Widget

@main
struct mealWidget: Widget {
    let kind: String = "mealWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                mealWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color("WidgetBackground")
                    }
            } else {
                mealWidgetEntryView(entry: entry)
                    .background(Color("WidgetBackground"))
            }
        }
        .contentMarginsDisabledIfAvailable()
        .configurationDisplayName(LocalizedStringKey("Today's meal"))
        .description(LocalizedStringKey("Inform today's meal."))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: Entry View Preview

struct mealWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            mealWidgetEntryView(entry: MealEntry(
                date: Date(),
                meal: [
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
                ],
                mealType: [MealType.lunch, MealType.breakfast]
            ))
            .preferredColorScheme(.light)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            mealWidgetEntryView(entry: MealEntry(
                date: Date(),
                meal: [
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
                ],
                mealType: [MealType.lunch, MealType.breakfast]
            ))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
        
        Group {
            mealWidgetEntryView(entry: MealEntry(
                date: Date(),
                meal: [
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
                ],
                mealType: [MealType.lunch, MealType.breakfast]
            ))
            .preferredColorScheme(.light)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            mealWidgetEntryView(entry: MealEntry(
                date: Date(),
                meal: [
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"]),
                    Meal(meal: ["친환경차수수밥", "순댓국", "돈육고추장불고기", "상추겉절이", "메기순살강정", "배추김치"])
                ],
                mealType: [MealType.lunch, MealType.breakfast]
            ))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}
