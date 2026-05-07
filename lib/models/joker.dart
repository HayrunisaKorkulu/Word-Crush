import 'package:flutter/material.dart';
import '../constants/app_constants.dart';


class Joker {
  final JokerType type;
  final String name;
  final String description;
  final String usagePurpose;
  final String usageHow;
  final String assetPath;
  final int goldCost;
  final IconData fallbackIcon;
  final Color color;

  const Joker({
    required this.type,
    required this.name,
    required this.description,
    required this.usagePurpose,
    required this.usageHow,
    required this.assetPath,
    required this.goldCost,
    required this.fallbackIcon,
    required this.color,
  });
}


class JokerCatalog {
  static const List<Joker> all = [
    Joker(
      type: JokerType.fish,
      name: 'Balık',
      description:
          'Gridde rastgele harfleri yok eder. Üstteki harfler aşağıya düşer.',
      usagePurpose:
          'Rastgele harfleri temizleyerek yeni kelime fırsatları açar.',
      usageHow:
          'Satın alındıktan sonra oyun ekranında dokununca hemen çalışır.',
      assetPath: 'assets/jokers/fish.png',
      goldCost: AppConstants.jokerFishPrice,
      fallbackIcon: Icons.water,
      color: Color(0xFF00B8D4),
    ),
    Joker(
      type: JokerType.wheel,
      name: 'Tekerlek',
      description:
          'Seçilen harfin bulunduğu satır ve sütundaki tüm harfleri yok eder.',
      usagePurpose:
          'Bir satır ve bir sütunu aynı anda temizleyerek alan açar.',
      usageHow: 'Jokeri seç, ardından grid üzerinde bir harfe dokun.',
      assetPath: 'assets/jokers/wheel.png',
      goldCost: AppConstants.jokerWheelPrice,
      fallbackIcon: Icons.adjust,
      color: Color(0xFFE91E63),
    ),
    Joker(
      type: JokerType.lollipop,
      name: 'Lolipop Kırıcı',
      description:
          'Seçilen tek bir harfi yok eder. Üstündekiler aşağı düşer.',
      usagePurpose:
          'Kelime oluşturmayı engelleyen tek bir harfi kaldırır.',
      usageHow: 'Jokeri seç, yok etmek istediğin harfe dokun.',
      assetPath: 'assets/jokers/lollipop.png',
      goldCost: AppConstants.jokerLollipopPrice,
      fallbackIcon: Icons.celebration,
      color: Color(0xFFFF6B9D),
    ),
    Joker(
      type: JokerType.swap,
      name: 'Serbest Değiştirme',
      description: 'Birbirine temas eden iki harfin yerini değiştirir.',
      usagePurpose:
          'İki komşu harfi değiştirerek yeni kelime yolu oluşturur.',
      usageHow: 'Jokeri seç, ardından iki komşu harfe sırayla dokun.',
      assetPath: 'assets/jokers/hand.png',
      goldCost: AppConstants.jokerSwapPrice,
      fallbackIcon: Icons.swap_horiz,
      color: Color(0xFFFF6B6B),
    ),
    Joker(
      type: JokerType.shuffle,
      name: 'Harf Karıştırma',
      description:
          'Gridde bulunan tüm harfleri rastgele bir şekilde karıştırır.',
      usagePurpose:
          'Mevcut harfleri karıştırarak yeni kelime ihtimalleri üretir.',
      usageHow:
          'Satın alındıktan sonra oyun ekranında dokununca hemen çalışır.',
      assetPath: 'assets/jokers/color_bomb.png',
      goldCost: AppConstants.jokerShufflePrice,
      fallbackIcon: Icons.shuffle,
      color: Color(0xFF9C27B0),
    ),
    Joker(
      type: JokerType.party,
      name: 'Parti Güçlendiricisi',
      description:
          'Tüm harfleri yok eder ve yukarıdan rastgele yeni harfler düşer.',
      usagePurpose:
          'Gridi tamamen yenileyerek güçlü bir başlangıç sağlar.',
      usageHow:
          'Satın alındıktan sonra oyun ekranında dokununca tüm grid yenilenir.',
      assetPath: 'assets/jokers/party.png',
      goldCost: AppConstants.jokerPartyPrice,
      fallbackIcon: Icons.auto_awesome,
      color: Color(0xFFFFD93D),
    ),
  ];

  static Joker getByType(JokerType type) {
    return all.firstWhere((j) => j.type == type);
  }
}

