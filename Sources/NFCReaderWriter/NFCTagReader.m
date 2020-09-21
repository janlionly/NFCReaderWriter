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
        self.readerSession = self.session;
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
//    if ([self.delegate respondsToSelector:@selector(reader:didDetectTags:)]) {
//        [self.delegate reader:self didDetectTags:tags];
//    }
    if (tags.count > 0) {
        [session connectToTag:tags.firstObject completionHandler:^(NSError * _Nullable error) {
            if (nil != error) {
                session.alertMessage = NSLocalizedString(@"Unable to connect to tag", @"");
                [session invalidateSession];
                return;
            }
            [tags.firstObject queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                if (status == NFCNDEFStatusNotSupported) {
                    session.alertMessage = NSLocalizedString(@"Tag is not NDEF compliant", @"");
                    [session invalidateSession];
                    return;
                } else if (nil != error) {
                    session.alertMessage = NSLocalizedString(@"Unable to query NDEF status of tag", @"");
                    [session invalidateSession];
                    return;
                }
                
                [tags.firstObject readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable message, NSError * _Nullable error) {
                    if (nil != error || nil == message) {
                        session.alertMessage = NSLocalizedString(@"Fail to read NDEF from tag", @"");
                        [session invalidateSession];
                        return;
                    } else {
                        if (nil != self.detectedMessage) {
                            session.alertMessage = self.detectedMessage;
                        }
                        if ([self.delegate respondsToSelector:@selector(reader:didDetectTag:didDetectNDEF:)]) {
                            [self.delegate reader:self didDetectTag:tags.firstObject didDetectNDEF:message];
                        }
                    }
                }];
            }];
        }];
    }
}

- (NSData *)tagIdentifierWithTag:(id<NFCTag>)tag {
    switch (tag.type) {
        case NFCTagTypeISO15693:
            return [tag asNFCISO15693Tag].identifier;
        case NFCTagTypeFeliCa:
            return [tag asNFCFeliCaTag].currentIDm;
        case NFCTagTypeISO7816Compatible:
            return [tag asNFCISO7816Tag].identifier;
        case NFCTagTypeMiFare:
            return [tag asNFCMiFareTag].identifier;
            
        default:
            return nil;
    }
}

- (NSString *)convertDataBytesToHex:(NSData *)dataBytes isAddColons:(BOOL)isAddColons {
    if (!dataBytes || [dataBytes length] == 0) {
        return @"";
    }
    NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:[dataBytes length]];
    [dataBytes enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *)bytes;
        for (NSInteger i = 0; i < byteRange.length; i ++) {
            NSString *singleHexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            NSString *seporator = isAddColons ? @":" : @"";
            if (i == byteRange.length - 1) {
                seporator = @"";
            }
            
            if ([singleHexStr length] == 2) {
                [hexStr appendFormat:@"%@%@", [singleHexStr uppercaseString], seporator];
            } else {
                [hexStr appendFormat:@"0%@%@", [singleHexStr uppercaseString], seporator];
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
