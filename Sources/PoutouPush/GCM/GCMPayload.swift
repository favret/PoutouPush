import Foundation

// MARK: - Payload
/**
*/
public struct GCMPayload: Codable {
  enum CodingKeys: String, CodingKey {
    case body = "notification"
    case token = "to"
  }

  var body: GCMPayloadBody
  var token: String
  var header: GCMPayloadHeader?

  public init(body: GCMPayloadBody, header: GCMPayloadHeader? = nil, to token: String) {
    self.body = body
    self.header = header
    self.token = token
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    body = try container.decode(GCMPayloadBody.self, forKey: .body)
    token = try container.decode(String.self, forKey: .token)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(body, forKey: .body)
    try container.encode(token, forKey: .token)
  }
}
// MARK: - Header
/**
*/
public struct GCMPayloadHeader {
  var ttl: Int?
  var topic: String?
  var id: String?

  public init(id: String? = nil, topic: String? = nil, ttl: Int? = nil) {
    self.id = id
    self.topic = topic
    self.ttl = ttl
  }
}

// MARK: - Body
/**
*/
public struct GCMPayloadBody: Codable {

  enum CodingKeys: String, CodingKey {
    case badge = "badge"
    case title = "title"
    case text = "text"
    case sound = "sound"
    case extra = "extra"
  }

  var badge: Int?
  var title = ""
  var text = ""
  var sound: String?
  var extra: [String: String]?

  public init(title: String, text: String, badge: Int? = nil, sound: String? = nil, extra: [String: String]? = nil) {
    self.title = title
    self.text = text
    self.badge = badge
    self.sound = sound
    self.extra = extra
  }
}
