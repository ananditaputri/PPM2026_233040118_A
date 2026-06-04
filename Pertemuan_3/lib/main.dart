import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Mahasiswa',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,

        scaffoldBackgroundColor: const Color(0xFFF5F3FF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepPurple.shade100),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {'/': (context) => const HomePage()},

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            return MaterialPageRoute(builder: (_) => const TambahCatatanPage());

          case '/detail':
            final catatan = settings.arguments as Catatan;

            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: catatan),
            );
        }

        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari StatefulWidget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  String _filterKategori = 'Semua';

  final List<String> _filterList = [
    'Semua',
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  List<Catatan> get _catatanFilter {
    if (_filterKategori == 'Semua') {
      return _catatan;
    }

    return _catatan.where((item) => item.kategori == _filterKategori).toList();
  }

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepPurple,
          content: Text('Catatan "${hasil.judul}" ditambahkan'),
        ),
      );
    }
  }

  void _hapusCatatan(int index) {
    setState(() {
      _catatan.remove(_catatanFilter[index]);
    });
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  Color _warnaKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah':
        return Colors.blue;

      case 'Tugas':
        return Colors.orange;

      case 'Pribadi':
        return Colors.green;

      default:
        return Colors.purple;
    }
  }

  IconData _iconKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah':
        return Icons.school;

      case 'Tugas':
        return Icons.assignment;

      case 'Pribadi':
        return Icons.person;

      default:
        return Icons.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterKategori,

                dropdownColor: Colors.deepPurple,

                iconEnabledColor: Colors.white,

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                items: _filterList.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _filterKategori = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),

      body: _catatanFilter.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 90,
                    color: Colors.deepPurple,
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Belum ada catatan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),

              itemCount: _catatanFilter.length,

              itemBuilder: (context, index) {
                final c = _catatanFilter[index];

                final warna = _warnaKategori(c.kategori);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),

                        blurRadius: 10,

                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    leading: CircleAvatar(
                      radius: 28,

                      backgroundColor: warna.withValues(alpha: 0.15),

                      child: Icon(
                        _iconKategori(c.kategori),

                        color: warna,
                        size: 28,
                      ),
                    ),

                    title: Text(
                      c.judul,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color: warna.withValues(alpha: 0.12),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Text(
                              c.kategori,

                              style: TextStyle(
                                color: warna,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            _formatTanggal(c.dibuatPada),

                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                      ),

                      onPressed: () => _hapusCatatan(index),
                    ),

                    onTap: () {
                      Navigator.pushNamed(context, '/detail', arguments: c);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahCatatanPage extends StatefulWidget {
  const TambahCatatanPage({super.key});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  final _judulCtrl = TextEditingController();

  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';

  final List<String> _kategoriList = ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),

      isi: _isiCtrl.text.trim(),

      kategori: _kategori,

      dibuatPada: DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            TextFormField(
              controller: _judulCtrl,

              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: _kategori,

              decoration: const InputDecoration(
                labelText: 'Kategori',

                prefixIcon: Icon(Icons.category),
              ),

              items: _kategoriList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),

              onChanged: (value) {
                setState(() {
                  _kategori = value!;
                });
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: _isiCtrl,

              maxLines: 5,

              decoration: const InputDecoration(
                labelText: 'Isi Catatan',

                prefixIcon: Icon(Icons.notes),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,

                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(vertical: 16),
              ),

              onPressed: _simpan,

              icon: const Icon(Icons.save),

              label: const Text('Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  Color _warnaKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah':
        return Colors.blue;

      case 'Tugas':
        return Colors.orange;

      case 'Pribadi':
        return Colors.green;

      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = _warnaKategori(catatan.kategori);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                catatan.judul,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Chip(
                backgroundColor: warna.withValues(alpha: 0.15),

                label: Text(
                  catatan.kategori,

                  style: TextStyle(color: warna, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                catatan.isi,

                style: const TextStyle(fontSize: 17, height: 1.7),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,

                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.arrow_back),

                  label: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
