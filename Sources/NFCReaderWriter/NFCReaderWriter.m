//
//  NFCReaderWriter.m
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/3.
//

#import "NFCReaderWriter.h"
#import "NFCNDEFReader.h"
#import "NFCNDEFWriter.h"
#import "NFCTagReader.h"
#import "NFCConstants.h"

@interface NFCReaderWriter()

@property (nonatomic, strong) NFCReader *reader;

@end

@implementation NFCReaderWriter

#pragma mark - Shared readerWriter

+ (NFCReaderWriter *)sharedInstance {
    
    static NFCReaderWriter *readerWriter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readerWriter = [[NFCReaderWriter alloc] init];
    });
    
    return readerWriter;
}

+ (dispatch_queue_t)queue {
    
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("com.NFCReaderWriter.queue", 0);
    });
    
    return q;
}

#pragma mark - Class Helper

+ (BOOL)isAvailable {
    
    return [NFCReaderSession readingAvailable];
}

#pragma mark - Initializers

- (void)newReaderSessionWithDelegate:(id<NFCReaderDelegate>)delegate invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage {
    
    self.reader = [[NFCNDEFReader alloc] initSessionWithDelegate:delegate
                                        invalidateAfterFirstRead:invalidate
                                                    alertMessage:alertMessage];
}

- (void)newWriterSessionWithDelegate:(id<NFCReaderDelegate>)delegate isLegacy:(BOOL)legacy invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage {
 
    if (legacy) {
        self.reader = [[NFCNDEFWriter alloc] initSessionWithDelegate:delegate
                                            invalidateAfterFirstRead:invalidate
                                                        alertMessage:alertMessage];
    }else{
        self.reader = [[NFCTagReader alloc] initSessionWithDelegate:delegate
                                                       alertMessage:alertMessage];
    }
}

#pragma mark - Helper

- (void)setDetectedMessage:(NSString *)detectedMessage {
    self.reader.detectedMessage = detectedMessage;
}

- (NSString *)detectedMessage {
    return self.reader.detectedMessage;
}

- (void)setAlertMessage:(NSString *)alertMessage {
    self.reader.readerSession.alertMessage = alertMessage;
}

- (NSString *)alertMessage {
    return  self.reader.readerSession.alertMessage;
}

- (void)begin {
    if (self.reader) {
        [self.reader begin];
    }
}

- (void)restart {
    if (self.reader) {
        [self.reader restart];
    }
}

- (void)end {
    if (self.reader) {
        [self.reader end];
    }
}

- (BOOL)canWrite {
    
    if ([self.reader isKindOfClass:[NFCNDEFWriter class]]) {
        return YES;
    }
    else if ([self.reader isKindOfClass:[NFCTagReader class]]) {
        return YES;
    }
    
    return NO;
}

- (NFCNDEFPayload *)createPayloadWithFormat:(NFCTypeNameFormat)format type:(NSString *)type indetifier:(NSString *)identifier message:(NSString *)payload {
    
    NSData *typeData = [type dataUsingEncoding:kCFStringEncodingUTF8];
    NSData *identifierData = [identifier dataUsingEncoding:kCFStringEncodingUTF8];
    NSData *payloadData = [payload dataUsingEncoding:kCFStringEncodingUTF8];
    
    NFCNDEFPayload *nfcPayload = [[NFCNDEFPayload alloc] initWithFormat:format
                                                          type:typeData
                                                    identifier:identifierData
                                                       payload:payloadData];
    
    return nfcPayload;
}

- (NFCNDEFMessage *)messageWithPayloads:(NSArray <NFCNDEFPayload *>*)payloads {
    
    NFCNDEFMessage *message = [[NFCNDEFMessage alloc] initWithNDEFRecords:payloads];
    
    return message;
}

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(id<NFCNDEFTag>)tag completion:(void (^)(NSError * _Nullable))completion {
    if (self.reader) {
        [self.reader writeMessage:message toTag:tag completion:completion];
    }
}

- (NSString *)parseNFCError:(NSError *)error {
    
    switch (error.code) {
        case NFCReaderSessionInvalidationErrorFirstNDEFTagRead: {
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderSessionInvalidationErrorFirstNDEFTagRead");
        
            return ErrorFirstNDEFTagRead;
        } break;
            
        case NFCReaderSessionInvalidationErrorUserCanceled: {
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderSessionInvalidationErrorUserCanceled");
          
            return ErrorUserCanceled;
        } break;
            
        case NFCReaderSessionInvalidationErrorSessionTimeout: {
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderSessionInvalidationErrorSessionTimeout");
            
            return ErrorSessionTimeout;
        } break;
            
        case NFCReaderSessionInvalidationErrorSystemIsBusy: {
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderSessionInvalidationErrorSystemIsBusy");
            
            return ErrorSystemIsBusy;
        } break;
            
        case NFCReaderSessionInvalidationErrorSessionTerminatedUnexpectedly: {
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderSessionInvalidationErrorSessionTerminatedUnexpectedly");
            
            return ErrorSessionTerminatedUnexpectedly;
        } break;
            
        default: { // NFCReaderErrorUnsupportedFeature
            if (self.isDebug) NSLog(@"NFCReaderWriter error: NFCReaderErrorUnsupportedFeature");
            
            return ErrorUnsupportedFeature;
        } break;
    }
}

- (NSData *)tagIdentifierWithTag:(id<NFCTag>)tag {
    if ([self.reader isKindOfClass:[NFCTagReader class]]) {
        NFCTagReader *tagReader = (NFCTagReader *)self.reader;
        return [tagReader tagIdentifierWithTag:tag];
    }
    return nil;
}

- (NSString *)hexStringWithData:(NSData *)data isAddColons:(BOOL)isAddColons {
    if ([self.reader isKindOfClass:[NFCTagReader class]]) {
        NFCTagReader *tagReader = (NFCTagReader *)self.reader;
        return [tagReader convertDataBytesToHex:data isAddColons:isAddColons];
    }
    return nil;
}


@end
