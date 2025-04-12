//
//  AppState.swift
//  Fabric
//
//  Created by 李旭 on 2025/4/12.
//

import Combine
import Foundation

// 标注控制器
class EditorState: ObservableObject {
    @Published var saving = false
    @Published var add = false
}
