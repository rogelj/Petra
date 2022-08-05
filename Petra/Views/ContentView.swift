/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct AlertMessage: Identifiable {
  let id = UUID()
  var title: Text
  var message: Text
  var actionButton: Alert.Button?
  var cancelButton: Alert.Button = .default(Text("OK"))
}

struct PickerInfo: Identifiable {
  let id = UUID()
  let picker: PickerView
}

struct ContentView: View {
  @State private var image: UIImage?
  @State private var styleImage: UIImage?
  @State private var stylizedImage: UIImage?
  @State private var processing = false
  @State private var showAlertMessage: AlertMessage?
  @State private var showImagePicker: PickerInfo?

  var body: some View {
    VStack {
      Text("PETRA")
        .font(.title)
      Spacer()
      Button(action: {
        if self.stylizedImage != nil {
          self.showAlertMessage = .init(
            title: Text("Choose new image?"),
            message: Text("This will clear the existing image!"),
            actionButton: .destructive(
              Text("Continue")) {
                self.stylizedImage = nil
                self.image = nil
                self.showImagePicker = PickerInfo(picker: PickerView(selectedImage: self.$image))
            },
            cancelButton: .cancel(Text("Cancel")))
        } else {
          self.showImagePicker = PickerInfo(picker: PickerView(selectedImage: self.$image))
        }
      }, label: {
        if let anImage = self.stylizedImage ?? self.image {
          Image(uiImage: anImage)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: ContentMode.fit)
            .border(.blue, width: 3)
        } else {
          Text("Choose a Pet Image")
            .font(.callout)
            .foregroundColor(.blue)
            .padding()
            .cornerRadius(10)
            .border(.blue, width: 3)
        }
      })
      Spacer()
      Text("Choose Style to Apply")
      Button(action: {
        self.showImagePicker = PickerInfo(picker: PickerView(selectedImage: self.$styleImage))
      }, label: {
        Image(uiImage: styleImage ?? UIImage(named: Constants.Path.presetStyle1) ?? UIImage())
          .resizable()
          .frame(width: 100, height: 100, alignment: .center)
          .scaledToFit()
          .aspectRatio(contentMode: ContentMode.fit)
          .cornerRadius(10)
          .border(.blue, width: 3)
      })
      Button(action: {
        guard let petImage = image, let styleImage = styleImage ?? UIImage(named: Constants.Path.presetStyle1) else {
          self.showAlertMessage = .init(
            title: Text("Error"),
            message: Text("You need to choose a Pet photo before applying the style!"),
            actionButton: nil,
            cancelButton: .default(Text("OK")))
          return
        }
        if !self.processing {
          self.processing = true
          MLStyleTransferHelper.shared.applyStyle(styleImage, on: petImage) { stylizedImage in
            processing = false
            self.stylizedImage = stylizedImage
          }
        }
      }, label: {
        Text(self.processing ? "Processing..." : "Apply Style!")
          .padding(EdgeInsets.init(top: 4, leading: 8, bottom: 4, trailing: 8))
          .font(.callout)
          .background(.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      })
      .padding()
    }
    .sheet(item: self.$showImagePicker) { pickerInfo in
      return pickerInfo.picker
    }
    .alert(item: self.$showAlertMessage) { alertMessage in
      if let actionButton = alertMessage.actionButton {
        return Alert(
          title: alertMessage.title,
          message: alertMessage.message,
          primaryButton: actionButton,
          secondaryButton: alertMessage.cancelButton)
      } else {
        return Alert(
          title: alertMessage.title,
          message: alertMessage.message,
          dismissButton: alertMessage.cancelButton)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
