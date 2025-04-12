//
//  MouseEventDemo.swift
//  Fabric
//
//  Created by 李旭 on 2025/4/10.
//

import SwiftUI

struct MouseEventDemo: View {
    @State private var cursorPosition = CGPoint.zero
    @State private var isDragging = false
    @State private var dragStart = CGPoint.zero
    @State private var dragOffset = CGSize.zero
    @State private var showCircle = false
    @State private var circlePosition = CGPoint.zero
    @State private var showRectangle = false
    @State private var rectangleFrame = CGRect.zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue.opacity(0.5))
                .onTapGesture(count: 1, coordinateSpace: .named("Fabric")) { value in // 单击
                    logger.info("单击事件 - 坐标: (\(value.x), \(value.y))")
                    // 调整坐标计算，考虑视图frame偏移
                    let adjustedPosition = CGPoint(
                        x: value.x, // 直接使用点击坐标
                        y: value.y // 直接使用点击坐标
                    )
                    circlePosition = adjustedPosition
                    showCircle = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            showCircle = false
                        }
                    }
                }
                // 核心事件处理
                .gesture(dragGesture) // 拖拽手势
                .frame(width: 800, height: 600)
                .background(Color.gray.opacity(0.2))
            
            if showCircle {
                Circle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 50, height: 50)
                    .position(circlePosition)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showCircle)
            }
            
            if showRectangle {
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: rectangleFrame.width, height: rectangleFrame.height)
                    .position(x: rectangleFrame.midX, y: rectangleFrame.midY)
            }
        }.background(Color.black)
            .frame(width: 800, height: 600)
            .coordinateSpace(name: "Fabric")
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .named("Fabric")) // 允许零距离触发
            .onChanged { value in
                   
//                logger.debug("拖动中 - 坐标: (\(value.location.x), \(value.location.y))")
                // 按下时触发
                if !isDragging {
                    dragStart = value.startLocation
                    isDragging = true
                    showRectangle = true
                    rectangleFrame = CGRect(x: CGFloat(dragStart.x), y: CGFloat(dragStart.y), width: CGFloat(value.translation.width), height: CGFloat(value.translation.height))
                }
                   
                // 更新矩形框大小
                let width = CGFloat(value.translation.width)
                let height = CGFloat(value.translation.height)
                rectangleFrame = CGRect(
                    x: dragStart.x,
                    y: dragStart.y,
                    width: width,
                    height: height
                )
                   
                // 实时更新位置
                dragOffset = value.translation
                cursorPosition = value.location
                
            }
    }
    

//    // 激活的图形框区域
//    private var activeAnnoView: some View {
//        Rectangle()
//            .fill(Color.blue.opacity(0.5))
//            // 核心事件处理
//            .gesture(
//                DragGesture(minimumDistance: 4, coordinateSpace: .named("Fabric"))
//                    .onChanged { event in
//                        logger.debug("拖动中 - 坐标: (\(event.location.x), \(event.location.y))")
//                    } // 拖拽手势
//                    .onEnded { _ in
//                        logger.info("拖动结束")
//                    }
//            )
//            .onTapGesture(count: 1, coordinateSpace: .named("Fabric")) { event in // 单击
//                logger.info("单击事件 - 坐标: (\(event.x), \(event.y))")
//            }
//    }
}
