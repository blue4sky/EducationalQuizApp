import 'package:education_app/view/main/latihan_soal/home_page.dart';
import 'package:education_app/view/main/latihan_soal/paket_soal_page.dart';
import 'package:flutter/material.dart';

class MapelPage extends StatelessWidget {
  const MapelPage({Key? key}) : super(key: key);
  static String route = "mapel_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Mata Pelajaran"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20,
        ),
        child: ListView.builder(itemBuilder: ((context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(PaketSoalPage.route);
            },
            child:
                MapelWidget(title: "Matematika", totalDone: 5, totalPacket: 10),
          );
        })),
      ),
    );
  }
}
