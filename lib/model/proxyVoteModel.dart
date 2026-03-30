class ProxyVoterModel {
  int? responseCode;
  String? voteCode;
  String? agmID;
  String? company;
  String? meetingInfo;
  String? cDSNo;
  String? names;
  String? shares;
  String? regStatus;
  List<ResItem>? resItem;

  ProxyVoterModel(
      {this.responseCode,
      this.voteCode,
      this.agmID,
      this.company,
      this.meetingInfo,
      this.cDSNo,
      this.names,
      this.shares,
      this.regStatus,
      this.resItem});

  ProxyVoterModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    voteCode = json['voteCode'];
    agmID = json['agmID'];
    company = json['Company'];
    meetingInfo = json['MeetingInfo'];
    cDSNo = json['CDSNo'];
    names = json['Names'];
    shares = json['Shares'];
    regStatus = json['RegStatus'];
    if (json['resItem'] != null) {
      resItem = <ResItem>[];
      json['resItem'].forEach((v) {
        resItem!.add(new ResItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['voteCode'] = this.voteCode;
    data['agmID'] = this.agmID;
    data['Company'] = this.company;
    data['MeetingInfo'] = this.meetingInfo;
    data['CDSNo'] = this.cDSNo;
    data['Names'] = this.names;
    data['Shares'] = this.shares;
    data['RegStatus'] = this.regStatus;
    if (this.resItem != null) {
      data['resItem'] = this.resItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResItem {
  String? sEQ;
  String? resNo;
  String? resText;
  String? resType;

  ResItem(
      {this.sEQ, this.resNo, this.resText, this.resType});

  ResItem.fromJson(Map<String, dynamic> json) {
    sEQ = json['SEQ'];
    resNo = json['resNo'];
    resText = json['resText'];
    resType = json['resType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SEQ'] = this.sEQ;
    data['resNo'] = this.resNo;
    data['resText'] = this.resText;
    data['resType'] = this.resType;
    return data;
  }
}
