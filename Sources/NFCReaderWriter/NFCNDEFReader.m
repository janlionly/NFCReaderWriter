//
//  NFCNDEFReader.m
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/3.
//

#import "NFCNDEFReader.h"

@interface NFCNDEFReader() <NFCNDEFReaderSessionDelegate>

@property (nonatomic, strong) NFCNDEFReaderSession *session;

@end

@implementation NFCNDEFReader

#pragma mark - Initializer

- (instancetype)initSessionWithDelegate:(id<NFCReaderDelegate>)delegate invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage {
    
    self = [super initSessionWithDelegate:delegate
                 invalidateAfterFirstRead:invalidate
                             alertMessage:alertMessage];

    if (self) {
        self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:[NFCReaderWriter queue] invalidateAfterFirstRead:invalidate];
        self.session.alertMessage = alertMessage;
        self.readerSession = self.session;
    }
    
    return self;
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
    [self.delegate reader:self didInvalidateWithError:error];
}

// iOS 11
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages {
    if (nil != self.detectedMessage) {
        session.alertMessage = self.detectedMessage;
    }
    if ([self.delegate respondsToSelector:@selector(reader:didDetectNDEFs:)]) {
        [self.delegate reader:self didDetectNDEFs:messages];
    }
}

- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session {
    
    if ([self.delegate respondsToSelector:@selector(readerDidBecomeActive:)]) {
        [self.delegate readerDidBecomeActive:self];
    }
}

#pragma mark - Methods

- (void)begin {
    
    if (self.session) {
        [self.session beginSession];
    }
}

- (void)restart {
    
    if (self.session) {
        [self.session restartPolling];
    }else{
        // create and start immediately
        self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                                                queue:[NFCReaderWriter queue]
                                             invalidateAfterFirstRead:self.invalidate];
        self.session.alertMessage = self.alertMessage;
        [self.session beginSession];
    }
}

- (void)end {
    
    if (self.session) {
        [self.session invalidateSession];
    }
}

@end
