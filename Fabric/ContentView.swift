//
//  ContentView.swift
//  Fabric
//
//  Created by 李旭 on 2025/4/12.
//

import SwiftUI

struct ContentView: View {
    @StateObject var editorState = EditorState()
    var body: some View {
        VStack {
            HStack {
                Button("Save") {
                    editorState.saving = true
                }
            }
            CanvasView(state: editorState) { data in
                onSave(data)
                editorState.saving = false
                logger.info("点击了:  save")
            }
        }
    }

    func onSave(_ data: CGImage) {
        let bitmap = NSBitmapImageRep(cgImage: data)
        let pngData = bitmap.representation(using: .png, properties: [:])

        if let data = pngData {
            let pb = NSPasteboard.general
            pb.clearContents()

            let saveRes = pb.setData(data, forType: .png)
            print("save data in pastboard is \(saveRes)")
        }
    }
}

#Preview {
    ContentView()
}
