//
//  CanvasView.swift
//  Fabric
//
//  Created by 李旭 on 2024/8/29.
//

import CoreGraphics
import SwiftUI

// 标注类型枚举
enum AnnotationType {
    case rect
    case text
    case arrow
}

// 标注数据结构
struct Annotation: Identifiable {
    let id = UUID()
    let type: AnnotationType
    var frame: CGRect
    var color: Color = .red
    var lineWidth: CGFloat = 2
    var text: String = ""
    var active: Bool = false
}

struct CanvasView: View {
    // 用于存储所有可拖动形状的数据
    @State private var annotations: [Annotation] = []

    @State private var mousePos = CGPoint.zero
    @State private var showCircle = false

    // 激活矩形
    @State private var isDragging = false
    @State private var dragStart = CGPoint.zero
    @State private var dragOffset = CGSize.zero

    @ObservedObject var state: EditorState

    var onSaveImage: (_ data: CGImage) -> Void

    // 修改为计算属性
    var showActiveFrame: Bool {
        return dragStart != .zero && dragOffset != .zero
    }

    var activeAnnotation: Annotation? {
        return annotations.first { $0.active } ?? annotations.last
    }

    // 计算属性：过滤出未激活的标注
    var canvasAnnotitions: [Annotation] {
        return annotations.filter { !$0.active }
    }

    var body: some View {
        ZStack {
            Canvas { context, size in

                // 绘制所有未标注
                for annotation in annotations {
                    switch annotation.type {
                    case .rect:
                        drawRect(context: context, annotation: annotation, size: size)
                    case .text:
                        drawText(context: context, annotation: annotation, size: size)
                    case .arrow:
                        drawArrow(context: context, annotation: annotation, size: size)
                    }
                }
            }
            .gesture(dragGesture) // 拖拽手势
            .onTapGesture(count: 1, coordinateSpace: .named("Canvas")) { value in // 单击
                logger.info("单击事件 - 坐标: (\(value.x), \(value.y))")
                // 调整坐标计算，考虑视图frame偏移
                mousePos = CGPoint(
                    x: value.x, // 直接使用点击坐标
                    y: value.y // 直接使用点击坐标
                )
                showCircle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showCircle = false
                    }
                }
            }

            // 激活的图形框区域
            if self.showActiveFrame {
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: abs(dragOffset.width), height: abs(dragOffset.height))
                    .position(x: dragStart.x + dragOffset.width/2, y: dragStart.y + dragOffset.height/2)
            }

            if let ann = activeAnnotation {
                ActiveAnnotation(annotation: ann, onUpdateFrame: { offset, size in
                    if let index = annotations.firstIndex(where: { $0.id == ann.id }) {
                        annotations[index].frame.origin.x += offset.width
                        annotations[index].frame.origin.y += offset.height
                        annotations[index].frame.size.width += size.width
                        annotations[index].frame.size.height += size.height
                    }
                })
                .position(x: ann.frame.midX, y: ann.frame.midY)
            }
            if showCircle {
                Circle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 50, height: 50)
                    .position(mousePos)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showCircle)
            }

        }.frame(width: 800, height: 600)
            .background(Color.gray.opacity(0.2))
            .coordinateSpace(.named("Canvas"))
            .onChange(of: state.saving) { _, newValue in
                if newValue {
                    saveImage()
                }
            }
    }

    func saveImage() {
        let renderer = ImageRenderer(content: self)
        if let cgImage = renderer.cgImage {
            onSaveImage(cgImage)
            // 保存
            logger.info("保存图片成功")
        } else {
            logger.error("保存图片失败")
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .named("Canvas")) // 允许零距离触发
            .onChanged { value in

                logger.debug("拖动中 - 坐标: (\(value.location.x), \(value.location.y))")
                // 按下时触发
                if !isDragging {
                    dragStart = value.startLocation
                    dragOffset = .zero
                    isDragging = true
                }

                // 实时更新位置
                dragOffset = value.translation
            }
            .onEnded { _ in
                self.annotations.append(Annotation(
                    type: .rect,
                    frame: CGRect(
                        x: dragStart.x,
                        y: dragStart.y,
                        width: dragOffset.width,
                        height: dragOffset.height
                    )
                ))
                dragStart = .zero
                dragOffset = .zero
                isDragging = false
            }
    }

    // 绘制矩形
    private func drawRect(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let path = Path(roundedRect: annotation.frame, cornerRadius: 0)
        context.stroke(path, with: .color(annotation.color), lineWidth: annotation.lineWidth)
    }

    // 绘制文字
    private func drawText(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let text = Text(annotation.text)
            .font(.system(size: 16))
            .foregroundColor(annotation.color)

        context.draw(text, at: CGPoint(
            x: annotation.frame.midX,
            y: annotation.frame.midY
        ), anchor: .center)
    }

    // 绘制箭头
    private func drawArrow(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let start = CGPoint(x: annotation.frame.minX, y: annotation.frame.minY)
        let end = CGPoint(x: annotation.frame.maxX, y: annotation.frame.maxY)

        // 绘制主线
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(annotation.color), lineWidth: annotation.lineWidth)

        // 绘制箭头头部
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 10

        let arrowPath = Path { path in
            path.move(to: end)
            path.addLine(to: CGPoint(
                x: end.x - arrowLength * cos(angle - .pi/6),
                y: end.y - arrowLength * sin(angle - .pi/6)
            ))

            path.addLine(to: CGPoint(
                x: end.x - arrowLength * cos(angle + .pi/6),
                y: end.y - arrowLength * sin(angle + .pi/6)
            ))

            path.closeSubpath()
        }

        context.fill(arrowPath, with: .color(annotation.color))
    }
}

struct ActiveAnnotation: View {
    @State var sartPoint: CGPoint = .zero
    @State var offset: CGSize = .zero
    @State var changeSize: CGSize = .zero

    var annotation: Annotation
    var onUpdateFrame: (CGSize, CGSize) -> Void

    // 计算矩形 8 个控制点的位置
    var controls: [CGPoint] {
        let frame = annotation.frame
        let width = frame.width + changeSize.width
        let height = frame.height + changeSize.height

        // 如果宽度或高度为 0，返回空数组
        guard width > 0, height > 0 else { return [] }

        // 按照顺时针顺序返回控制点:
        // 左上、右上、右下、左下
        // 上中、右中、下中、左中
        return [
            .init(x: 0, y: 0), // 左上
            .init(x: width/2, y: 0), // 上中
            .init(x: width, y: 0), // 右上
            .init(x: 0, y: height/2), // 左中
            .init(x: width, y: height/2), // 右中
            .init(x: 0, y: height), // 左下
            .init(x: width/2, y: height), // 下中
            .init(x: width, y: height), // 右下
        ]
    }

    var body: some View {
        Rectangle()
            .stroke(Color.black, lineWidth: 6)
            .fill(Color.black.opacity(0.01))
            .offset(offset)
            .highPriorityGesture(
                DragGesture(minimumDistance: 5.0, coordinateSpace: .named("Canvas"))
                    .onChanged { event in
                        // 记录拖动起始位置
                        if sartPoint == .zero {
                            sartPoint = event.startLocation
                        }
                        // 计算偏移量
                        offset = event.translation

//                        movingAnnotation(offset)

                        logger.info("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height)")
                    }
                    .onEnded { _ in
                        // 重置起始位置和偏移
                        movingAnnotation(offset)
                        sartPoint = .zero
                        offset = .zero
                    }
            )
            .frame(width: annotation.frame.width + changeSize.width, height: annotation.frame.height + changeSize.height)
//         绘制 8 个控制点圆环
            .overlay(
                ForEach(controls.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .onHover(perform: { hovering in
                            if hovering {
                                logger.info("鼠标悬停在控制点 \(index)")
                                setCursorbyIndex(index)
                            } else {
                                NSCursor.pop()
                            }
                        }
                        )
                        .position(controls[index])
                        .offset(offset)
                        .gesture(
                            DragGesture(minimumDistance: 3, coordinateSpace: .named("Canvas"))
                                .onChanged { event in
                                    logger.info("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height) 起点：\(event.startLocation.x), \(event.startLocation.y)")
                                    let size = sizeByIndexAndTrans(index, event.translation)
                                    // 计算新的宽高
                                    changeSize = size
                                }
                                .onEnded { event in
                                    let size = sizeByIndexAndTrans(index, event.translation)
                                    // 计算新的宽高
                                    resizeAnnotationFrame(size)
                                    changeSize = .zero
                                }
                        )
                }
            )
    }

    func movingAnnotation(_ offset: CGSize) {
        // 通过回调通知父视图更新frame
        onUpdateFrame(offset, .zero)
    }

    func resizeAnnotationFrame(_ size: CGSize) {
        onUpdateFrame(.zero, size)
    }

    func sizeByIndexAndTrans(_ index: Int, _ trans: CGSize) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch index {
        case 0, 2, 5, 7:
            width = trans.width
            height = trans.height
        case 1, 6:
            width = 0
            height = trans.height
        case 3, 4:
            width = trans.width
            height = 0
        default:
            width = 0
            height = 0
        }

        return CGSize(width: width, height: height)
    }

    func setCursorbyIndex(_ index: Int) {
        switch index {
        case 0:
            NSCursor.frameResize(position: .topLeft, directions: .all).push()
        case 1:
            NSCursor.frameResize(position: .top, directions: .all).push()
        case 2:
            NSCursor.frameResize(position: .topRight, directions: .all).push()
        case 3:
            NSCursor.frameResize(position: .left, directions: .all).push()
        case 4:
            NSCursor.frameResize(position: .right, directions: .all).push()
        case 5:
            NSCursor.frameResize(position: .bottomLeft, directions: .all).push()
        case 6:
            NSCursor.frameResize(position: .bottom, directions: .all).push()
        case 7:
            NSCursor.frameResize(position: .bottomRight, directions: .all).push()
        default:
            NSCursor.crosshair.push()
        }
    }
}
