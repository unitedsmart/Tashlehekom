import 'package:uuid/uuid.dart';

/// نموذج طلب التمويل
class FinanceApplication {
  final String id;
  final String userId;
  final String carId;
  final double carPrice;
  final double downPayment;
  final double loanAmount;
  final int loanTermMonths;
  final double interestRate;
  final double monthlyPayment;
  final FinanceStatus status;
  final String bankId;
  final Map<String, dynamic> documents;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  FinanceApplication({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carPrice,
    required this.downPayment,
    required this.loanAmount,
    required this.loanTermMonths,
    required this.interestRate,
    required this.monthlyPayment,
    required this.status,
    required this.bankId,
    required this.documents,
    required this.appliedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  factory FinanceApplication.fromJson(Map<String, dynamic> json) {
    return FinanceApplication(
      id: json['id'],
      userId: json['userId'],
      carId: json['carId'],
      carPrice: json['carPrice'].toDouble(),
      downPayment: json['downPayment'].toDouble(),
      loanAmount: json['loanAmount'].toDouble(),
      loanTermMonths: json['loanTermMonths'],
      interestRate: json['interestRate'].toDouble(),
      monthlyPayment: json['monthlyPayment'].toDouble(),
      status: FinanceStatus.values[json['status']],
      bankId: json['bankId'],
      documents: Map<String, dynamic>.from(json['documents']),
      appliedAt: DateTime.parse(json['appliedAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carPrice': carPrice,
      'downPayment': downPayment,
      'loanAmount': loanAmount,
      'loanTermMonths': loanTermMonths,
      'interestRate': interestRate,
      'monthlyPayment': monthlyPayment,
      'status': status.index,
      'bankId': bankId,
      'documents': documents,
      'appliedAt': appliedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }
}

enum FinanceStatus {
  pending,
  underReview,
  approved,
  rejected,
  cancelled,
  active,
  completed,
}

/// نموذج البنك الشريك
class PartnerBank {
  final String id;
  final String name;
  final String nameAr;
  final String logo;
  final double minInterestRate;
  final double maxInterestRate;
  final int minLoanTerm;
  final int maxLoanTerm;
  final double minLoanAmount;
  final double maxLoanAmount;
  final List<String> requiredDocuments;
  final Map<String, dynamic> eligibilityCriteria;
  final bool isActive;

  PartnerBank({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logo,
    required this.minInterestRate,
    required this.maxInterestRate,
    required this.minLoanTerm,
    required this.maxLoanTerm,
    required this.minLoanAmount,
    required this.maxLoanAmount,
    required this.requiredDocuments,
    required this.eligibilityCriteria,
    required this.isActive,
  });
}

/// نموذج حاسبة التمويل
class FinanceCalculation {
  final String id;
  final double carPrice;
  final double downPayment;
  final double loanAmount;
  final int loanTermMonths;
  final double interestRate;
  final double monthlyPayment;
  final double totalInterest;
  final double totalAmount;
  final List<PaymentSchedule> paymentSchedule;
  final DateTime calculatedAt;

  FinanceCalculation({
    required this.id,
    required this.carPrice,
    required this.downPayment,
    required this.loanAmount,
    required this.loanTermMonths,
    required this.interestRate,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalAmount,
    required this.paymentSchedule,
    required this.calculatedAt,
  });
}

class PaymentSchedule {
  final int paymentNumber;
  final DateTime dueDate;
  final double paymentAmount;
  final double principalAmount;
  final double interestAmount;
  final double remainingBalance;

  PaymentSchedule({
    required this.paymentNumber,
    required this.dueDate,
    required this.paymentAmount,
    required this.principalAmount,
    required this.interestAmount,
    required this.remainingBalance,
  });
}

/// نموذج عرض التمويل
class FinanceOffer {
  final String id;
  final String bankId;
  final String userId;
  final String carId;
  final double interestRate;
  final int loanTermMonths;
  final double monthlyPayment;
  final double totalAmount;
  final List<String> benefits;
  final List<String> conditions;
  final DateTime validUntil;
  final bool isPreApproved;

  FinanceOffer({
    required this.id,
    required this.bankId,
    required this.userId,
    required this.carId,
    required this.interestRate,
    required this.loanTermMonths,
    required this.monthlyPayment,
    required this.totalAmount,
    required this.benefits,
    required this.conditions,
    required this.validUntil,
    required this.isPreApproved,
  });
}

/// نموذج التأمين
class InsuranceQuote {
  final String id;
  final String carId;
  final String userId;
  final String insuranceCompany;
  final InsuranceType type;
  final double annualPremium;
  final double coverage;
  final List<String> benefits;
  final Map<String, dynamic> terms;
  final DateTime validUntil;

  InsuranceQuote({
    required this.id,
    required this.carId,
    required this.userId,
    required this.insuranceCompany,
    required this.type,
    required this.annualPremium,
    required this.coverage,
    required this.benefits,
    required this.terms,
    required this.validUntil,
  });
}

enum InsuranceType {
  thirdParty,
  comprehensive,
  againstOthers,
}

/// نموذج خطة الدفع
class PaymentPlan {
  final String id;
  final String userId;
  final String carId;
  final double totalAmount;
  final double downPayment;
  final int installments;
  final double installmentAmount;
  final PaymentFrequency frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<InstallmentSchedule> schedule;

  PaymentPlan({
    required this.id,
    required this.userId,
    required this.carId,
    required this.totalAmount,
    required this.downPayment,
    required this.installments,
    required this.installmentAmount,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.schedule,
  });
}

enum PaymentFrequency {
  weekly,
  biweekly,
  monthly,
  quarterly,
}

class InstallmentSchedule {
  final int installmentNumber;
  final DateTime dueDate;
  final double amount;
  final InstallmentStatus status;
  final DateTime? paidAt;

  InstallmentSchedule({
    required this.installmentNumber,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.paidAt,
  });
}

enum InstallmentStatus {
  pending,
  paid,
  overdue,
  cancelled,
}
