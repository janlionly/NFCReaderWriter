//
//  NFCNDEFWriter.h
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/2.
//

#import <Foundation/Foundation.h>
#import "NFCReader.h"

NS_ASSUME_NONNULL_BEGIN
// iOS 13
@interface NFCNDEFWriter : NFCReader

- (void)writeMessage:(NFCNDEFMessage *)message toTag:(nonnull id<NFCNDEFTag>)tag connectHandler:(nonnull void(^)(NSError *_Nullable error))connectHandler queryHandler:(nonnull void(^)(NFCNDEFStatus status, NSUInteger capacity, NSError *_Nullable error))queryHandler writeHandler:(nonnull void(^)(NSError *_Nullable error))writeHandler;

@end

NS_ASSUME_NONNULL_END
