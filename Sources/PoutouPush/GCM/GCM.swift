import CCurl
import Foundation

/**
*/
public class GCM {
  private let server = "https://gcm-http.googleapis.com/gcm/send"

  private var serverKey: String
  private var curl: UnsafeMutableRawPointer

  public init(serverKey: String) {
    curl = curl_easy_init()

    self.serverKey = serverKey

    curlHelperSetOptBool(curl, CURLOPT_VERBOSE, 1)

    // force protocol to http2
    curlHelperSetOptInt(curl, CURLOPT_HTTP_VERSION, 3)
  }

  private func build(body: GCMPayload) -> UnsafeMutablePointer<Int8>? {
    let encoder = JSONEncoder()
    guard
      let data = try? encoder.encode(body),
      let stringData = String(data: data, encoding: .utf8) else {
      return nil
    }

    print("========")
    print(stringData)
    print("========")

    let cs = NSString(string: "\(stringData)").utf8String
    return UnsafeMutablePointer<Int8>(mutating: cs)
  }

  // MARK: - Push notification
  public func push(title: String, text: String, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil, to tokens: [String]) {
    tokens.forEach { self.push(title: title, text: text, badge: badge, sound: sound, extra: extra, to: $0) }
  }

  public func push(title: String, text: String, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil, to token: String) {
    let body = GCMPayloadBody(title: title, text: text, badge: badge, sound: sound, extra: extra)
    let payload = GCMPayload(body: body, to: token)

    self.push(payload: payload)
  }

  public func push(payload: GCMPayload) {
    guard let body = build(body: payload) else {
      return
    }

    var headers: UnsafeMutablePointer<curl_slist>?

    curlHelperSetOptBool(curl, CURLOPT_HEADER, 1)
    headers = curl_slist_append(headers, "Accept: application/json")
    headers = curl_slist_append(headers, "Content-Type: application/json")
    headers = curl_slist_append(headers, "Authorization: key=\(serverKey)")

    curlHelperSetOptString(curl, CURLOPT_URL, server)
    curlHelperSetOptBool(curl, CURLOPT_VERBOSE, CURL_TRUE)
    curlHelperSetOptBool(curl, CURLOPT_FOLLOWLOCATION, CURL_TRUE)
    curlHelperSetOptBool(curl, CURLOPT_POST, CURL_TRUE)

    curlHelperSetOptString(curl, CURLOPT_POSTFIELDS, body)
    curlHelperSetOptList(curl, CURLOPT_HTTPHEADER, headers)

    let ret = curl_easy_perform(curl)

    print("ret = \(ret)")

    if ret != CURLE_OK {
      let error = curl_easy_strerror(ret)
      print(String(utf8String: error!)!)
    }
  }

}
