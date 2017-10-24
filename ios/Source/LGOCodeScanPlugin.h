//
//  LGOCodeScanPlugin.h
//  plugin

#import <Foundation/Foundation.h>
#import <LEGO-SDK/LGOProtocols.h>

@interface LGOCodeScanPlugin : LGOModule

@end

@interface LGOCodeScanResponse: LGOResponse

@property (nonatomic, copy) NSString *result;

@end

@interface LGOCodeScanRequest: LGORequest
@property (nonatomic, assign) BOOL closeAfter;
@end

@interface LGOCodeScanperation: LGORequestable
@property (nonatomic, strong) LGOCodeScanRequest *request;
@property (nonatomic, copy) LGORequestableAsynchronizeBlock callbackBlock;
@end

