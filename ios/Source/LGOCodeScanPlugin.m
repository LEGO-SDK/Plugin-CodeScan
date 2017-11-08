//
//  LGOCodeScanPlugin.m
//  plugin

#import "LGOCodeScanPlugin.h"
#import <LEGO-SDK/LGOCore.h>
#import "CodeScanViewController.h"
#import <LEGO-SDK/LGOBaseNavigationController.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface LGOCodeScanRequest()
@property (nonatomic, copy) NSString *opt;
@end

@implementation LGOCodeScanRequest

@end


@implementation LGOCodeScanResponse

- (NSDictionary *)resData {
    return @{
             @"result": self.result ?: @"",
             };
}

@end

@interface LGOCodeScanImagePickerDelegateHandler : NSObject <UIImagePickerControllerDelegate>
+ (instancetype)sharedInstance;
@property (nonatomic, strong) LGOCodeScanperation *operation;
@end

@interface LGOCodeScanperation()

@end

@implementation LGOCodeScanperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    self.callbackBlock = callbackBlock;
    if ([self.request.opt isEqualToString:@"Scan"]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CodeScanViewController *codeScanViewController = [CodeScanViewController new];
            codeScanViewController.operation = self;
            LGOBaseNavigationController *navigationController = [[LGOBaseNavigationController alloc] initWithRootViewController:codeScanViewController];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
        }];
    } else if ([self.request.opt isEqualToString:@"Recognition"]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            if (imagePickerController) {
                [LGOCodeScanImagePickerDelegateHandler sharedInstance].operation = self;
                imagePickerController.delegate = (id)[LGOCodeScanImagePickerDelegateHandler sharedInstance];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
            } else {
                callbackBlock([[LGOCodeScanResponse new] reject:[NSError errorWithDomain:@"Plugin.CodeScan" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"can not creat imagePicker"}]]);
            }
        }];
    }
}
@end

@implementation LGOCodeScanImagePickerDelegateHandler
static LGOCodeScanImagePickerDelegateHandler *singleton = nil;

+ (instancetype)sharedInstance {
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    singleton = [[super allocWithZone:NULL] init];
});
return singleton;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [LGOCodeScanImagePickerDelegateHandler sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [LGOCodeScanImagePickerDelegateHandler sharedInstance];
}

#pragma mark ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    if ([pickedImage isKindOfClass:[UIImage class]]) {
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:NULL options:@{CIDetectorAccuracy:  CIDetectorAccuracyLow}];
        if (detector) {
            CIImage *corePickedImage = pickedImage.CIImage;
            if (! corePickedImage) {
                corePickedImage = [CIImage imageWithCGImage:pickedImage.CGImage];
                if (! corePickedImage) {
                    NSData *pickedImageData = UIImageJPEGRepresentation(pickedImage, 1.0);
                    corePickedImage = [CIImage imageWithData:pickedImageData];
                }
            }
            if (corePickedImage) {
                NSArray *features = [detector featuresInImage:corePickedImage];
                if (features.count > 0) {
                    [features enumerateObjectsUsingBlock:^(CIQRCodeFeature  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[CIQRCodeFeature class]]) {
                            if ([obj.type isEqualToString:CIFeatureTypeQRCode]) {
                                LGOCodeScanResponse *response = [LGOCodeScanResponse new];
                                response.result = obj.messageString;
                                self.operation.callbackBlock([response accept:nil]);
                            }
                        }
                        
                    }];
                } else {
                    self.operation.callbackBlock([[LGOCodeScanResponse new] reject:[NSError errorWithDomain:@"Plugin.CodeScan" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"can not find QR code"}]]);
                }
            } else {
                self.operation.callbackBlock([[LGOCodeScanResponse new] reject:[NSError errorWithDomain:@"Plugin.CodeScan" code:-4 userInfo:@{NSLocalizedDescriptionKey : @"can not convert picked image to CIImage"}]]);
            }
        } else {
            self.operation.callbackBlock([[LGOCodeScanResponse new] reject:[NSError errorWithDomain:@"Plugin.CodeScan" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"can not create CIDetector"}]]);
        }
    }
//    if (self.operation.request.closeAfter) {
        [picker dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.operation.callbackBlock([[LGOCodeScanResponse new] reject:[NSError errorWithDomain:@"Plugin.CodeScan" code:-3 userInfo:@{NSLocalizedDescriptionKey : @"imagePickerControllerDidCancel"}]]);
    }];
}
@end

@implementation LGOCodeScanPlugin

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOCodeScanperation *operation = [LGOCodeScanperation new];
    operation.request = [LGOCodeScanRequest new];
    operation.request.context = context;
    operation.request.closeAfter = [dictionary[@"closeAfter"] isKindOfClass:[NSNumber class]] ? [dictionary[@"closeAfter"] boolValue] : YES;
    operation.request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : nil;
    return operation;
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOCodeScanRequest class]]) {
        LGOCodeScanperation *operation = [LGOCodeScanperation new];
        operation.request = (LGOCodeScanRequest *)request;
        return operation;
    }
    return nil;
}

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Plugin.CodeScan" instance:[self new]];
}

@end
