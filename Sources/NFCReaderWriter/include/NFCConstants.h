//
//  NFCConstants.h
//  Pods-NFCReaderWriter
//
//  Created by janlionly on 2020/6/2.
//

#import <Foundation/Foundation.h>

#pragma mark - Session Error

NSString *const SESSION_ALERT_MESSAGE = @"Hold your iPhone near the item to learn more about it.";

#pragma mark - Reading Error

NSString *const ErrorFirstNDEFTagRead = @"";
NSString *const ErrorUserCanceled = @"";
NSString *const ErrorSessionTimeout = @"";
NSString *const ErrorSystemIsBusy = @"";
NSString *const ErrorSessionTerminatedUnexpectedly = @"";
NSString *const ErrorUnsupportedFeature = @"";

NSString *const ErrorTooManyTagDectected = @"More than 1 tag is detected. Please remove all tags and try again.";

#pragma mark - Status Error

NSString *const StatusConnectionFailed = @"Unable to connect to tag.";
NSString *const StatusQueryFailed = @"Unable to query the NDEF status of tag.";
NSString *const StatusNotSupported = @"Tag is not NDEF compliant.";;
NSString *const StatusReadOnly = @"Tag is read only.";
NSString *const StatusReadWriteError = @"Write NDEF message fail.";
NSString *const StatusReadWriteSuccessful = @"Write NDEF message successful.";
NSString *const StatusUnknown = @"Unknown NDEF tag status.";
