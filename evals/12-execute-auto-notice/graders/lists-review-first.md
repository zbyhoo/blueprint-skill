---
type: regex
target: trace
---
"type":"assistant"(?=[^\n]*"type":"text")(?=[^\n]*\bQ2\b)(?=[^\n]*(?:[Aa]ssum|Review first))[^\n]*\n[\s\S]*?"type":"tool_use"[^\n]*?"name":"(?:Write|Bash)"
