class Faq {
  final String id;
  final String question;
  final String answer;

  Faq({required this.id, required this.question, required this.answer});

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'].toString(),
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class ContactDetail {
  final String id;
  final String label;
  final String value;
  final String icon;

  ContactDetail({
    required this.id,
    required this.label,
    required this.value,
    required this.icon,
  });

  factory ContactDetail.fromJson(Map<String, dynamic> json) {
    return ContactDetail(
      id: json['id'].toString(),
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      icon: json['icon'] ?? 'phone',
    );
  }
}
