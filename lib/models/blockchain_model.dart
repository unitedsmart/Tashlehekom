import 'package:uuid/uuid.dart';

/// نموذج سجل الملكية اللامركزي
class BlockchainOwnership {
  final String id;
  final String carId;
  final String currentOwnerId;
  final List<OwnershipRecord> ownershipHistory;
  final String blockchainHash;
  final String smartContractAddress;
  final DateTime lastUpdated;
  final bool isVerified;

  BlockchainOwnership({
    required this.id,
    required this.carId,
    required this.currentOwnerId,
    required this.ownershipHistory,
    required this.blockchainHash,
    required this.smartContractAddress,
    required this.lastUpdated,
    required this.isVerified,
  });

  factory BlockchainOwnership.fromJson(Map<String, dynamic> json) {
    return BlockchainOwnership(
      id: json['id'],
      carId: json['carId'],
      currentOwnerId: json['currentOwnerId'],
      ownershipHistory: (json['ownershipHistory'] as List)
          .map((e) => OwnershipRecord.fromJson(e))
          .toList(),
      blockchainHash: json['blockchainHash'],
      smartContractAddress: json['smartContractAddress'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'currentOwnerId': currentOwnerId,
      'ownershipHistory': ownershipHistory.map((e) => e.toJson()).toList(),
      'blockchainHash': blockchainHash,
      'smartContractAddress': smartContractAddress,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}

class OwnershipRecord {
  final String id;
  final String ownerId;
  final DateTime fromDate;
  final DateTime? toDate;
  final double purchasePrice;
  final String transactionHash;
  final Map<String, dynamic> metadata;

  OwnershipRecord({
    required this.id,
    required this.ownerId,
    required this.fromDate,
    this.toDate,
    required this.purchasePrice,
    required this.transactionHash,
    required this.metadata,
  });

  factory OwnershipRecord.fromJson(Map<String, dynamic> json) {
    return OwnershipRecord(
      id: json['id'],
      ownerId: json['ownerId'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,
      purchasePrice: json['purchasePrice'].toDouble(),
      transactionHash: json['transactionHash'],
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'transactionHash': transactionHash,
      'metadata': metadata,
    };
  }
}

/// نموذج NFT للسيارات النادرة
class CarNFT {
  final String id;
  final String carId;
  final String tokenId;
  final String contractAddress;
  final String name;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> attributes;
  final String currentOwnerId;
  final double mintPrice;
  final DateTime mintedAt;
  final List<NFTTransaction> transactionHistory;
  final bool isListed;
  final double? listingPrice;

  CarNFT({
    required this.id,
    required this.carId,
    required this.tokenId,
    required this.contractAddress,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.attributes,
    required this.currentOwnerId,
    required this.mintPrice,
    required this.mintedAt,
    required this.transactionHistory,
    required this.isListed,
    this.listingPrice,
  });
}

class NFTTransaction {
  final String id;
  final String fromAddress;
  final String toAddress;
  final double price;
  final String transactionHash;
  final DateTime timestamp;
  final NFTTransactionType type;

  NFTTransaction({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.price,
    required this.transactionHash,
    required this.timestamp,
    required this.type,
  });
}

enum NFTTransactionType {
  mint,
  transfer,
  sale,
  auction,
}

/// نموذج المحفظة الرقمية
class CryptoWallet {
  final String id;
  final String userId;
  final String address;
  final Map<String, double> balances;
  final List<String> supportedTokens;
  final bool isVerified;
  final DateTime createdAt;

  CryptoWallet({
    required this.id,
    required this.userId,
    required this.address,
    required this.balances,
    required this.supportedTokens,
    required this.isVerified,
    required this.createdAt,
  });
}

/// نموذج المعاملة بالعملة الرقمية
class CryptoTransaction {
  final String id;
  final String fromAddress;
  final String toAddress;
  final String tokenSymbol;
  final double amount;
  final double amountInSAR;
  final String transactionHash;
  final TransactionStatus status;
  final String? carId;
  final TransactionType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  CryptoTransaction({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.tokenSymbol,
    required this.amount,
    required this.amountInSAR,
    required this.transactionHash,
    required this.status,
    this.carId,
    required this.type,
    required this.timestamp,
    required this.metadata,
  });
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  cancelled,
}

enum TransactionType {
  purchase,
  sale,
  deposit,
  withdrawal,
  fee,
}

/// نموذج العقد الذكي
class SmartContract {
  final String id;
  final String address;
  final String name;
  final ContractType type;
  final String abi;
  final Map<String, dynamic> functions;
  final bool isActive;
  final DateTime deployedAt;

  SmartContract({
    required this.id,
    required this.address,
    required this.name,
    required this.type,
    required this.abi,
    required this.functions,
    required this.isActive,
    required this.deployedAt,
  });
}

enum ContractType {
  ownership,
  escrow,
  auction,
  nft,
  payment,
}

/// نموذج الضمان الذكي (Escrow)
class SmartEscrow {
  final String id;
  final String contractAddress;
  final String buyerId;
  final String sellerId;
  final String carId;
  final double amount;
  final String tokenSymbol;
  final EscrowStatus status;
  final List<EscrowCondition> conditions;
  final DateTime createdAt;
  final DateTime? releasedAt;

  SmartEscrow({
    required this.id,
    required this.contractAddress,
    required this.buyerId,
    required this.sellerId,
    required this.carId,
    required this.amount,
    required this.tokenSymbol,
    required this.status,
    required this.conditions,
    required this.createdAt,
    this.releasedAt,
  });
}

enum EscrowStatus {
  created,
  funded,
  released,
  refunded,
  disputed,
}

class EscrowCondition {
  final String id;
  final String description;
  final bool isMet;
  final DateTime? metAt;
  final String? evidence;

  EscrowCondition({
    required this.id,
    required this.description,
    required this.isMet,
    this.metAt,
    this.evidence,
  });
}
