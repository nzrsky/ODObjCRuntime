# ODObjCRuntime

[![Version](https://img.shields.io/cocoapods/v/ODObjCRuntime.svg?style=flat)](http://cocoapods.org/pods/ODObjCRuntime)
[![License](https://img.shields.io/cocoapods/l/ODObjCRuntime.svg?style=flat)](http://cocoapods.org/pods/ODObjCRuntime)
[![Platform](https://img.shields.io/cocoapods/p/ODObjCRuntime.svg?style=flat)](http://cocoapods.org/pods/ODObjCRuntime)

ODObjCRuntime is set of classes for working with ObjC Runtime.

## Usage

```objective-c
#import <ODObjCRuntime.h>

// All methods of current class
NSArray<ODObjCMethod *> *methods = [self.class od_methods];

```

## Installation

ODObjCRuntime is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ODObjCRuntime"
```

## Author

Alexey Nazaroff, alexx.nazaroff@gmail.com

## License

ODObjCRuntime is available under the MIT license. See the LICENSE file for more info.
