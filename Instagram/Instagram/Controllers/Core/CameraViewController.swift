//
//  CameraViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {

//MARK: - Properties
    
    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
//MARK: - SubViews
    
    private let cameraView: UIView = {
        let camera = UIView()
        return camera
    }()
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()
    
//MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Take Photo"
        
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        setupNavBar()
        checkCameraPermissions()
        shutterButton.addTarget(self, action: #selector(didTapShutterButton), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraView.frame = view.bounds
        
        //need to set the previewLayer frame here so that the safeAreaInsets will be set and respected for future SubViews
        previewLayer.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width
        )
        
        let buttonSize: CGFloat = view.width/5
        shutterButton.frame = CGRect(
            x: (view.width - buttonSize)/2,
            y: view.safeAreaInsets.top + view.width + 100,
            width: buttonSize,
            height: buttonSize
        )
        shutterButton.layer.cornerRadius = buttonSize/2
    }

//MARK: - Configure
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        //makes navbar translucent/clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            //request
            AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
                guard granted else {return}
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .authorized:
            setupCamera()
        case .restricted, .denied:
            break
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        
        let captureSession = AVCaptureSession()
    
        //Add device
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            }
            catch {
                print(error)
            }
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            //Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        }
    }

//MARK: - Actions
    
    @objc private func didTapClose() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func didTapShutterButton() {
        output.capturePhoto(
            with: AVCapturePhotoSettings(),
            delegate: self
        )
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {return}
        
        captureSession?.stopRunning()
        
        let vc = PostEditViewController(image: image)
        vc.navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: false)
    }
}
