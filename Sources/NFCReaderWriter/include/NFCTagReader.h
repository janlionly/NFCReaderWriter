//
//  NFCTagReader.h
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/3.
//

#import <Foundation/Foundation.h>
#import "NFCReader.h"

NS_ASSUME_NONNULL_BEGIN
// iOS 13
@interface NFCTagReader : NFCReader

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(nonnull id<NFCTag>)tag connectHandler:(nonnull void(^)(NSError *_Nullable error))connectHandler writeHandler:(nonnull void(^)(NFCNDEFStatus status, NSUInteger capacity, NSError *_Nullable error))writeHandler;
- (NSData *)tagIdentifierWithTag:(nonnull id<NFCTag>)tag;
- (NSString *)convertDataBytesToHex:(NSData *)dataBytes isAddColons:(BOOL)isAddColons;

@end

NS_ASSUME_NONNULL_END
