//
//  LGOCodeScanPlugin.m
//  plugin

#import "LGOCodeScanPlugin.h"
#import <LEGO-SDK/LGOCore.h>
#import "CodeScanViewController.h"
#import <LEGO-SDK/LGOBaseNavigationController.h>
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

@interface LGOCodeScanperation()

@end

@implementation LGOCodeScanperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    self.callbackBlock = callbackBlock;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        CodeScanViewController *codeScanViewController = [CodeScanViewController new];
        codeScanViewController.operation = self;
        LGOBaseNavigationController *navigationController = [[LGOBaseNavigationController alloc] initWithRootViewController:codeScanViewController];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
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
