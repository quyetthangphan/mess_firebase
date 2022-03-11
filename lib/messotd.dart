class MessOTD {
  String text;
  String phone;
  String to;
  String time;
  bool seen;
  MessOTD({this.text, this.phone, this.to, this.time, this.seen});

  Map<String, dynamic> toJson() => {
        'text': text,
        'phone': phone,
        'to': to,
        'time': time,
        'seen': false,
      };
}
