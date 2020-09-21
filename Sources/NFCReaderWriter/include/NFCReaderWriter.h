//
//  NFCReaderWriter.h
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/3.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>
#import "NFCReaderDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@class NFCReader;

@interface NFCReaderWriter : NSObject

#pragma mark - Shared readerWriter

+ (NFCReaderWriter *)sharedInstance;
+ (dispatch_queue_t)queue;

#pragma mark - Class Helper

+ (BOOL)isAvailable;

#pragma mark - Attributes

@property (nonatomic) BOOL isDebug;

#pragma mark - Initializers

/*!
* @method newReaderSessionWithDelegate:invalidateAfterFirstRead:alertMessage:
*
* @param delegate   The session reader delegate.
* @param invalidate Invalidates session after first read.
* @param alertMessage   The session's alert message.
*
* @discussion   Use when you want to display the NFC Tags payload information.
*/
- (void)newReaderSessionWithDelegate:(id <NFCReaderDelegate>)delegate invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage;

/*!
* @method newWriterSessionWithDelegate:isLegacy:invalidateAfterFirstRead:alertMessage:
*
* @param delegate   The session reader delegate.
* @param legacy Define if you want to read tags using the old reader which may not support new tags.
* @param invalidate Invalidates session after first read.
* @param alertMessage   The session's alert message.
*
* @discussion   Use when you want to read and write information to your NFC Tags.
*/
- (void)newWriterSessionWithDelegate:(id <NFCReaderDelegate>)delegate isLegacy:(BOOL)legacy invalidateAfterFirstRead:(BOOL)invalidate alertMessage:(NSString *)alertMessage;

#pragma mark - Helper

@property (nonatomic, strong) NSString *detectedMessage;
@property (nonatomic, strong) NSString *alertMessage;
- (void)begin;
- (void)restart;
- (void)end;
- (BOOL)canWrite;


/*!
* @method createPayloadWithFormat:type:indetifier:message:
*
* @param format   NFC type name format.
* @param type Hex string payload message or value format.
* @param identifier Payload indetifier.
* @param payload   Payload message or value.
*
* @discussion   Use when creating NFC information payload.
*/
- (NFCNDEFPayload *)createPayloadWithFormat:(NFCTypeNameFormat)format type:(NSString *)type indetifier:(NSString *)identifier message:(NSString *)payload;

/*!
* @method messageWithPayloads:
*
* @param payloads   Payload information that is to be written into NFC tags.
*
* @discussion   Use along with createPayloadWithFormat:type:indetifier:message: and to enwrap payloads to a message.
*/
- (NFCNDEFMessage *)messageWithPayloads:(NSArray <NFCNDEFPayload *>*)payloads;

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(id<NFCNDEFTag>)tag completion:(void (^)( NSError * _Nullable ))completion;

- (NSString *)parseNFCError:(NSError *)error;

- (NSData *)tagIdentifierWithTag:(nonnull id<NFCTag>)tag;
- (NSString *)hexStringWithData:(NSData *)data isAddColons:(BOOL)isAddColons;


@end

NS_ASSUME_NONNULL_END
