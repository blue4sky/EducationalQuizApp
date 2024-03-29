import 'package:education_app/constant/r.dart';
import 'package:education_app/helpers/user_email.dart';
import 'package:education_app/models/exercise_question_list.dart';
import 'package:education_app/models/network_response.dart';
import 'package:education_app/repository/exercise_question_api.dart';
import 'package:education_app/view/main/exercise_question/result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  ExerciseQuestionList? soalList;
  getQuestionList() async {
    final result = await ExerciseQuestionApi().postQuestionList(widget.id);
    if (result.status == Status.success) {
      soalList = ExerciseQuestionList.fromJson(result.data!);
      _controller = TabController(length: soalList!.data!.length, vsync: this);
      // Move the button simultaneously
      _controller!.addListener(() {
        setState(() {});
      });
      setState(() {});
    }
  }

  TabController? _controller;

  @override
  void initState() {
    super.initState();
    getQuestionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Quiz",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Next Button or Submit Button
      bottomNavigationBar: _controller == null
          ? SizedBox(
              height: 0,
            )
          : Container(
              margin: EdgeInsets.only(right: 23, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: R.colours.primary,
                        fixedSize: Size(135, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    onPressed: () async {
                      // When on the last question
                      if (_controller!.index == soalList!.data!.length - 1) {
                        final result = await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return BottomSheetConfirmation();
                            });
                        if (result == true) {
                          // Data send to backend
                          List<String> answer = [];
                          List<String> questionId = [];

                          soalList!.data!.forEach((element) {
                            questionId.add(element.bankQuestionId!);
                            answer.add(element.studentAnswer!);
                          });

                          final payload = {
                            "user_email": UserEmail.getUserEmail(),
                            "exercise_id": widget.id,
                            "bank_question_id": questionId,
                            "student_answer": answer,
                          };
                          final result = await ExerciseQuestionApi()
                              .postStudentAnswer(payload);
                          if (result.status == Status.success) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ResultPage(
                                exerciseId: widget.id,
                              );
                            }));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Submit failed. Please try again!")));
                          }
                        }
                      } else {
                        _controller!.animateTo(_controller!.index + 1);
                      }
                    },
                    child: Text(
                      _controller?.index == soalList!.data!.length - 1
                          ? "Check Answer"
                          : "Next",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
      body: soalList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // TabBar No Soal
                Container(
                  child: TabBar(
                    enableFeedback: true,
                    controller: _controller,
                    indicator: BoxDecoration(
                        shape: BoxShape.circle, color: R.colours.primary),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    tabs: List.generate(
                      soalList!.data!.length,
                      (index) => Text(
                        "${index + 1}",
                      ),
                    ),
                  ),
                ),
                // TabBarView Quest and Choices
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: TabBarView(
                        controller: _controller,
                        children: List.generate(
                          soalList!.data!.length,
                          (index) => SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Question ${index + 1}",
                                  style: TextStyle(
                                    color: R.colours.greySubtitleHome,
                                    fontSize: 12,
                                  ),
                                ),
                                if (soalList!.data![index].questionTitle !=
                                    null)
                                  Html(
                                    data: soalList!.data![index].questionTitle!,
                                    style: {
                                      "body": Style(padding: EdgeInsets.zero),
                                      "p": Style(
                                        fontSize: FontSize(12),
                                      )
                                    },
                                  ),
                                if (soalList!.data![index].questionTitleImg !=
                                    null)
                                  Image.network(
                                      soalList!.data![index].questionTitleImg!),
                                _buildOption(
                                  "A",
                                  soalList!.data![index].optionA,
                                  soalList!.data![index].optionAImg,
                                  index,
                                ),
                                _buildOption(
                                  "B",
                                  soalList!.data![index].optionB,
                                  soalList!.data![index].optionBImg,
                                  index,
                                ),
                                _buildOption(
                                  "C",
                                  soalList!.data![index].optionC,
                                  soalList!.data![index].optionCImg,
                                  index,
                                ),
                                _buildOption(
                                  "D",
                                  soalList!.data![index].optionD,
                                  soalList!.data![index].optionDImg,
                                  index,
                                ),
                                _buildOption(
                                  "E",
                                  soalList!.data![index].optionE,
                                  soalList!.data![index].optionEImg,
                                  index,
                                )
                              ],
                            ),
                          ),
                        ).toList()),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOption(
      String option, String? answer, String? answerImg, int index) {
    final answerCheck = soalList!.data![index].studentAnswer == option;
    return GestureDetector(
      onTap: () {
        soalList!.data![index].studentAnswer = option;
        setState(() {});
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              color: answerCheck
                  ? R.colours.primary.withOpacity(0.71)
                  : Colors.white,
              border: Border.all(
                width: 1,
                color: Color(0xFFC9C9C9),
              ),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Text(
                option + ".",
                style: TextStyle(
                  color: answerCheck ? Colors.white : Colors.black,
                ),
              ),
              if (answer != null)
                Expanded(
                    child: Html(
                  data: answer,
                  style: {
                    "p": Style(
                      color: answerCheck ? Colors.white : Colors.black,
                    )
                  },
                )),
              if (answerImg != null) Expanded(child: Image.network(answerImg)),
            ],
          )),
    );
  }
}

class BottomSheetConfirmation extends StatefulWidget {
  const BottomSheetConfirmation({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomSheetConfirmation> createState() =>
      _BottomSheetConfirmationState();
}

class _BottomSheetConfirmationState extends State<BottomSheetConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 6,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFC4C4C4)),
            ),
            SizedBox(
              height: 15,
            ),
            Image.asset(R.assets.icConfirmation),
            SizedBox(
              height: 15,
            ),
            Text(
              "Do you want to check the answer now?",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text("Not Now"))),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Yes"))),
                SizedBox(
                  width: 15,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
