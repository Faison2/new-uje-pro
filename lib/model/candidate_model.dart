class CandidateModel {
  String? resNo;
  String? iD;
  String? nomineeName;
  String? orderNumber;
  String? resExistingVote;
  String? resSEQ;

  CandidateModel(
      {this.resNo,
      this.iD,
      this.nomineeName,
      this.orderNumber,
      this.resExistingVote,
      this.resSEQ});

  CandidateModel.fromJson(Map<String, dynamic> json) {
    resNo = json['resNo'];
    iD = json['ID'];
    nomineeName = json['NomineeName'];
    orderNumber = json['OrderNumber'];
    resExistingVote = json['resExistingVote'];
    resSEQ = json['resSEQ'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resNo'] = this.resNo;
    data['ID'] = this.iD;
    data['NomineeName'] = this.nomineeName;
    data['OrderNumber'] = this.orderNumber;
    data['resExistingVote'] = this.resExistingVote;
    data['resSEQ'] = this.resSEQ;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
