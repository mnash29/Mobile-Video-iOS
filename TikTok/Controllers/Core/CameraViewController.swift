//
//  CameraViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // Capture session
    var captureSession = AVCaptureSession()

    // Capture device
    var videoCaptureDevice: AVCaptureDevice?

    // Capture output
    var captureOutput = AVCaptureMovieFileOutput()

    // Capture preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?

    private let cameraView: UIView = {
        let view = UIView()

        view.clipsToBounds = true
        view.backgroundColor = .black

        return view
    }()

    private let recordButton = RecordButton()

    private var previewLayer: AVPlayerLayer?

    var recordedVideoURL: URL?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(cameraView)
        view.backgroundColor = .systemBackground
        setUpCamera()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )

        view.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cameraView.frame = view.bounds

        let size: CGFloat = 70
        recordButton.frame = CGRect(
            x: (view.width - size) / 2,
            y: view.height - view.safeAreaInsets.bottom - size - 5,
            width: size,
            height: size
        )
    }

    @objc private func didTapClose() {
        navigationItem.rightBarButtonItem = nil
        recordButton.isHidden = false

        if previewLayer != nil {
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
        }
        else {
            captureSession.stopRunning()
            tabBarController?.tabBar.isHidden = false
            tabBarController?.selectedIndex = 0
        }
    }

    @objc private func didTapRecord() {
        if captureOutput.isRecording {
            recordButton.toggle(for: .notRecording)
            captureOutput.stopRecording()
        }
        else {
            guard var url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else {
                return
            }

            url.appendPathComponent("video.mov")

            recordButton.toggle(for: .recording)

            if FileManager.default.fileExists(atPath: url.absoluteString) {
                try? FileManager.default.removeItem(at: url)
            }

            captureOutput.startRecording(to: url,
                                         recordingDelegate: self)
        }
    }

    @objc private func didTapNext() {
        // Push caption controller
    }

    func setUpCamera() {
        // Add devices
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            if let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            }
        }

        if let videoDevice = AVCaptureDevice.default(for: .video) {
            if let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
            }
        }

        // Update sessions
        captureSession.sessionPreset = .hd1280x720
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }

        // Configure preview
        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer?.videoGravity = .resizeAspectFill
        capturePreviewLayer?.frame = view.bounds

        if let layer = capturePreviewLayer {
            cameraView.layer.addSublayer(layer)
        }

        // Enable camera start
        captureSession.startRunning()
    }

}

// MARK: - AVCaptureFileOutputRecording delegate methods

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            let alert = UIAlertController(
                title: "Woops",
                message: "Something went wrong while recording video.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }

        recordedVideoURL = outputFileURL

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next",
            style: .done,
            target: self,
            action: #selector(didTapNext)
        )

        let player = AVPlayer(url: outputFileURL)
        previewLayer = AVPlayerLayer(player: player)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = cameraView.bounds

        guard let previewLayer = previewLayer else { return }
        recordButton.isHidden = true
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.player?.play()
    }
}
