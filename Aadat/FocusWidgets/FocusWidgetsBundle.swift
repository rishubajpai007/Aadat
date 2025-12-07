//
//  FocusWidgetsBundle.swift
//  FocusWidgets
//
//  Created by Rishu Bajpai on 07/12/25.
//

import WidgetKit
import SwiftUI

@main
struct FocusWidgetsBundle: WidgetBundle {
    var body: some Widget {
        FocusWidgets()
        FocusWidgetsControl()
        FocusWidgetsLiveActivity()
    }
}
