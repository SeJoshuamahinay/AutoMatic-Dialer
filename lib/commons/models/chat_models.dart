class ChatTemplate {
  final int id;
  final String subject;
  final String body;
  final int createdBy;
  final int? updatedBy;
  final String createdAt;
  final String? updatedAt;
  final ChatTemplateCreator? creator;

  const ChatTemplate({
    required this.id,
    required this.subject,
    required this.body,
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    this.updatedAt,
    this.creator,
  });

  factory ChatTemplate.fromJson(Map<String, dynamic> json) {
    return ChatTemplate(
      id: (json['id'] as num).toInt(),
      subject: json['subject']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdBy: (json['created_by'] as num?)?.toInt() ?? 0,
      updatedBy: (json['updated_by'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      creator: json['creator'] != null
          ? ChatTemplateCreator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ChatTemplateCreator {
  final int id;
  final String firstName;
  final String lastName;

  const ChatTemplateCreator({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory ChatTemplateCreator.fromJson(Map<String, dynamic> json) {
    return ChatTemplateCreator(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
    );
  }
}

class ChatLog {
  final int id;
  final int chatTemplateId;
  final int userId;
  final int? borrowerId;
  final int? loanId;
  final String message;
  final String sentAt;
  final String createdAt;
  final String updatedAt;
  final String? deliveryStatus;
  final String? deliveredAt;
  final String? deliveryError;

  const ChatLog({
    required this.id,
    required this.chatTemplateId,
    required this.userId,
    this.borrowerId,
    this.loanId,
    required this.message,
    required this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryStatus,
    this.deliveredAt,
    this.deliveryError,
  });

  factory ChatLog.fromJson(Map<String, dynamic> json) {
    return ChatLog(
      id: (json['id'] as num).toInt(),
      chatTemplateId: (json['chat_template_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      borrowerId: (json['borrower_id'] as num?)?.toInt(),
      loanId: (json['loan_id'] as num?)?.toInt(),
      message: json['message']?.toString() ?? '',
      sentAt: json['sent_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deliveryStatus: json['delivery_status']?.toString(),
      deliveredAt: json['delivered_at']?.toString(),
      deliveryError: json['delivery_error']?.toString(),
    );
  }
}
