// ignore_for_file: prefer_const_constructors

import 'package:education_app/constant/r.dart';
import 'package:education_app/models/network_response.dart';
import 'package:education_app/models/bank_question_list.dart';
import 'package:education_app/repository/exercise_question_api.dart';
import 'package:education_app/view/main/exercise_question/quiz_page.dart';
import 'package:flutter/material.dart';

class PaketSoalPage extends StatefulWidget {
  const PaketSoalPage({Key? key, required this.id}) : super(key: key);
  static String route = "paket_soal_page";
  final String id;

  @override
  State<PaketSoalPage> createState() => _PaketSoalPageState();
}

class _PaketSoalPageState extends State<PaketSoalPage> {
  BankQuestionList? paketSoalList; // Global var
  getPaketSoal() async {
    final mapelResult = await ExerciseQuestionApi().getExercise(widget.id);
    if (mapelResult.status == Status.success) {
      paketSoalList = BankQuestionList.fromJson(mapelResult.data!);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPaketSoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colours.grey,
      appBar: AppBar(
        title: Text("Topics of The Subject"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a topic",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
                child: paketSoalList == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Wrap(
                          children: List.generate(paketSoalList!.data!.length,
                              (index) {
                            final currentPaketSoal =
                                paketSoalList!.data![index];
                            return Container(
                                padding: EdgeInsets.all(3),
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: PaketSoalWidget(data: currentPaketSoal));
                          }).toList(),
                        ),
                      )

                // GridView.count(
                //     mainAxisSpacing: 10,
                //     crossAxisSpacing: 10,
                //     crossAxisCount: 2,
                //     childAspectRatio: 4 / 3,
                //     children:
                //         List.generate(paketSoalList!.data!.length, (index) {
                //       final currentPaketSoal = paketSoalList!.data![index];
                //       return PaketSoalWidget(data: currentPaketSoal);
                //     }).toList(),
                //     // [
                //     //   PaketSoalWidget(),
                //     //   PaketSoalWidget(),
                //     //   PaketSoalWidget(),
                //     //   PaketSoalWidget(),
                //     // ],
                //   ),
                ),
          ],
        ),
      ),
    );
  }
}

class PaketSoalWidget extends StatelessWidget {
  const PaketSoalWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BankQuestionData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => KerjakanLatihanSoalPage(id: data.exerciseId!),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.withOpacity(0.2),
              ),
              padding: EdgeInsets.all(12),
              child: Image.asset(R.assets.icNote, width: 14),
            ),
            SizedBox(height: 4),
            Text(
              data.exerciseTitle!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${data.jumlahDone}/${data.jumlahSoal} Questions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9,
                color: R.colours.greySubtitleHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}