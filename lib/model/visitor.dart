import 'package:shyam_tiles/common/api_constant.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/common/request.dart';

class SalesmanItem {
  final int id;
  final String name;
  final String contact;
  final String location;

  SalesmanItem({
    required this.id,
    required this.name,
    required this.contact,
    required this.location,
  });

  factory SalesmanItem.fromJson(Map<String, dynamic> json) {
    return SalesmanItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}

class VisitorItem {
  final int id;
  final int receptionistId;
  final String visitorName;
  final String contact;
  final bool isConverted;
  final String? reason;
  final int? salesmanId;
  final String? salesmanName;
  final String? salesmanContact;
  final String createdAt;

  VisitorItem({
    required this.id,
    required this.receptionistId,
    required this.visitorName,
    required this.contact,
    required this.isConverted,
    this.reason,
    this.salesmanId,
    this.salesmanName,
    this.salesmanContact,
    required this.createdAt,
  });

  factory VisitorItem.fromJson(Map<String, dynamic> json) {
    final rawConverted = json['is_converted'];
    final bool converted = rawConverted == 1 ||
        rawConverted == '1' ||
        rawConverted == true;

    return VisitorItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      receptionistId: json['receptionist_id'] is int
          ? json['receptionist_id']
          : int.tryParse(json['receptionist_id'].toString()) ?? 0,
      visitorName: json['visitor_name']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      isConverted: converted,
      reason: json['reason']?.toString(),
      salesmanId: json['salesman_id'] != null
          ? (json['salesman_id'] is int
              ? json['salesman_id']
              : int.tryParse(json['salesman_id'].toString()))
          : null,
      salesmanName: json['salesman_name']?.toString(),
      salesmanContact: json['salesman_contact']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  bool get isCreatedToday {
    if (createdAt.isEmpty) return false;
    try {
      final DateTime dt = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      return createdAt.startsWith(todayStr);
    }
  }
}

class VisitorService {
  static Future<List<SalesmanItem>> fetchSalesmen({String? location}) async {
    try {
      final Map<String, dynamic> body = {};
      if (location != null && location.isNotEmpty) {
        body['location'] = location;
      }
      final ResponseSmartAuditor response = await Request.sharedInstance
          .postRequest(body, APIConstant.getSalesmen);

      if (response.status && response.body is List) {
        return (response.body as List)
            .map((item) => SalesmanItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      print("Error fetching salesmen: $e");
    }
    return [];
  }

  static Future<ResponseSmartAuditor> submitVisitor({
    required int receptionistId,
    required String visitorName,
    required String contact,
    required bool isConverted,
    String? reason,
    int? salesmanId,
  }) async {
    final Map<String, dynamic> body = {
      'receptionist_id': receptionistId,
      'visitor_name': visitorName,
      'contact': contact,
      'is_converted': isConverted ? 1 : 0,
      'reason': isConverted ? null : reason,
      'salesman_id': salesmanId,
    };

    return await Request.sharedInstance.postRequest(body, APIConstant.addVisitor);
  }

  static Future<ResponseSmartAuditor> updateVisitor({
    required int id,
    required int receptionistId,
    required String visitorName,
    required String contact,
    required bool isConverted,
    String? reason,
    int? salesmanId,
  }) async {
    final Map<String, dynamic> body = {
      'id': id,
      'receptionist_id': receptionistId,
      'visitor_name': visitorName,
      'contact': contact,
      'is_converted': isConverted ? 1 : 0,
      'reason': isConverted ? null : reason,
      'salesman_id': salesmanId,
    };

    return await Request.sharedInstance.postRequest(body, APIConstant.updateVisitor);
  }

  static Future<List<VisitorItem>> fetchVisitors(int receptionistId) async {
    try {
      final Map<String, dynamic> body = {
        'receptionist_id': receptionistId,
      };
      final ResponseSmartAuditor response = await Request.sharedInstance
          .postRequest(body, APIConstant.getVisitors);

      if (response.status && response.body is List) {
        return (response.body as List)
            .map((item) => VisitorItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      print("Error fetching visitors: $e");
    }
    return [];
  }
}
