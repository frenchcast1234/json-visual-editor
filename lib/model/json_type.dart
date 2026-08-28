enum JsonType {
  string,
  integer,
  decimal,
  boolean,
  nil;

  static JsonType of(dynamic v) => switch (v) {
    String _ => string,
    int _ => integer,
    double _ => decimal,
    bool _ => boolean,
    _ => nil,
  };

  String get label => switch (this) {
    string => "string",
    integer => "int",
    decimal => "double",
    boolean => "bool",
    nil => "null",
  };

  dynamic parse(String raw) {
    final t = raw.trim();
    switch (this) {
      case string:
        return raw;
      case integer:
        final v = int.tryParse(t);
        if (v == null) throw FormatException("Not an integer", raw);
        return v;
      case decimal:
        final v = double.tryParse(t);
        if (v == null) throw FormatException("Not a number", raw);
        return v;
      case boolean:
        if (t.toLowerCase() == "true") return true;
        if (t.toLowerCase() == "false") return false;
        throw FormatException("Expected true or false", raw);
      case nil:
        return null;
    }
  }

  String format(dynamic v) => switch (this) {
    string => v is String ? v : "${v ?? ''}",
    nil => "null",
    _ => "$v",
  };

  dynamic coerce(dynamic v) {
    switch (this) {
      case string:
        return v == null ? "" : (v is String ? v : "$v");
      case integer:
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is bool) return v ? 1 : 0;
        return int.tryParse("$v".trim()) ?? 0;
      case decimal:
        if (v is double) return v;
        if (v is num) return v.toDouble();
        if (v is bool) return v ? 1.0 : 0.0;
        return double.tryParse("$v".trim()) ?? 0.0;
      case boolean:
        if (v is bool) return v;
        if (v is num) return v != 0;
        return "$v".trim().toLowerCase() == "true";
      case nil:
        return null;
    }
  }
}
