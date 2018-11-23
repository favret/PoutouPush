import CCurl
import Foundation

/**
*/
public enum APNSServer: String {
  case sandbox = "https://api.development.push.apple.com"
  case production = "https://api.push.apple.com"
}

/**
*/
public class APNS {

  private var certificate: APNSCertificate
  private var server: APNSServer
  private var curl: UnsafeMutableRawPointer

  public init(certificate: APNSCertificate, server: APNSServer = .sandbox) {
    curl = curl_easy_init()

    self.certificate = certificate
    self.server = server

    curlHelperSetOptBool(curl, CURLOPT_VERBOSE, 1)

    curlHelperSetOptString(curl, CURLOPT_SSLCERT, certificate.certPath)
    curlHelperSetOptString(curl, CURLOPT_SSLCERTTYPE, "PEM")

    if let keyPath = certificate.keyPath {
      curlHelperSetOptString(curl, CURLOPT_SSLKEY, keyPath)
      curlHelperSetOptString(curl, CURLOPT_SSLKEYTYPE, "PEM")
    }

    // force protocol to http2
    curlHelperSetOptInt(curl, CURLOPT_HTTP_VERSION, 3)
  }

  private func build(body: APNSPayload) -> UnsafeMutablePointer<Int8>? {
    let encoder = JSONEncoder()
    guard
      let data = try? encoder.encode(body),
      let stringData = String(data: data, encoding: .utf8) else {
      return nil
    }
    let cs = NSString(string: "\(stringData)").utf8String
    return UnsafeMutablePointer<Int8>(mutating: cs)
  }

  private func build(header: APNSPayloadHeader?) -> UnsafeMutablePointer<curl_slist>? {
    guard let header = header else {
      return nil
    }

    var headers: UnsafeMutablePointer<curl_slist>?

    curlHelperSetOptBool(curl, CURLOPT_HEADER, 1)
    headers = curl_slist_append(headers, "Accept: application/json")
    headers = curl_slist_append(headers, "Content-Type: application/json")
    headers = curl_slist_append(headers, "apns-priority: \(header.priority .rawValue)")

    if let ttl = header.ttl {
      headers = curl_slist_append(headers, "apns-expiration: \(ttl)")
    }

    if let topic = header.topic {
      headers = curl_slist_append(headers, "apns-topic: \(topic)")
    }

    if let id = header.id {
      headers = curl_slist_append(headers, "apns-id: \(id)")
    }

    return headers
  }

  // MARK: - Push notification
  public func push(text: APNSPayloadBodyText, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil, to tokens: [String]) {
    tokens.forEach { self.push(text: text, badge: badge, sound: sound, extra: extra, to: $0) }
  }

  public func push(text: APNSPayloadBodyText, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil, to token: String) {
    let body = APNSPayloadBody(text: text, badge: badge, sound: sound, extra: extra)
    let payload = APNSPayload(body: body)
    self.push(payload: payload, to: token)
  }

  public func push(payload: APNSPayload, to tokens: [String]) {
      tokens.forEach { self.push(payload: payload, to: $0) }
  }

  public func push(payload: APNSPayload, to token: String) {
    guard let body = build(body: payload) else {
      return
    }

    curlHelperSetOptString(curl, CURLOPT_URL, (server.rawValue + "/3/device/\(token)"))
    curlHelperSetOptBool(curl, CURLOPT_VERBOSE, CURL_TRUE)
    curlHelperSetOptBool(curl, CURLOPT_FOLLOWLOCATION, CURL_TRUE)
    curlHelperSetOptBool(curl, CURLOPT_POST, CURL_TRUE)
    curlHelperSetOptInt(curl, CURLOPT_PORT, 443)

    curlHelperSetOptString(curl, CURLOPT_POSTFIELDS, body)

    if let header = build(header: payload.header) {
      curlHelperSetOptList(curl, CURLOPT_HTTPHEADER, header)
    }

    let ret = curl_easy_perform(curl)

    print("ret = \(ret)")

    if ret != CURLE_OK {
      let error = curl_easy_strerror(ret)
      print(String(utf8String: error!)!)
    }
  }

}
