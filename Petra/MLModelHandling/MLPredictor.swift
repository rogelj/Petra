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

import Foundation
import UIKit
import Vision
import CoreML

enum MLPredictor {
  static func predictUsingModel(_ modelPath: URL, inputImage: UIImage, onCompletion: @escaping (UIImage?) -> Void) {
    // 1
    guard
      let compiledModel = try? MLModel.compileModel(at: modelPath),
      let mlModel = try? MLModel.init(contentsOf: compiledModel)
    else {
      debugPrint("Error reading the ML Model")
      return onCompletion(nil)
    }
    // 2
    let imageOptions: [MLFeatureValue.ImageOption: Any] = [
      .cropAndScale: VNImageCropAndScaleOption.centerCrop.rawValue
    ]
    guard
      let cgImage = inputImage.cgImage,
      let imageConstraint = mlModel.modelDescription.inputDescriptionsByName["image"]?.imageConstraint,
      let inputImg = try? MLFeatureValue(cgImage: cgImage, constraint: imageConstraint, options: imageOptions),
      let inputImage = try? MLDictionaryFeatureProvider(dictionary: ["image": inputImg])
    else {
      return onCompletion(nil)
    }
    // 3
    guard
      let stylizedImage = try? mlModel.prediction(from: inputImage),
      let imgBuffer = stylizedImage.featureValue(for: "stylizedImage")?.imageBufferValue
    else {
      return onCompletion(nil)
    }
    let stylizedUIImage = UIImage(withCVImageBuffer: imgBuffer)
    return onCompletion(stylizedUIImage)
  }
}
