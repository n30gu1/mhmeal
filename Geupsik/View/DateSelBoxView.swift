//
//  DateSelBoxView.swift
//  Geupsik
//
//  Created by 박성헌 on 2021/07/11.
//  Copyright © 2021 n30gu1. All rights reserved.
//

import SwiftUI

struct DateSelBoxView: View {
    @State private var location: CGPoint = CGPoint(x: 0, y: 50)
    @State private var isOpened = false
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }
    }
    
    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
    
    @Binding var date: Date
    
    var body: some View {
        GeometryReader { geometry in
            let openedState = CGPoint(x: 0, y: geometry.size.height / 2)
            let closedState = CGPoint(x: 0, y: geometry.size.height * 1.22)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("BoxColor"))
                    .shadow(radius: 1)
                VStack {
                    TopNavigator(date: $date)
                        .padding()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)
                        .opacity(isOpened ? 1 : 0)
                    Button("Close") {
                        withAnimation(.spring()) {
                            isOpened = false
                            location = closedState
                        }
                    }
                }
            }
            .frame(width: isOpened ? geometry.size.width * 0.96 : geometry.size.width * 0.921, height: 400)
            .position(x: geometry.size.width / 2, y: location.y)
            .gesture(
                simpleDrag.simultaneously(with: fingerDrag)
                    .onEnded{ _ in
                    if location.y < geometry.size.height * 1.2 {
                            withAnimation(.spring()) {
                                location = openedState
                                isOpened = true
                            }
                        } else {
                            withAnimation(.spring()) {
                                location = closedState
                                isOpened = false
                            }
                        }
                    }
            )
            .onAppear {
                location = closedState
            }
        }
    }
}
