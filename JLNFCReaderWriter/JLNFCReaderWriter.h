//
//  JLNFCReaderWriter.h
//  JLNFCReaderWriter
//
//  Created by janlionly on 2020/6/5.
//  Copyright © 2020 janlionly. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JLNFCReaderWriter.
FOUNDATION_EXPORT double JLNFCReaderWriterVersionNumber;

//! Project version string for JLNFCReaderWriter.
FOUNDATION_EXPORT const unsigned char JLNFCReaderWriterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JLNFCReaderWriter/PublicHeader.h>
#if __has_include("NFCConstants.h")
#import <JLNFCReaderWriter/NFCConstants.h>
#endif

#if __has_include("NFCReaderDelegate.h")
#import <JLNFCReaderWriter/NFCReaderDelegate.h>
#endif

#if __has_include("NFCReaderWriter.h")
#import <JLNFCReaderWriter/NFCReaderWriter.h>
#endif

#if __has_include("NFCReader.h")
#import <JLNFCReaderWriter/NFCReader.h>
#endif

#if __has_include("NFCNDEFReader.h")
#import <JLNFCReaderWriter/NFCNDEFReader.h>
#endif

#if __has_include("NFCNDEFWriter.h")
#import <JLNFCReaderWriter/NFCNDEFWriter.h>
#endif

#if __has_include("NFCTagReader.h")
#import <JLNFCReaderWriter/NFCTagReader.h>
#endif

