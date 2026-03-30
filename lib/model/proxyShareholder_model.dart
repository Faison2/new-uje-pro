class ShareholderModel {
  String? shareholder;
  String? names;
  String? shares;
  String? vote;
  String? category;

  ShareholderModel(
      {this.shareholder, this.names, this.shares, this.vote, this.category});

  ShareholderModel.fromJson(Map<String, dynamic> json) {
    shareholder = json['shareholder'];
    names = json['Names'];
    shares = json['Shares'];
    vote = json['Vote'];
    category = json['Category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shareholder'] = this.shareholder;
    data['Names'] = this.names;
    data['Shares'] = this.shares;
    data['Vote'] = this.vote;
    data['Category'] = this.category;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
