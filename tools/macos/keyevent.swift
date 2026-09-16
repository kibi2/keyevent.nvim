import AppKit

let delay = NSEvent.keyRepeatDelay * 1000
let interval = NSEvent.keyRepeatInterval * 1000

print("""
{"delay":\(Int(delay)),"interval":\(Int(interval))}
""")