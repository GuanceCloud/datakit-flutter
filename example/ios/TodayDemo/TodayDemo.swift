//
//  TodayDemo.swift
//  TodayDemo
//
//  Created by hulilei on 2022/11/14.
//

import WidgetKit
import SwiftUI
import FTMobileSDK

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let httpEngine = HttpEngine()
        httpEngine.network { data, response, error in
            
        };
        FTExtensionManager.sharedInstance().logging("getTimeline", status: .statusInfo)
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct TodayDemoEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct TodayDemo: Widget {
    let kind: String = "TodayDemo"
    init() {
        let extensionConfig = FTExtensionConfig.init(groupIdentifier: "group.com.ft.sdk.flutter.agentExample.TodayDemo")
        extensionConfig.enableTrackAppCrash = true
        extensionConfig.enableSDKDebugLog = true
        extensionConfig.enableTracerAutoTrace = true
        extensionConfig.enableRUMAutoTraceResource = true
        FTExtensionManager.start(with: extensionConfig)
        FTExternalDataManager.shared().startView(withName: "TodayDemoEntryView")
    }
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayDemoEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TodayDemo_Previews: PreviewProvider {
    static var previews: some View {
        TodayDemoEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
