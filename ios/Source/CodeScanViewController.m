//
//  CodeScanViewController.m
//  plugin
//
//  Created by Keep Jacky on 2017/10/20.
//  Copyright © 2017年 UED Center, YY Inc. All rights reserved.
//

#import "CodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>
@interface CodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (nonatomic, strong) CALayer *previewLayer;
@property (nonatomic, assign) BOOL isCodeCaptured;
@property (weak, nonatomic) IBOutlet UIButton *flashLightIconButton;
@property (weak, nonatomic) IBOutlet UIButton *flashLightTextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskWidthConstrantI;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskWidthConstraintII;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskHeightConstraintI;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskHeightConstraintII;
@end

@implementation CodeScanViewController
- (void)rightAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫码";
    self.webView.hidden = YES;
    [self setupButton];
    [self setupScan];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
    self.maskWidthConstrantI.constant = (self.view.bounds.size.width - 300) / 2.0;
    self.maskWidthConstraintII.constant = (self.view.bounds.size.width - 300) / 2.0;
    self.maskHeightConstraintI.constant = (self.view.bounds.size.height - 300) / 2.0;
    self.maskHeightConstraintII.constant = (self.view.bounds.size.height - 300) / 2.0;
    [self.view layoutIfNeeded];
}

#pragma mark setup
- (void)setupButton {
    NSData *unSelectedData = [[NSData alloc] initWithBase64EncodedString:@"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" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *seletedData = [[NSData alloc] initWithBase64EncodedString:@"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" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (unSelectedData) {
        UIImage *unSelectedImage = [UIImage imageWithData:unSelectedData];
        if (unSelectedImage) {
            [self.flashLightIconButton setImage:unSelectedImage forState:UIControlStateNormal];
        }
    }
    if (seletedData) {
        UIImage *selectedImage = [UIImage imageWithData:seletedData];
        if (selectedImage) {
            [self.flashLightIconButton setImage:selectedImage forState:UIControlStateSelected];
        }
    }
}
- (void)setupScan {
    self.session = [[AVCaptureSession alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (deviceInput) {
        [self.session addInput:deviceInput];
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:metadataOutput];
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.view.frame;
        [self.previewView.layer addSublayer:previewLayer];
        self.previewLayer = previewLayer;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"摄像头开启失败" delegate:nil cancelButtonTitle:@"稍后再试" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([self presentedViewController] != nil) {
        return;
    }
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isCodeCaptured) {
        self.isCodeCaptured = YES;
        if (self.operation.callbackBlock) {
            LGOCodeScanResponse *response = [LGOCodeScanResponse new];
            response.result = metadataObject.stringValue;
            self.operation.callbackBlock([response accept:nil]);
            if (self.operation.request.closeAfter) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.presentingViewController) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isCodeCaptured = NO;
                });
            }
        }
    }
}

- (IBAction)onFlashLightToggle:(id)sender {
    if(![self.device hasTorch] || ![self.device hasFlash]) {
        return;
    }
    if (!self.flashLightTextButton.selected) {
        [self.session beginConfiguration];
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOn];
        [self.device setFlashMode:AVCaptureFlashModeOn];
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];
        self.flashLightIconButton.selected = YES;
        self.flashLightTextButton.selected = YES;
    }
    else {
        [self.session beginConfiguration];
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device setFlashMode:AVCaptureFlashModeOff];
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];
        self.flashLightIconButton.selected = NO;
        self.flashLightTextButton.selected = NO;
    }
}
@end
