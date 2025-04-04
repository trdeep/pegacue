import AVKit
import Flutter
import UIKit

class PiPHandler: NSObject {
    private var flutterViewController: FlutterViewController
    private var pipController: AVPictureInPictureController?
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var contentView: UIView?
    
    init(flutterViewController: FlutterViewController) {
        self.flutterViewController = flutterViewController
        super.init()
        setupPiP()
    }
    
    private func setupPiP() {
        // 检查设备是否支持画中画
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("设备不支持画中画功能")
            return
        }
        
        // 创建一个空的播放器
        player = AVPlayer()
        
        // 创建播放器层
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        playerLayer?.videoGravity = .resizeAspect
        
        // 创建内容视图
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        contentView?.backgroundColor = .black
        
        // 将播放器层添加到内容视图中
        if let playerLayer = playerLayer, let contentView = contentView {
            contentView.layer.addSublayer(playerLayer)
        }
        
        // 创建画中画控制器
        if let playerLayer = playerLayer {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.delegate = self
        }
        
        // 设置方法通道
        let channel = FlutterMethodChannel(
            name: "com.pegacue.pip",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "setupPiP":
                self?.setupPiP()
                result(true)
            case "startPiP":
                self?.startPiP()
                result(true)
            case "stopPiP":
                self?.stopPiP()
                result(true)
            case "updateContent":
                if let args = call.arguments as? [String: Any],
                   let content = args["content"] as? String {
                    self?.updateContent(content)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments",
                                      details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func startPiP() {
        pipController?.startPictureInPicture()
    }
    
    private func stopPiP() {
        pipController?.stopPictureInPicture()
    }
    
    private func updateContent(_ content: String) {
        // 创建一个文本视图来显示内容
        let textView = UITextView(frame: contentView?.bounds ?? .zero)
        textView.text = content
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 30)
        textView.isEditable = false
        
        // 更新内容视图
        contentView?.subviews.forEach { $0.removeFromSuperview() }
        contentView?.addSubview(textView)
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension PiPHandler: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("画中画即将开始")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("画中画已开始")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("画中画即将停止")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("画中画已停止")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("画中画启动失败: \(error.localizedDescription)")
    }
} 
