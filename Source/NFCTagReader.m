//
//  NFCTagReader.m
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/3.
//

#import "NFCTagReader.h"

@interface NFCTagReader() <NFCTagReaderSessionDelegate>

@property (nonatomic, strong) NFCTagReaderSession *session;
@property(strong,nonatomic)id<NFCTag> cuurentTag;

@end

@implementation NFCTagReader

#pragma mark - Initializer

- (instancetype)initSessionWithDelegate:(id<NFCReaderDelegate>)delegate alertMessage:(NSString *)alertMessage {
    
    self = [super initSessionWithDelegate:delegate
                             alertMessage:alertMessage];
    
    if (self) {
        
        NFCPollingOption option = NFCPollingISO14443 | NFCPollingISO15693 | NFCPollingISO18092;
        self.session = [[NFCTagReaderSession alloc] initWithPollingOption:option
                                                                 delegate:self
                                                                    queue:[NFCReaderWriter queue]];
        self.session.alertMessage = alertMessage;
    }
    
    return self;
}

#pragma mark - NFCTagReaderSessionDelegate

- (void)tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error {
    
    [self.delegate reader:self didInvalidateWithError:error];
}

- (void)tagReaderSessionDidBecomeActive:(NFCTagReaderSession *)session {
    
    if ([self.delegate respondsToSelector:@selector(readerDidBecomeActive:)]) {
        [self.delegate readerDidBecomeActive:self];
    }
}

- (void)tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCTag>> *)tags {
    
    if ([self.delegate respondsToSelector:@selector(reader:didDetectTags:)]) {
        [self.delegate reader:self didDetectTags:tags];
    }
    
    // GET NFC TAG UID
//    self.cuurentTag = [tags firstObject];
//    NSLog(@"TagType: %lu, %lu", (unsigned long)self.cuurentTag.type, (unsigned long)NFCTagTypeISO7816Compatible);
//    id<NFCISO7816Tag> mifareTag = [self.cuurentTag asNFCISO7816Tag];
//    NSData *data = mifareTag.identifier;
//    NSString *string = [self convertDataBytesToHex:data];
//    NSLog(@"result---%@",string);
}

- (NSString *)convertDataBytesToHex:(NSData *)dataBytes {
    if (!dataBytes || [dataBytes length] == 0) {
        return @"";
    }
    NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:[dataBytes length]];
    [dataBytes enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *)bytes;
        for (NSInteger i = 0; i < byteRange.length; i ++) {
            NSString *singleHexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([singleHexStr length] == 2) {
                [hexStr appendString:singleHexStr];
            } else {
                [hexStr appendFormat:@"0%@", singleHexStr];
            }
        }
    }];
    return hexStr;
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
        NFCPollingOption option = NFCPollingISO14443 | NFCPollingISO15693 | NFCPollingISO18092;
        self.session = [[NFCTagReaderSession alloc] initWithPollingOption:option
                                                                 delegate:self
                                                                    queue:[NFCReaderWriter queue]];
        self.session.alertMessage = self.alertMessage;
        [self.session beginSession];
    }
}

- (void)end {
    
    if (self.session) {
        [self.session invalidateSession];
    }
}

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(nonnull id<NFCTag>)tag connectHandler:(nonnull void (^)(NSError * _Nullable))connectHandler writeHandler:(nonnull void (^)(NFCNDEFStatus, NSUInteger, NSError * _Nullable))writeHandler {
    
    [self.session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
        if (error) {
            connectHandler(error);
        }else{
            switch (tag.type) {
                case NFCTagTypeISO15693: {
                    [self queryTag:[tag asNFCISO15693Tag] andWriteMessage:message queryHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                        
                    } writeHandler:^(NSError * _Nullable error) {
                        
                    }];
                } break;
                    
                case NFCTagTypeFeliCa: {
                    [self queryTag:[tag asNFCFeliCaTag] andWriteMessage:message queryHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                        
                    } writeHandler:^(NSError * _Nullable error) {
                        
                    }];
                } break;
                    
                case NFCTagTypeISO7816Compatible: {
                    [self queryTag:[tag asNFCISO7816Tag] andWriteMessage:message queryHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                        
                    } writeHandler:^(NSError * _Nullable error) {
                        
                    }];
                } break;
                    
                case NFCTagTypeMiFare: {
                    [self queryTag:[tag asNFCMiFareTag] andWriteMessage:message queryHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                        
                    } writeHandler:^(NSError * _Nullable error) {
                        
                    }];
                } break;
                    
                default: break;
            }
        }
    }];
}

- (void)queryTag:(id <NFCNDEFTag>)tag andWriteMessage:(NFCNDEFMessage *)message queryHandler:(nonnull void(^)(NFCNDEFStatus status, NSUInteger capacity, NSError *_Nullable error))queryHandler writeHandler:(nonnull void(^)(NSError *_Nullable error))writeHandler{
    
    [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
        
        if (status == NFCNDEFStatusReadWrite && !error) {
            [tag writeNDEF:message completionHandler:^(NSError * _Nullable error) {
                writeHandler(error);
            }];
        }else{
            queryHandler(status, capacity, error);
        }
    }];
}

@end
