import 'package:cloud_firestore/cloud_firestore.dart';

extension DocumentSnapshotExtension on DocumentSnapshot {
  Map<String, dynamic>? get dataAsMap {
    if (!exists) return null;
    return data() as Map<String, dynamic>?;
  }

  String getString(String key, {String defaultValue = ''}) {
    final data = dataAsMap;
    return data?[key] as String? ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    final data = dataAsMap;
    return data?[key] as int? ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    final data = dataAsMap;
    return data?[key] as double? ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final data = dataAsMap;
    return data?[key] as bool? ?? defaultValue;
  }

  Timestamp? getTimestamp(String key) {
    final data = dataAsMap;
    return data?[key] as Timestamp?;
  }

  DateTime? getDateTime(String key) {
    final timestamp = getTimestamp(key);
    return timestamp?.toDate();
  }

  List<T> getList<T>(String key, {List<T> defaultValue = const []}) {
    final data = dataAsMap;
    if (data == null || data[key] == null) return defaultValue;

    try {
      return List<T>.from(data[key] as List);
    } catch (e) {
      return defaultValue;
    }
  }

  Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    final data = dataAsMap;
    if (data == null || data[key] == null) return defaultValue;

    try {
      return Map<String, dynamic>.from(data[key] as Map);
    } catch (e) {
      return defaultValue;
    }
  }

  bool hasField(String key) {
    final data = dataAsMap;
    return data?.containsKey(key) ?? false;
  }

  T? getValue<T>(String key) {
    final data = dataAsMap;
    return data?[key] as T?;
  }
}

extension QuerySnapshotExtension on QuerySnapshot {
  List<Map<String, dynamic>> get documentsData {
    return docs.map((doc) => doc.dataAsMap ?? {}).toList();
  }

  Map<String, dynamic>? get firstDocumentData {
    if (docs.isEmpty) return null;
    return docs.first.dataAsMap;
  }

  Map<String, dynamic>? get lastDocumentData {
    if (docs.isEmpty) return null;
    return docs.last.dataAsMap;
  }

  bool get hasDocuments => docs.isNotEmpty;

  List<String> get documentIds => docs.map((doc) => doc.id).toList();
}

extension DocumentReferenceExtension on DocumentReference {
  Future<void> updateField(String field, dynamic value) async {
    await update({field: value});
  }

  Future<void> setDataMerge(Map<String, dynamic> data) async {
    await set(data, SetOptions(merge: true));
  }

  Future<void> incrementField(String field, num value) async {
    await update({field: FieldValue.increment(value)});
  }

  Future<void> decrementField(String field, num value) async {
    await update({field: FieldValue.increment(-value)});
  }

  Future<void> addToArray(String field, dynamic value) async {
    await update({
      field: FieldValue.arrayUnion([value]),
    });
  }

  Future<void> removeFromArray(String field, dynamic value) async {
    await update({
      field: FieldValue.arrayRemove([value]),
    });
  }
}

extension CollectionReferenceExtension on CollectionReference {
  Future<List<DocumentSnapshot>> getAllDocuments() async {
    final snapshot = await get();
    return snapshot.docs;
  }

  Query whereEquals(String field, dynamic value) {
    return where(field, isEqualTo: value);
  }

  Query whereIn(String field, List<dynamic> values) {
    return where(field, whereIn: values);
  }

  Query orderByDesc(String field) {
    return orderBy(field, descending: true);
  }

  Query orderByAsc(String field) {
    return orderBy(field, descending: false);
  }

  Query limitTo(int count) {
    return limit(count);
  }
}

extension TimestampExtension on Timestamp {
  String toFormattedString({String format = 'dd/MM/yyyy HH:mm'}) {
    final date = toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    final now = DateTime.now();
    final date = toDate();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final date = toDate();
    return yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
  }

  String get timeAgo {
    final now = DateTime.now();
    final date = toDate();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "year" : "years"} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else {
      return 'Just now';
    }
  }
}
