class AppConstants {
  static const String appName = 'FitClass';
  
  // Exercise Categories
  static const List<String> exerciseCategories = [
    'Göğüs',
    'Bacak',
    'Sırt',
    'Biceps',
    'Triceps',
    'Omuz',
    'Bilek',
  ];

  static String getCategoryDefaultImage(String category) {
    switch (category) {
      case 'Göğüs':
        return 'assets/images/exercises/bench_press.png';
      case 'Bacak':
        return 'assets/images/exercises/squats.png';
      case 'Sırt':
        return 'assets/images/exercises/deadlift.png';
      case 'Biceps':
        return 'assets/images/exercises/bicep_curl.png';
      case 'Triceps':
        return 'assets/images/exercises/triceps.png';
      case 'Omuz':
        return 'assets/images/exercises/shoulders.png';
      case 'Bilek':
        return 'assets/images/exercises/wrist.png';
      default:
        return 'assets/images/exercises/bench_press.png';
    }
  }

  // Activity Levels for Harris-Benedict formula
  static final Map<double, String> activityLevels = {
    1.2: 'Hareketsiz (Masa başı iş)',
    1.375: 'Hafif Aktif (Haftada 1-3 gün spor)',
    1.55: 'Orta Aktif (Haftada 3-5 gün spor)',
    1.725: 'Çok Aktif (Haftada 6-7 gün ağır spor)',
  };

  // Predefined popular foods with categories
  static const List<Map<String, dynamic>> foodDatabase = [
    // Protein Kaynakları
    {'name': 'Izgara Tavuk Göğsü (150g)', 'protein': 46.5, 'calories': 250.0, 'category': 'Protein Kaynakları'},
    {'name': 'Dana Biftek (150g)', 'protein': 39.0, 'calories': 290.0, 'category': 'Protein Kaynakları'},
    {'name': 'Izgara Somon Balığı (150g)', 'protein': 34.0, 'calories': 310.0, 'category': 'Protein Kaynakları'},
    {'name': 'Lor Peyniri (100g)', 'protein': 13.0, 'calories': 90.0, 'category': 'Protein Kaynakları'},
    {'name': 'Haşlanmış Yumurta (1 Adet)', 'protein': 6.0, 'calories': 70.0, 'category': 'Protein Kaynakları'},
    {'name': 'Hindi Füme Dilimleri (100g)', 'protein': 18.0, 'calories': 110.0, 'category': 'Protein Kaynakları'},
    {'name': 'Ton Balığı Konservesi (80g)', 'protein': 20.0, 'calories': 140.0, 'category': 'Protein Kaynakları'},
    {'name': 'Süzme Peynir (100g)', 'protein': 11.5, 'calories': 98.0, 'category': 'Protein Kaynakları'},
    {'name': 'Izgara Karides (120g)', 'protein': 24.0, 'calories': 115.0, 'category': 'Protein Kaynakları'},
    {'name': 'Kırmızı Mercimek Çorbası (1 Kase)', 'protein': 8.0, 'calories': 160.0, 'category': 'Protein Kaynakları'},
    
    // Karbonhidrat & Tahıl
    {'name': 'Yulaf Ezmesi (100g)', 'protein': 13.0, 'calories': 389.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Esmer Pirinç Pilavı (150g)', 'protein': 4.0, 'calories': 195.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Tam Tahıllı Ekmek (2 Dilim)', 'protein': 7.0, 'calories': 160.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Haşlanmış Patates (150g)', 'protein': 2.5, 'calories': 130.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Basmati Pirinç Pilavı (150g)', 'protein': 3.5, 'calories': 185.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Karabuğday (Greçka) (100g)', 'protein': 12.5, 'calories': 343.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Bulgur Pilavı (150g)', 'protein': 5.0, 'calories': 164.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Fırınlanmış Tatlı Patates (150g)', 'protein': 2.0, 'calories': 128.0, 'category': 'Karbonhidrat & Tahıl'},
    {'name': 'Tam Buğday Makarna (150g)', 'protein': 8.0, 'calories': 190.0, 'category': 'Karbonhidrat & Tahıl'},
    
    // Türk Mutfağı / Yemekler
    {'name': 'Lahmacun (1 Adet)', 'protein': 12.0, 'calories': 240.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Kıymalı Pide (1 Adet)', 'protein': 28.0, 'calories': 620.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Tavuklu Pilav (1 Porsiyon - 250g)', 'protein': 22.0, 'calories': 480.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Et Tantuni Dürüm (1 Adet)', 'protein': 24.0, 'calories': 450.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Adana Kebap (1 Porsiyon - Pidesiz)', 'protein': 32.0, 'calories': 580.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'İskender Kebap (1 Porsiyon)', 'protein': 38.0, 'calories': 750.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Kuru Fasulye (1 Porsiyon)', 'protein': 12.5, 'calories': 280.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Konya Etli Ekmek (1 Adet)', 'protein': 26.0, 'calories': 590.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Köfte Ekmek (Yarım Ekmek)', 'protein': 28.0, 'calories': 510.0, 'category': 'Türk Mutfağı / Yemekler'},
    {'name': 'Tavuk Döner Dürüm (1 Adet)', 'protein': 26.0, 'calories': 480.0, 'category': 'Türk Mutfağı / Yemekler'},

    // Meyve & Atıştırmalık
    {'name': 'Muz (1 Orta Boy)', 'protein': 1.2, 'calories': 105.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Çilek (100g)', 'protein': 0.8, 'calories': 32.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Badem (25g)', 'protein': 5.5, 'calories': 143.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Fıstık Ezmesi (1 Yemek Kaşığı)', 'protein': 4.0, 'calories': 95.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Ceviz İçi (30g)', 'protein': 4.5, 'calories': 196.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Yeşil Elma (1 Adet)', 'protein': 0.5, 'calories': 95.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Avokado (Yarım - 75g)', 'protein': 1.0, 'calories': 120.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Chia Tohumu (1 Yemek Kaşığı)', 'protein': 2.0, 'calories': 60.0, 'category': 'Meyve & Atıştırmalık'},
    {'name': 'Pirinç Patlağı (2 Adet)', 'protein': 1.0, 'calories': 70.0, 'category': 'Meyve & Atıştırmalık'},
    
    // İçecekler
    {'name': 'Sütlü Filtre Kahve (200ml)', 'protein': 3.2, 'calories': 45.0, 'category': 'İçecekler'},
    {'name': 'Whey Protein Shake (1 Ölçek)', 'protein': 24.0, 'calories': 120.0, 'category': 'İçecekler'},
    {'name': 'Sade Maden Suyu (200ml)', 'protein': 0.0, 'calories': 0.0, 'category': 'İçecekler'},
    {'name': 'Yağsız Süt (200ml)', 'protein': 6.8, 'calories': 70.0, 'category': 'İçecekler'},
    {'name': 'Sade Kefir (200ml)', 'protein': 6.0, 'calories': 105.0, 'category': 'İçecekler'},
    {'name': 'Kakao Proteinli Süt (330ml)', 'protein': 26.0, 'calories': 180.0, 'category': 'İçecekler'},
    {'name': 'Şekersiz Yeşil Çay (250ml)', 'protein': 0.0, 'calories': 2.0, 'category': 'İçecekler'},
    {'name': 'Hindistan Cevizi Suyu (250ml)', 'protein': 0.5, 'calories': 45.0, 'category': 'İçecekler'},
  ];
}
