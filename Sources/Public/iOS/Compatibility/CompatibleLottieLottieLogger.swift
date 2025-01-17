//
//  File.swift
//  
//
//  Created by Martin Guillon on 21/11/2023.
//

import Foundation
/// An Objective-C compatible wrapper around Lottie's AnimationKeypath
@objc
@objcMembers
public class CompatibleLottieLogger: NSObject {

  // MARK: Lifecycle
  
  @objc
  public static func overrideLottieLogger()
  {
    LottieLogger.shared =  LottieLogger(assert: { condition, message, file, line in }, assertionFailure: { message, file, line in })
  }

}
