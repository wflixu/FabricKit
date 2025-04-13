//
//  Model.swift
//  Fabric
//
//  Created by 李旭 on 2025/4/13.
//

import Foundation
import SwiftUI

// 可编辑形状的控制点
enum CPoint {
    case topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight

    var frameResizePosition: NSCursor.FrameResizePosition {
        switch self {
            case .topLeft:
                return NSCursor.FrameResizePosition.topLeft
            case .top:
                return NSCursor.FrameResizePosition.top
            case .topRight:
                return NSCursor.FrameResizePosition.topRight
            case .left:
                return NSCursor.FrameResizePosition.left
            case .right:
                return NSCursor.FrameResizePosition.right
            case .bottomLeft:
                return NSCursor.FrameResizePosition.bottomLeft
            case .bottom:
                return NSCursor.FrameResizePosition.bottom
            case .bottomRight:
                return NSCursor.FrameResizePosition.bottomRight
        }
    }

    func position(_ targetSize: CGSize) -> CGPoint {
        switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .top:
                return CGPoint(x: targetSize.width / 2, y: 0)
            case .topRight:
                return CGPoint(x: targetSize.width, y: 0)
            case .left:
                return CGPoint(x: 0, y: targetSize.height / 2)
            case .right:
                return CGPoint(x: targetSize.width, y: targetSize.height / 2)
            case .bottomLeft:
                return CGPoint(x: 0, y: targetSize.height)
            case .bottom:
                return CGPoint(x: targetSize.width / 2, y: targetSize.height)
            case .bottomRight:
                return CGPoint(x: targetSize.width, y: targetSize.height)
        }
    }

    func getViewOffset(_ trans: CGSize) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch self {
            case .bottomRight, .bottomLeft, .topLeft, .topRight:
                width = trans.width / 2
                height = trans.height / 2
            case .top, .bottom:
                width = 0
                height = trans.height / 2
            case .left, .right:
                width = trans.width / 2
                height = 0
        }

        return CGSize(width: width, height: height)
    }

    func getOriginTrans(_ trans: CGSize) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch self {
            case .bottomRight, .bottom, .right:
                width = 0
                height = 0
            case .topLeft, .top:
                width = trans.width
                height = trans.height
            case .topRight:
                width = 0
                height = trans.height
            case .bottomLeft, .left:
                width = trans.width
                height = 0
        }

        return CGSize(width: width, height: height)
    }

    func getTargetChangedSize(_ trans: CGSize) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch self {
            case .bottomRight:
                width = trans.width
                height = trans.height
            case .topLeft:
                width = -trans.width
                height = -trans.height
            case .top:
                width = 0
                height = -trans.height
            case .topRight:
                width = trans.width
                height = -trans.height
            case .left:
                width = -trans.width
                height = 0
            case .right:
                width = trans.width
                height = 0
            case .bottomLeft:
                width = -trans.width
                height = trans.height
            case .bottom:
                width = 0
                height = trans.height
        }

        return CGSize(width: width, height: height)
    }

    static func allCases() -> [CPoint] {
        return [.topLeft, .top, .topRight, .left, .right, .bottomLeft, .bottom, .bottomRight]
    }
}
