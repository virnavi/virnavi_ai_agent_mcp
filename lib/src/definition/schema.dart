/// Base class for all JSON Schema types used in tool input definitions.
abstract class SchemaType {
  Map<String, dynamic> toJson();
}

/// JSON Schema type for string values.
class StringSchema extends SchemaType {
  final String? description;
  final List<String>? enumValues;

  StringSchema({this.description, this.enumValues});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'string',
        if (description != null) 'description': description,
        if (enumValues != null) 'enum': enumValues,
      };
}

/// JSON Schema type for integer values.
class IntegerSchema extends SchemaType {
  final String? description;
  final int? minimum;
  final int? maximum;

  IntegerSchema({this.description, this.minimum, this.maximum});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'integer',
        if (description != null) 'description': description,
        if (minimum != null) 'minimum': minimum,
        if (maximum != null) 'maximum': maximum,
      };
}

/// JSON Schema type for numeric (double/int) values.
class NumberSchema extends SchemaType {
  final String? description;
  final num? minimum;
  final num? maximum;

  NumberSchema({this.description, this.minimum, this.maximum});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'number',
        if (description != null) 'description': description,
        if (minimum != null) 'minimum': minimum,
        if (maximum != null) 'maximum': maximum,
      };
}

/// JSON Schema type for boolean values.
class BooleanSchema extends SchemaType {
  final String? description;

  BooleanSchema({this.description});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'boolean',
        if (description != null) 'description': description,
      };
}

/// JSON Schema type for array values.
class ArraySchema extends SchemaType {
  final String? description;
  final SchemaType items;

  ArraySchema({this.description, required this.items});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'array',
        'items': items.toJson(),
        if (description != null) 'description': description,
      };
}

/// JSON Schema type for object values with named properties.
class ObjectSchema extends SchemaType {
  final String? description;
  final Map<String, SchemaType> properties;
  final List<String> required;

  ObjectSchema({
    this.description,
    this.properties = const {},
    this.required = const [],
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'object',
        if (description != null) 'description': description,
        if (properties.isNotEmpty)
          'properties': {
            for (final e in properties.entries) e.key: e.value.toJson(),
          },
        if (required.isNotEmpty) 'required': required,
      };
}
