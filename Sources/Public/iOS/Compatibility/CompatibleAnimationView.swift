//
//  CompatibleAnimationView.swift
//  Lottie_iOS
//
//  Created by Tyler Hedrick on 3/6/19.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit

/// An Objective-C compatible wrapper around Lottie's Animation class.
/// Use in tandem with CompatibleAnimationView when using Lottie in Objective-C
@objc
public final class CompatibleAnimation: NSObject {
  
  // MARK: Private

  private let filepath: String?
  private let name: String?
  private let json: String?
  private let subdirectory: String?
  private let bundle: Bundle?

  // MARK: Lifecycle

  @objc
  static func filepath(_ filepath: String) -> CompatibleAnimation {
    return CompatibleAnimation(filepath: filepath)
  }
  
  @objc
  static func json(_ json: String) -> CompatibleAnimation {
    return CompatibleAnimation(json: json)
  }
  
  @objc
  public init(filepath: String? = nil) {
    self.filepath = filepath
    self.bundle = nil
    self.name = nil
    self.subdirectory = nil
    self.json = nil
    super.init()
  }
  
  @objc
  public init(json: String? = nil) {
    self.filepath = nil
    self.bundle = nil
    self.name = nil
    self.subdirectory = nil
    self.json = json
    super.init()
  }
  
  @objc
  public init(
    name: String,
    bundle: Bundle = Bundle.main)
  {
    self.name = name
    self.subdirectory = nil
    self.bundle = bundle
    self.filepath = nil
    self.json = nil
    super.init()
  }
  @objc
  public init(
    name: String,
    subdirectory: String? = nil,
    bundle: Bundle = Bundle.main)
  {
    self.name = name
    self.subdirectory = subdirectory
    self.bundle = bundle
    self.filepath = nil
    self.json = nil
    super.init()
  }

  // MARK: Internal

  internal var animation: LottieAnimation? {
    if let json = json {
      guard let jsonData = json.data(using: .utf8) else { return nil }
      return try? JSONDecoder().decode(LottieAnimation.self, from: jsonData)
    } else if let filepath = filepath {
      if (filepath.hasSuffix(".lottie")) {
        return try? DotLottieFile.SynchronouslyBlockingCurrentThread.loadedFrom(filepath: filepath).get().animation(at: 0)?.animation;
      } else {
        return LottieAnimation.filepath(filepath)

      }
    } else if let name = name, let bundle = bundle {
      if (name.hasSuffix(".lottie")) {
        return try? DotLottieFile.SynchronouslyBlockingCurrentThread.named(name, bundle: bundle).get().animation(at: 0)?.animation;
      } else {
        return LottieAnimation.named(name, bundle: bundle, subdirectory: subdirectory)
      }
    }
    return nil
  }

  @objc
  static func named(_ name: String) -> CompatibleAnimation {
    CompatibleAnimation(name: name)
  }

}

/// An Objective-C compatible wrapper around Lottie's RenderingEngineOption enum. Pass in an option
/// to the CompatibleAnimationView initializers to configure the rendering engine for the view.
@objc
public enum CompatibleRenderingEngineOption: Int {
  /// Uses the rendering engine specified in LottieConfiguration.shared.
  case shared

  /// Uses the library default rendering engine, coreAnimation.
  case defaultEngine

  /// Optimizes rendering performance by using the Core Animation rendering engine for animations it
  /// can render while falling back to the main thread renderer for all other animations.
  case automatic

  /// Only renders animations using the main thread rendering engine.
  case mainThread

  /// Only renders animations using the Core Animation rendering engine. Those animations that use
  /// features not yet supported on this renderer will not be rendered.
  case coreAnimation

  // MARK: Public

  /// Converts a CompatibleRenderingEngineOption to the corresponding LottieConfiguration for
  /// internal rendering engine configuration.
  public static func generateLottieConfiguration(
    _ configuration: CompatibleRenderingEngineOption)
    -> LottieConfiguration
  {
    switch configuration {
    case .shared:
      return LottieConfiguration.shared
    case .defaultEngine:
      return LottieConfiguration(renderingEngine: .coreAnimation)
    case .automatic:
      return LottieConfiguration(renderingEngine: .automatic)
    case .mainThread:
      return LottieConfiguration(renderingEngine: .mainThread)
    case .coreAnimation:
      return LottieConfiguration(renderingEngine: .coreAnimation)
    }
  }
}

/// An Objective-C compatible version of `LottieBackgroundBehavior`.
@objc
public enum CompatibleBackgroundBehavior: Int {
  /// Stop the animation and reset it to the beginning of its current play time. The completion block is called.
  case stop

  /// Pause the animation in its current state. The completion block is called.
  case pause

  /// Pause the animation and restart it when the application moves to the foreground.
  /// The completion block is stored and called when the animation completes.
  ///  - This is the default when using the Main Thread rendering engine.
  case pauseAndRestore

  /// Stops the animation and sets it to the end of its current play time. The completion block is called.
  case forceFinish

  /// The animation continues playing in the background.
  ///  - This is the default when using the Core Animation rendering engine.
  ///    Playing an animation using the Core Animation engine doesn't come with any CPU overhead,
  ///    so using `.continuePlaying` avoids the need to stop and then resume the animation
  ///    (which does come with some CPU overhead).
  ///  - This mode should not be used with the Main Thread rendering engine.
  case continuePlaying
}

/// An Objective-C compatible wrapper around Lottie's LottieAnimationView.
@objc
public final class CompatibleAnimationView: UIView {

  // MARK: Lifecycle

  /// Initializes a compatible AnimationView with a given compatible animation. Defaults to using
  /// the rendering engine specified in LottieConfiguration.shared.
  @objc
  public convenience init(compatibleAnimation: CompatibleAnimation) {
    self.init(compatibleAnimation: compatibleAnimation, compatibleRenderingEngineOption: .shared)
  }

  /// Initializes a compatible AnimationView with a given compatible animation and rendering engine
  /// configuration.
  @objc
  public init(
    compatibleAnimation: CompatibleAnimation,
    compatibleRenderingEngineOption: CompatibleRenderingEngineOption)
  {
    animationView = LottieAnimationView(
      animation: compatibleAnimation.animation,
      configuration: CompatibleRenderingEngineOption.generateLottieConfiguration(compatibleRenderingEngineOption))
    self.compatibleAnimation = compatibleAnimation
    super.init(frame: .zero)
    commonInit()
  }

  /// Initializes a compatible AnimationView with the resources asynchronously loaded from a given
  /// URL. Defaults to using the rendering engine specified in LottieConfiguration.shared.
  @objc
  public convenience init(url: URL) {
    self.init(url: url, compatibleRenderingEngineOption: .shared)
  }

  /// Initializes a compatible AnimationView with the resources asynchronously loaded from a given
  /// URL using the given rendering engine configuration.
  @objc
  public init(url: URL, compatibleRenderingEngineOption: CompatibleRenderingEngineOption) {
    animationView = LottieAnimationView(
      url: url,
      closure: { _ in },
      configuration: CompatibleRenderingEngineOption.generateLottieConfiguration(compatibleRenderingEngineOption))
    super.init(frame: .zero)
    commonInit()
  }

  /// Initializes a compatible AnimationView from a given Data object specifying the Lottie
  /// animation. Defaults to using the rendering engine specified in LottieConfiguration.shared.
  @objc
  public convenience init(data: Data) {
    self.init(data: data, compatibleRenderingEngineOption: .shared)
  }

  /// Initializes a compatible AnimationView from a given Data object specifying the Lottie
  /// animation using the given rendering engine configuration.
  @objc
  public init(data: Data, compatibleRenderingEngineOption: CompatibleRenderingEngineOption) {
    if let animation = try? LottieAnimation.from(data: data) {
      animationView = LottieAnimationView(
        animation: animation,
        configuration: CompatibleRenderingEngineOption.generateLottieConfiguration(compatibleRenderingEngineOption))
    } else {
      animationView = LottieAnimationView(
        configuration: CompatibleRenderingEngineOption.generateLottieConfiguration(compatibleRenderingEngineOption))
    }
    super.init(frame: .zero)
    commonInit()
  }

  @objc
  public override init(frame: CGRect) {
    animationView = LottieAnimationView()
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    animationView = LottieAnimationView()
    super.init(coder: coder)
    commonInit()
  }

  // MARK: Public

  @objc
  public var compatibleAnimation: CompatibleAnimation? {
    didSet {
      animationView.animation = compatibleAnimation?.animation
    }
  }
  
  @objc
  public var animation: LottieAnimation? {
    didSet {
      animationView.animation = animation
    }
  }

  @objc
  public var loopAnimationCount: CGFloat = 0 {
    didSet {
      animationView.loopMode = loopAnimationCount == -1 ? .loop : .repeat(Float(loopAnimationCount))
    }
  }

  @objc
  public var compatibleDictionaryTextProvider: CompatibleDictionaryTextProvider? {
    didSet {
      animationView.textProvider = compatibleDictionaryTextProvider?.textProvider ?? DefaultTextProvider()
    }
  }

  @objc
  public override var contentMode: UIView.ContentMode {
    set { animationView.contentMode = newValue }
    get { animationView.contentMode }
  }

  @objc
  public var shouldRasterizeWhenIdle: Bool {
    set { animationView.shouldRasterizeWhenIdle = newValue }
    get { animationView.shouldRasterizeWhenIdle }
  }
  
  @objc
  public var currentProgress: CGFloat {
    set { animationView.currentProgress = newValue }
    get { animationView.currentProgress }
  }

  @objc
  public var duration: CGFloat {
    animationView.animation?.duration ?? 0.0
  }

  @objc
  public var currentTime: TimeInterval {
    set { animationView.currentTime = newValue }
    get { animationView.currentTime }
  }

  @objc
  public var currentFrame: CGFloat {
    set { animationView.currentFrame = newValue }
    get { animationView.currentFrame }
  }

  @objc
  public var realtimeAnimationFrame: CGFloat {
    animationView.realtimeAnimationFrame
  }
  
  @objc
  public var realtimeAnimationProgress: CGFloat {
    animationView.realtimeAnimationProgress
  }
  
  @objc
  public var animationDuration: TimeInterval {
    return animationView.animation?.duration ?? -1;
  }

  @objc
  public var animationSpeed: CGFloat {
    set { animationView.animationSpeed = newValue }
    get { animationView.animationSpeed }
  }

  @objc
  public var respectAnimationFrameRate: Bool {
    set { animationView.respectAnimationFrameRate = newValue }
    get { animationView.respectAnimationFrameRate }
  }

  @objc
  public var isAnimationPlaying: Bool {
    animationView.isAnimationPlaying
  }

  @objc
  public var backgroundMode: CompatibleBackgroundBehavior {
    get {
      switch animationView.backgroundBehavior {
      case .stop:
        return .stop
      case .pause:
        return .pause
      case .pauseAndRestore:
        return .pauseAndRestore
      case .forceFinish:
        return .forceFinish
      case .continuePlaying:
        return .continuePlaying
      }
    }
    set {
      switch newValue {
      case .stop:
        animationView.backgroundBehavior = .stop
      case .pause:
        animationView.backgroundBehavior = .pause
      case .pauseAndRestore:
        animationView.backgroundBehavior = .pauseAndRestore
      case .forceFinish:
        animationView.backgroundBehavior = .forceFinish
      case .continuePlaying:
        animationView.backgroundBehavior = .continuePlaying
      }
    }
  }

  @objc
  public func play() {
    play(completion: nil)
  }

  @objc
  public func play(completion: ((Bool) -> Void)?) {
    animationView.play(completion: completion)
  }

  /// Note: When calling this code from Objective-C, the method signature is
  /// playFromProgress:toProgress:completion which drops the standard "With" naming convention.
  @objc
  public func play(
    fromProgress: CGFloat,
    toProgress: CGFloat,
    completion: ((Bool) -> Void)? = nil) {
    animationView.play(
      fromProgress: fromProgress,
      toProgress: toProgress,
      loopMode: nil,
      completion: completion)
  }

  /// Note: When calling this code from Objective-C, the method signature is
  /// playFromFrame:toFrame:completion which drops the standard "With" naming convention.
  @objc
  public func play(
    fromFrame: CGFloat,
    toFrame: CGFloat,
    completion: ((Bool) -> Void)? = nil) {
    animationView.play(
      fromFrame: fromFrame,
      toFrame: toFrame,
      loopMode: nil,
      completion: completion)
  }

  /// Note: When calling this code from Objective-C, the method signature is
  /// playFromMarker:toMarker:completion which drops the standard "With" naming convention.
  @objc
  public func play(
    fromMarker: String,
    toMarker: String,
    completion: ((Bool) -> Void)? = nil) {
    animationView.play(
      fromMarker: fromMarker,
      toMarker: toMarker,
      completion: completion)
  }

  @objc
  public func play(
    marker: String,
    completion: ((Bool) -> Void)? = nil)
  {
    animationView.play(
      marker: marker,
      completion: completion)
  }

  @objc
  public func stop() {
    animationView.stop()
  }

  @objc
  public func pause() {
    animationView.pause()
  }

  @objc
  public func reloadImages() {
    animationView.reloadImages()
  }

  @objc
  public func forceDisplayUpdate() {
    animationView.forceDisplayUpdate()
  }

  @objc
  public func getValue(
    for keypath: CompatibleAnimationKeypath,
    atFrame: CGFloat)
    -> Any?
  {
    animationView.getValue(
      for: keypath.animationKeypath,
      atFrame: atFrame)
  }

  @objc
  public func logHierarchyKeypaths() {
    animationView.logHierarchyKeypaths()
  }

  @objc
  public func setColorValue(_ color: UIColor, forKeypath keypath: CompatibleAnimationKeypath) {
    let valueProvider = ColorValueProvider(color.lottieColorValue)
    animationView.setValueProvider(valueProvider, keypath: keypath.animationKeypath)
  }

  @objc
  public func getColorValue(for keypath: CompatibleAnimationKeypath, atFrame: CGFloat) -> UIColor? {
    let value = animationView.getValue(for: keypath.animationKeypath, atFrame: atFrame)
    guard let colorValue = value as? LottieColor else {
      return nil;
    }

    return UIColor(
      red: CGFloat(colorValue.r),
      green: CGFloat(colorValue.g),
      blue: CGFloat(colorValue.b),
      alpha: CGFloat(colorValue.a))
  }
  
  @objc
  public func setFloatValue(_ value: CGFloat, forKeypath keypath: CompatibleAnimationKeypath) {
    let valueProvider = FloatValueProvider(value)
    animationView.setValueProvider(valueProvider, keypath: keypath.animationKeypath)
  }

  @objc
  public func getFloatValue(for keypath: CompatibleAnimationKeypath, atFrame: CGFloat) -> NSNumber? {
    let value = animationView.getValue(for: keypath.animationKeypath, atFrame: atFrame)
    return value as? NSNumber
  }


  @objc
  public func addSubview(
    _ subview: AnimationSubview,
    forLayerAt keypath: CompatibleAnimationKeypath) {
    animationView.addSubview(
      subview,
      forLayerAt: keypath.animationKeypath)
  }

  @objc
  public func convert(
    rect: CGRect,
    toLayerAt keypath: CompatibleAnimationKeypath?)
    -> CGRect
  {
    animationView.convert(
      rect,
      toLayerAt: keypath?.animationKeypath) ?? .zero
  }

  @objc
  public func convert(
    point: CGPoint,
    toLayerAt keypath: CompatibleAnimationKeypath?)
    -> CGPoint
  {
    animationView.convert(
      point,
      toLayerAt: keypath?.animationKeypath) ?? .zero
  }

  @objc
  public func progressTime(forMarker named: String) -> CGFloat {
    animationView.progressTime(forMarker: named) ?? 0
  }
  
  @objc
  public func frameTime(forMarker named: String) -> CGFloat {
    animationView.frameTime(forMarker: named) ?? 0
  }
  
  @objc
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return animationView.intrinsicContentSize
  }
  
  @objc
  public override var intrinsicContentSize: CGSize {
    get { return animationView.intrinsicContentSize }
  }

  @objc
  public func durationFrameTime(forMarker named: String) -> CGFloat {
    animationView.durationFrameTime(forMarker: named) ?? 0
  }

  // MARK: Private

  private let animationView: LottieAnimationView

  private func commonInit() {
    setUpViews()
  }
  

  private func setUpViews() {
    animationView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(animationView)
    animationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    animationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    animationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    animationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}

/// An Objective-C compatible wrapper around Lottie's DictionaryTextProvider.
/// Use in tandem with CompatibleAnimationView to supply text to LottieAnimationView
/// when using Lottie in Objective-C.
@objc
public final class CompatibleDictionaryTextProvider: NSObject {

  // MARK: Lifecycle

  @objc
  public init(values: [String: String]) {
    self.values = values
    super.init()
  }

  // MARK: Internal

  var textProvider: AnimationKeypathTextProvider? {
    DictionaryTextProvider(values)
  }

  // MARK: Private

  private let values: [String: String]
}
#endif
