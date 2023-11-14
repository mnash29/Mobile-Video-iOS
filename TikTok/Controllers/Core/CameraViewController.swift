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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cameraView.frame = view.bounds
    }

    @objc private func didTapClose() {
        captureSession.stopRunning()
        tabBarController?.tabBar.isHidden = false
        tabBarController?.selectedIndex = 0
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
            return
        }

        print("Finished recording to url: \(outputFileURL.absoluteString)")
    }
}
