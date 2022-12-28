const crystalSchema = {
  "$id": "https://example.com/geographical-location.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "A Crystal Found",
  "description": "A geographical coordinate and data of a Crystal.",
  "required": [ "latitude", "longitude" ],
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "filename": {
      "type": "string"
    },
    "id": {
      "type": "number",
      "minimum": 1
    },
    "dropfreq": {
      "type": "number"
    },
    "desc": {
      "type": "string"
    },
    "value": {
      "type": "number"
    },
    "condition": {
      "type": "string"
    },
    "grading": {
      "type": "number",
      "minimum": 1,
      "maximum": 100
    },
    "effects": {
      "type": "array"
    },
    "latitude": {
      "type": "number",
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": "number",
      "minimum": -180,
      "maximum": 180
    }
  }
};
module.exports = crystalSchema;

// A crystal has: 
// A name 
// A fule name 
// Type 
// Lat and long 
// Drop frequency 
// Description 
// Value 
// Condition(raw,tumbled,cracked,geode) 
// Grading 
// Effects 

// String values MUST be one of the six primitive types ("null", "boolean", "object", "array", "number", or "string"),