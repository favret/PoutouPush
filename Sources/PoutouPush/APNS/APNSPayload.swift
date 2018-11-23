import Foundation

/**
*/
public enum APNSPriority: Int {
  case standard = 5
  case high = 10
}

// MARK: - Payload
/**
*/
public struct APNSPayload: Codable {
  enum CodingKeys: String, CodingKey {
    case body = "aps"
  }

  var body: APNSPayloadBody
  var header: APNSPayloadHeader?

  public init(body: APNSPayloadBody, header: APNSPayloadHeader? = nil) {
    self.body = body
    self.header = header
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    body = try container.decode(APNSPayloadBody.self, forKey: .body)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(body, forKey: .body)
  }
}

// MARK: - Header
/**
*/
public struct APNSPayloadHeader {
  var ttl: Int?
  var topic: String?
  var id: String?
  var priority: APNSPriority = .high

  public init(id: String? = nil, topic: String? = nil, ttl: Int? = nil, priority: APNSPriority = .high) {
    self.id = id
    self.topic = topic
    self.ttl = ttl
    self.priority = priority
  }
}

// MARK: - Body
/**
*/
public struct APNSPayloadBody: Codable {

  enum CodingKeys: String, CodingKey {
    case badge = "badge"
    case text = "alert"
    case sound = "sound"
    case extra = "extra"
  }

  var badge: Int?
  var text: APNSPayloadBodyText
  var sound: String?
  var extra: [String: String]?

  public init(text: APNSPayloadBodyText, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil) {
    self.text = text
    self.badge = badge
    self.sound = sound
    self.extra = extra
  }
}

public struct APNSPayloadBodyText: Codable {
  var title: String?
  var subtitle: String?
  var body: String
}

// MARK: - Certificate
/**
*/
public struct APNSCertificate {
  public var certPath: String
  public var keyPath: String?

  public init(certPath: String, keyPath: String? = nil) {
    self.certPath = certPath
    self.keyPath = keyPath
  }
}
