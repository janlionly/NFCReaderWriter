//
//  NFCReader.m
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/2.
//

#import "NFCReader.h"

@implementation NFCReader

#pragma mark - Initializer

- (instancetype)initSessionWithDelegate:(id<NFCReaderDelegate>)delegate alertMessage:(NSString *)alertMessage {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        self.alertMessage = alertMessage;
    }
    
    return self;
}

- (instancetype)initSessionWithDelegate:(id <NFCReaderDelegate>)delegate invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        self.invalidate = invalidate;
        self.alertMessage = alertMessage;
    }
    
    return self;
}

#pragma mark - Methods

- (void)begin {
    
}

- (void)restart {
    
}

- (void)end {
    
}

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(id<NFCNDEFTag>)tag completion:(void (^)(NSError * _Nullable))completion {
    
}


@end
