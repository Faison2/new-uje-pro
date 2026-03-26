class VoterModel {
  int? responseCode;
  String? agmID;
  String? company;
  String? meetingInfo;
  String? cDSNo;
  String? names;
  String? shares;
  String? regStatus;
  List<ResItem>? resItem;

  VoterModel(
      {this.responseCode,
      this.agmID,
      this.company,
      this.meetingInfo,
      this.cDSNo,
      this.names,
      this.shares,
      this.regStatus,
      this.resItem});

  VoterModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
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
  String? resExistingVote;

  ResItem(
      {this.sEQ, this.resNo, this.resText, this.resType, this.resExistingVote});

  ResItem.fromJson(Map<String, dynamic> json) {
    sEQ = json['SEQ'];
    resNo = json['resNo'];
    resText = json['resText'];
    resType = json['resType'];
    resExistingVote = json['resExistingVote'];
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
