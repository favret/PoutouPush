[![codebeat badge](https://codebeat.co/badges/451364c0-f051-4278-9063-6739e24ab61f)](https://codebeat.co/projects/github-com-favret-poutoupush-master)

# PoutouPush
Swift server side push notification. APNS and GCM.

Works on Kitura, not tested on Perfect and Vapor, but it should work too.

## Getting Started

### Prerequisites

First, you need to install curl with http2 and install swift

#### Ubuntu
``` sh
# install curl with http2
sudo apt-get install build-essential nghttp2 libnghttp2-dev
wget https://curl.haxx.se/download/curl-7.54.0.tar.bz2
tar -xvjf curl-7.54.0.tar.bz2
cd curl-7.54.0
./configure --with-nghttp2 --prefix=/usr/local
make
sudo make install
sudo ldconfig

# install swift
wget https://swift.org/builds/swift-4.0-release/ubuntu1604/swift-4.0-RELEASE/swift-4.0-RELEASE-ubuntu16.04.tar.gz
tar -zxvf swift-4.0-RELEASE-ubuntu16.04.tar.gz
export PATH=/path/to/swift-4.0-RELEASE-ubuntu16.04.tar.gz/usr/bin/:"${PATH}"
apt-get update
sudo apt-get install git cmake ninja-build clang uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config
```

#### Mac OS
```sh
# install cURL with nghttp2 support
brew install curl --with-nghttp2

# link the formula to replace the system cURL
brew link curl --force
```

### Installing

#### swift package manager

```swift
import PackageDescription

let package = Package(
    name: "projectName",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/favret/PoutouPush.git", from: "0.0.3")
    ]
    ...
```

### Example

#### APNS
```swift
let apns = APNS.init(certificate: APNSCertificate(certPath: "/path/to/cert.pem"))

# Simple apns push
apns.push(text: "poutou poutou poutooooouuuuuu", to: "token") // Multiple token => to: ["token1", "token2", "token3"]


# Custom apns push
let body = APNSPayloadBody(text: "Text", sound: "hey.caf", badge: 5) // create a body
let header = APNSPayloadHeader(id: "123", topic: "MyTopic", ttl: 0, priority: .high) //create a header (optional)
let payload = APNSPayload(body: body, header: header) //use body and header to create the payload
apns.push(payload: payload, to: "cbe13970c9756dbccced18f777f66bdb2e227bcc58224f6f031a69b79e6045b9") //push it. Multiple token => to: ["token1", "token2", "token3"]
```

#### GCM
```swift
let gcm = GCM.init(serverKey: "SERVER_KEY")

# Simple gcm push
gcm.push(text: "poutou poutou poutooooouuuuuu", to: "token") // Multiple token => to: ["token1", "token2", "token3"]

# Custom gcm push
let body = GCMPayloadBody(title: "POUTOU", text: "poutou poutou poutouuuuu", badge: 5, sound: "poutou.caf") //create body
let payload = GCMPayload(body: body, to: "token") //create payload
gcm.push(payload: payload) //push it. Multiple token => to: ["token1", "token2", "token3"]
```
