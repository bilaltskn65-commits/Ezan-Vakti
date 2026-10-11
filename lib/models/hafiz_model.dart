class HafizModel {
  final String id;
  final String nameTr;
  final String nameAr;
  final String serverPath;
  final String imageAsset;
  final String description;

  const HafizModel({
    required this.id,
    required this.nameTr,
    required this.nameAr,
    required this.serverPath,
    required this.imageAsset,
    required this.description,
  });
}

class HafizList {
  static const List<HafizModel> reciters = [
    HafizModel(
      id: 'alafasy',
      nameTr: 'Mişari Raşid el-Afasi',
      nameAr: 'مشاري بن راشد العفاسي',
      serverPath: 'Alafasy_128kbps',
      imageAsset: 'assets/hafiz/alafasy.png',
      description: 'Kuveytli dünyaca ünlü kâri, duygusal ve melodik okuyuş',
    ),
    HafizModel(
      id: 'abdulsamed',
      nameTr: 'Abdülsamed (Abdul Basit)',
      nameAr: 'عبد الباسط عبد الصمد',
      serverPath: 'Abdul_Basit_Murattal_192kbps',
      imageAsset: 'assets/hafiz/abdulsamed.png',
      description: 'Mısır efsanesi, muazzam nefes ve klasik tecvid üstadı',
    ),
    HafizModel(
      id: 'husary',
      nameTr: 'Mahmud Halil el-Husari',
      nameAr: 'محمود خليل الحصري',
      serverPath: 'Husary_128kbps',
      imageAsset: 'assets/hafiz/husary.png',
      description: 'Kıraat ilminin öncüsü, tam tecvidli öğretici tilavet',
    ),
    HafizModel(
      id: 'muaiqly',
      nameTr: 'Mahir el-Muaykili',
      nameAr: 'ماهر المعيقلي',
      serverPath: 'MaherAlMuaiqly128kbps',
      imageAsset: 'assets/hafiz/muaiqly.png',
      description: 'Mekke Mescid-i Haram İmamı, huzur veren berrak ses',
    ),
    HafizModel(
      id: 'ghamdi',
      nameTr: 'Saad el-Gamdi',
      nameAr: 'سعد الغامدي',
      serverPath: 'Ghamadi_40kbps',
      imageAsset: 'assets/hafiz/ghamdi.png',
      description: 'Suudi Arabistanlı tanınmış hafız, akıcı ve dinlendirici makam',
    ),
    HafizModel(
      id: 'shatri',
      nameTr: 'Ebu Bekir eş-Şatri',
      nameAr: 'أبو بكر الشاطري',
      serverPath: 'Abu_Bakr_Ash-Shaatree_128kbps',
      imageAsset: 'assets/hafiz/shatri.png',
      description: 'Cidde doğumlu ünlü imam, derin ve etkileyici ton',
    ),
    HafizModel(
      id: 'qatami',
      nameTr: 'Naser el-Katami',
      nameAr: 'ناصر القطامي',
      serverPath: 'Nasser_Alqatami_128kbps',
      imageAsset: 'assets/hafiz/qatami.png',
      description: 'Riyad Kâri ve İmamı, huşu dolu duygusal okuyuş',
    ),
    HafizModel(
      id: 'dosari',
      nameTr: 'Yaser el-Devsari',
      nameAr: 'ياسر الدوسري',
      serverPath: 'Yasser_Ad-Dussary_128kbps',
      imageAsset: 'assets/hafiz/dosari.png',
      description: 'Mescid-i Haram İmamı, güçlü ve coşkulu tilavet',
    ),
    HafizModel(
      id: 'shuraim',
      nameTr: 'Suud eş-Şureym',
      nameAr: 'سعود الشريم',
      serverPath: 'Saood_ash-Shuraym_128kbps',
      imageAsset: 'assets/hafiz/shuraim.png',
      description: 'Kabe eski başımamı, hızlı ve ritmik okuyuş ekolü',
    ),
    HafizModel(
      id: 'ismail',
      nameTr: 'Mustafa İsmail',
      nameAr: 'مصطفى إسماعيل',
      serverPath: 'Mustafa_Ismail_48kbps',
      imageAsset: 'assets/hafiz/ismail.png',
      description: 'Klasik Mısır makam üstadı, tarihi ve eşsiz ses',
    ),
  ];

  static HafizModel getById(String id) {
    return reciters.firstWhere(
      (element) => element.id == id,
      orElse: () => reciters.first,
    );
  }
}

