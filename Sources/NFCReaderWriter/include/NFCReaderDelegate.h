//
//  NFCReaderDelegate.h
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/2.
//

#import <CoreNFC/CoreNFC.h>

NS_ASSUME_NONNULL_BEGIN

@class NFCReader;

@protocol NFCReaderDelegate <NSObject>

@required

/*!
 * @method reader:didInvalidateWithError:
 *
 * @param session   The session object that is invalidated.
 * @param error     The error indicates the invalidation reason.
 *
 * @discussion      Gets called when a session becomes invalid.  At this point the client is expected to discard
 *                  the returned session object.
 */
- (void)reader:(NFCReader *)session didInvalidateWithError:(NSError *)error;

@optional

/*!
 * @method reader:didDetectTags:
 *
 * @param session   The session object used for NDEF tag detection.
 * @param tags      Array of @link NFCNDEFTag @link/ objects.
 *
 * @discussion      Gets called when the reader detects NDEF tag(s) in the RF field.  Presence of this method overrides -readerSession:didDetectNDEFs: and enables
 *                  read-write capability for the session.
 */
- (void)reader:(NFCReader *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags;

/*!
 * @method readerDidBecomeActive:
 *
 * @param session   The session object in the active state.
 *
 * @discussion      Gets called when the NFC reader session has become active. RF is enabled and reader is scanning for tags.
 */
- (void)readerDidBecomeActive:(NFCReader *)session;

/*!
 * @method reader:didDetectNDEFs:
 *
 * @param session   The session object used for tag detection.
 * @param messages  Array of @link NFCNDEFMessage @link/ objects.
 *
 * @discussion      Gets called when the reader detects NFC tag(s) with NDEF messages in the polling sequence.  Polling
 *                  is automatically restarted once the detected tag is removed from the reader's read range.  This method
 *                  is only get call if the optional -readerSession:didDetectTags: method is not
 *                  implemented.
 */
- (void)reader:(NFCReader *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(watchos, macos, tvos);

/*!
 * @method reader:didDetectTag:didDetectNDEF:
 *
 * @param session   The session object used for tag detection.
 * @param tag      NFCTag @link/ objects.
 */
- (void)reader:(NFCReader *)session didDetectTag:(__kindof id<NFCTag>)tag didDetectNDEF:(NFCNDEFMessage *)message API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos);

@end

NS_ASSUME_NONNULL_END
