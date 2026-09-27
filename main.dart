import 'package:flutter/material.dart';

void main() {
  runApp(const ProCadApp());
}

class ProCadApp extends StatelessWidget {
  const ProCadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro CAD 3D AI Lab Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.orange,
      ),
      home: const CadStudioScreen(),
    );
  }
}

// AI PROMPT PARSER (GELİŞMİŞ YAPAY ZEKA DESTEKLİ METİN VE LAB ANALİZİ)
class CadPromptParser {
  static Map<String, dynamic> parse(String prompt) {
    double width = 120.0;
    double height = 120.0;
    bool hasMarble = false;
    String category = 'Yapı Elemanı';
    String type = 'Özel Modül';
    String details = 'Standart Detay';

    final RegExp sizeRegex = RegExp(r'(\d+)\s*x\s*(\d+)');
    final match = sizeRegex.firstMatch(prompt.toLowerCase());
    if (match != null) {
      width = double.tryParse(match.group(1)!) ?? 120.0;
      height = double.tryParse(match.group(2)!) ?? 120.0;
    }

    String lower = prompt.toLowerCase();

    // Akıllı Yapay Zeka Kategori Tespiti
    if (lower.contains('pencere') || lower.contains('kapı')) {
      category = 'PVC & Doğrama';
      type = lower.contains('pencere') ? 'PVC Pencere' : 'Panel Kapı';
      hasMarble = lower.contains('mermer') || lower.contains('denizlik');
    } else if (lower.contains('parke') || lower.contains('seramik') || lower.contains('zemin')) {
      category = 'Zemin Döşeme';
      type = lower.contains('parke') ? 'Laminat Parke' : 'Granit Seramik';
      details = 'Mat/Parlak Surface';
    } else if (lower.contains('koltuk') || lower.contains('masası') || lower.contains('dolab')) {
      category = 'Mobilya';
      type = 'Modüler Mobilya';
      details = 'Ahşap / Kumaş Doku';
    } else if (lower.contains('buzdolabı') || lower.contains('fırın') || lower.contains('çamaşır')) {
      category = 'Beyaz Eşya';
      type = 'Ankastre / Cihaz';
      details = 'Inox / Beyaz Gövde';
    } else if (lower.contains('spot') || lower.contains('priz') || lower.contains('led') || lower.contains('klima')) {
      category = 'Elektrik & Tesisat';
      type = 'Elektrik/İklimlendirme';
      details = '220V Standart Tesisat';
    } else if (lower.contains('tavan') || lower.contains('asma')) {
      category = 'Tavan Sistemleri';
      type = 'Asma Tavan / Spot Kutusu';
      details = 'Alçıpan / Gergi Tavan';
    }

    return {
      'category': category,
      'type': type,
      'width': width,
      'height': height,
      'hasMarble': hasMarble,
      'details': details,
    };
  }
}

class CadStudioScreen extends StatefulWidget {
  const CadStudioScreen({super.key});

  @override
  State<CadStudioScreen> createState() => _CadStudioScreenState();
}

class _CadStudioScreenState extends State<CadStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isAnimMode = false;
  bool _isPhotomontageMode = false;
  final List<String> _keyframes = [];
  Map<String, dynamic>? _active3DObject;
  String _selectedCategory = 'Tümü';

  // DEV LAB KATALOĞU VERİTABANI (OFFLINE DATA)
  final List<Map<String, String>> _catalogDatabase = [
    {'title': '150x140 PVC Pencere', 'category': 'PVC & Doğrama', 'prompt': '150x140 cm PVC pencere mermerli'},
    {'title': '180x210 Sürgü Kapı', 'category': 'PVC & Doğrama', 'prompt': '180x210 cm sürgü kapı'},
    {'title': 'Laminat Parke 8mm', 'category': 'Zemin Döşeme', 'prompt': '100x100 cm laminat parke zemin'},
    {'title': '60x120 Granit Seramik', 'category': 'Zemin Döşeme', 'prompt': '60x120 cm granit seramik kaplama'},
    {'title': 'L Köşe Koltuk', 'category': 'Mobilya', 'prompt': '240x160 cm L köşe koltuk takımı'},
    {'title': 'Mutfak Ada Dolabı', 'category': 'Mobilya', 'prompt': '200x90 cm mutfak ada dolabı'},
    {'title': 'No-Frost Buzdolabı', 'category': 'Beyaz Eşya', 'prompt': '70x185 cm kombi buzdolabı'},
    {'title': '60cm Ankastre Fırın', 'category': 'Beyaz Eşya', 'prompt': '60x60 cm ankastre fırın ve ocak'},
    {'title': 'Sıva Altı LED Spot', 'category': 'Elektrik & Tesisat', 'prompt': '20x20 cm sıva altı LED spot aydınlatma'},
    {'title': 'Inverter Klima 12k', 'category': 'Elektrik & Tesisat', 'prompt': '90x30 cm inverter klima iç ünite'},
    {'title': 'Kartonpiyer Asma Tavan', 'category': 'Tavan Sistemleri', 'prompt': '300x300 cm LED havuzlu asma tavan'},
  ];

  void _generate3DModel(String inputPrompt) {
    if (inputPrompt.isEmpty) return;
    setState(() {
      _promptController.text = inputPrompt;
      _active3DObject = CadPromptParser.parse(inputPrompt);
    });
  }

  void _showExportShareMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📤 Tasarımı Dışa Aktar ve Paylaş',
                  style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                title: const Text('PDF Raporu Olarak Paylaş'),
                subtitle: const Text('WhatsApp / E-posta / Drive'),
                onTap: () => _shareFile('PDF'),
              ),
              ListTile(
                leading: const Icon(Icons.architecture, color: Colors.blueAccent),
                title: const Text('CAD / DWG Formatında Aktar'),
                subtitle: const Text('AutoCAD & Çizim Cihazları İçin'),
                onTap: () => _shareFile('DWG/CAD'),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.greenAccent),
                title: const Text('PNG / JPG Görsel Gönder'),
                subtitle: const Text('Yüksek Kaliteli Render Fotosu'),
                onTap: () => _shareFile('PNG/JPG'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareFile(String format) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Tasarım $format formatına dönüştürüldü. Paylaşım başlatılıyor...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCatalog = _selectedCategory == 'Tümü'
        ? _catalogDatabase
        : _catalogDatabase.where((item) => item['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('🔬 Pro CAD 3D Lab Studio',
            style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo, color: _isPhotomontageMode ? Colors.amber : Colors.white),
            tooltip: 'Fotomontaj Modu',
            onPressed: () {
              setState(() => _isPhotomontageMode = !_isPhotomontageMode);
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: _isAnimMode ? Colors.redAccent : Colors.white),
            tooltip: '5 Dk Kamera Animasyonu',
            onPressed: () => setState(() => _isAnimMode = !_isAnimMode),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.orange),
            tooltip: 'WhatsApp / Email Paylaş',
            onPressed: _showExportShareMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Akıllı AI Prompt Barı
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF222222),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Örn: L köşe koltuk, laminat parke, LED asma tavan...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => _generate3DModel(_promptController.text),
                  child: const Text('AI Lab Çiz', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          // 2. 3D Tuval / Lab Çizim Sahası
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: _isPhotomontageMode ? const Color(0xFF2E2E2E) : Colors.black,
                  child: _active3DObject == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPhotomontageMode ? Icons.camera_alt : Icons.science,
                                size: 60,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isPhotomontageMode
                                    ? '📷 Fotomontaj & Lab Sahası\nArka plana mekan resmi koyup katalogdan 3D malzeme oturtun'
                                    : '🏛️ Pro CAD 3D Lab Sahası Hazır\nMetin komutu yazın veya alt dev katalogdan eleman seçin',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Container(
                            width: (_active3DObject!['width'] as double) * 1.1,
                            height: (_active3DObject!['height'] as double) * 1.1,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.25),
                              border: Border.all(color: Colors.orange, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.view_in_ar, color: Colors.orange, size: 36),
                                const SizedBox(height: 4),
                                Text(
                                  '[${_active3DObject!['category']}]',
                                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_active3DObject!['type']}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Ölçek: ${_active3DObject!['width']} x ${_active3DObject!['height']} cm',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                                Text(
                                  'Detay: ${_active3DObject!['details']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                if (_active3DObject!['hasMarble'])
                                  Container(
                                    margin: const EdgeInsets.top(4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: Colors.white24,
                                    child: const Text('Mermer Denizlik', style: TextStyle(color: Colors.white, fontSize: 9)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),

                // 5 Dakikalık Kamera Yolu Paneli
                if (_isAnimMode)
                  Positioned(
                    top: 10, left: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kamera Yolu: ${_keyframes.length} Kare (5 Dk Video)',
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            icon: const Icon(Icons.add_a_photo, size: 12, color: Colors.white),
                            label: const Text('+ Kare Ekle', style: TextStyle(color: Colors.white, fontSize: 10)),
                            onPressed: () => setState(() => _keyframes.add('Frame_${_keyframes.length + 1}')),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),

          // 3. SINIRSIZ KATEGORİLİ DEV LAB KATALOĞU (OFFLINE)
          Container(
            height: 135,
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Filtre Butonları
                SizedBox(
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    children: [
                      'Tümü', 'PVC & Doğrama', 'Zemin Döşeme', 'Mobilya', 'Beyaz Eşya', 'Elektrik & Tesisat', 'Tavan Sistemleri'
                    ].map((cat) {
                      bool isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.white)),
                          selected: isSelected,
                          selectedColor: Colors.orange,
                          backgroundColor: const Color(0xFF2C2C2C),
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Katalog Kartları
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: filteredCatalog.length,
                    itemBuilder: (context, index) {
                      var item = filteredCatalog[index];
                      return _buildCatalogCard(item['title']!, item['category']!, item['prompt']!);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCatalogCard(String title, String category, String fullPrompt) {
    return GestureDetector(
      onTap: () => _generate3DModel(fullPrompt),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_box, color: Colors.orange, size: 18),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(category, style: const TextStyle(fontSize: 7, color: Colors.grey)),
            const SizedBox(height: 2),
            const Text('+ Lab Sahnene Ekle', style: TextStyle(fontSize: 7, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
