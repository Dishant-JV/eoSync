class ScanApiModel {
  String? statusCode;
  String? statusMessage;
  String? accountCode;

  ScanApiModel({this.statusCode, this.statusMessage, this.accountCode});

  ScanApiModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    accountCode = json['accountCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['statusMessage'] = this.statusMessage;
    data['accountCode'] = this.accountCode;
    return data;
  }
}