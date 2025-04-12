# Fabric - SwiftUI图片标注工具

Fabric是一个基于SwiftUI的图片标注工具包，可以方便地在图片上添加矩形、箭头、文字和序号等标注。

## 功能特性

- 在图片上添加矩形标注
- 在图片上添加箭头标注
- 在图片上添加文字标注
- 在图片上添加序号标注
- 支持自定义标注样式
- 支持手势交互

## 安装

### Swift Package Manager

1. 在Xcode中打开你的项目
2. 选择"File" > "Add Packages..."
3. 输入仓库URL: `https://github.com/yourusername/Fabric.git`
4. 选择版本规则
5. 点击"Add Package"

## 使用示例

```swift
import Fabric
import SwiftUI

struct ContentView: View {
    var body: some View {
        CanvasView()
    }
}
```

## API文档

### CanvasView

主视图，用于显示和编辑标注。

### 标注类型

- `RectangleAnnotation`
- `ArrowAnnotation`
- `TextAnnotation`
- `NumberAnnotation`

## 贡献

欢迎提交Pull Request或Issue。

## 许可证

MIT