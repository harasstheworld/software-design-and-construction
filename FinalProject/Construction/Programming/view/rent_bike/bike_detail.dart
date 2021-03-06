import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../controller/rent_bike/bike_detail_controller.dart';
import '../../helper/widget.dart';
import '../../model/bike_model.dart';

const scaleFraction = 0.3;
const fullScale = 1;
const pagerHeight = 250.0;

class BikeDetail extends StatefulWidget {
  const BikeDetail({this.bikeModel, this.nameParking});
  final String nameParking;
  final BikeModel bikeModel;
  @override
  _BikeDetailState createState() => _BikeDetailState();
}

class _BikeDetailState extends State<BikeDetail> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
  );

  final formKey = GlobalKey<FormState>();
  final codeBike = TextEditingController();

  double viewPortFraction = 0.5;
  PageController pageController = PageController();
  int currentPage = 2;
  double currentPageValue = 2;
  //get current location
  Position location;
  Future<void> getUserLocation() async {
    await Geolocator.getCurrentPosition().then((value) {
      location = value;
    });
  }
  //get current time
  DateTime now;
  DateFormat formatter;
  String time;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BikeDetailController bikeDetailController = BikeDetailController();
  @override
  void initState() {
    pageController = PageController(
        initialPage: currentPage, viewportFraction: viewPortFraction);
    getUserLocation();
    flutterLocalNotificationsPlugin = Helper.initNotify();
    super.initState();
  }

  void onChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pr = ProgressDialog(context, type: ProgressDialogType.Normal);
    pageController.addListener(() {
      setState(() {
        currentPageValue = pageController.page;
      });
    });
    setState(() {
      now = DateTime.now();
      formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      time = formatter.format(now);
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          Helper.appBarMain(const Text("Th??ng tin chi ti???t c???a xe"), context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text("Danh s??ch m??u xe",
                                  style: Helper.simpleTextFieldStyle(
                                      Colors.redAccent, 18, FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: pagerHeight,
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                onPageChanged: onChanged,
                                physics: const BouncingScrollPhysics(),
                                controller: pageController,
                                itemCount: widget.bikeModel.urlImage.length,
                                itemBuilder: (context, index) {
                                  final scale = max(
                                      scaleFraction,
                                      (fullScale -
                                              (index - currentPageValue)
                                                  .abs()) +
                                          viewPortFraction);
                                  return circleOffer(
                                      widget.bikeModel
                                          .urlImage["urlImage${index + 1}"],
                                      scale);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                    widget.bikeModel.urlImage.length, (index) {
                                  return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: 10,
                                      width: (index == currentPage) ? 30 : 10,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 30),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: (index == currentPage)
                                              ? Colors.redAccent
                                              : Colors.red.withOpacity(0.5)));
                                })),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text("Chi ti???t s???n ph???m",
                              style: Helper.simpleTextFieldStyle(
                                  Colors.redAccent, 18, FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: widget.bikeModel.licensePlate ==
                                                null
                                            ? const Text("Bi???n s??? xe: Kh??ng c??")
                                            : Text(
                                                // ignore: lines_longer_than_80_chars
                                                "Bi???n s??? xe: ${widget.bikeModel.licensePlate} ",
                                                style:
                                                    Helper.simpleTextFieldStyle(
                                                        Colors.black,
                                                        16,
                                                        FontWeight.normal))),
                                    Expanded(
                                        child: widget.bikeModel
                                                    .batteryCapacity ==
                                                null
                                            ? const Text(
                                                "L?????ng pin hi???n t???i: Kh??ng c??")
                                            : Text(
                                                // ignore: lines_longer_than_80_chars
                                                "L?????ng pin hi???n t???i: ${widget.bikeModel.batteryCapacity}% ",
                                                style:
                                                    Helper.simpleTextFieldStyle(
                                                        Colors.black,
                                                        16,
                                                        FontWeight.normal)))
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text("M?? xe: ${widget.bikeModel.codeBike} ",
                                    style: Helper.simpleTextFieldStyle(
                                        Colors.black, 16, FontWeight.normal)),
                                const SizedBox(height: 10),
                                Text(
                                    "C??ch t??nh ti???n "
                                    "(Ho??n l???i ti???n c???c khi tr??? xe): ",
                                    style: Helper.simpleTextFieldStyle(
                                        Colors.black, 16, FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border:
                                            Border.all(color: Colors.black54)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "N???u kh??ch h??ng d??ng xe h??n "
                                              "10 ph??t th?? t??nh ti???n "
                                              "nh?? sau: ",
                                              style:
                                                  Helper.simpleTextFieldStyle(
                                                      Colors.black,
                                                      16,
                                                      FontWeight.normal)),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                                "+ Gi?? kh???i ??i???m cho 30 ph??t"
                                                " ?????u l?? 10.000 ?????ng",
                                                style:
                                                    Helper.simpleTextFieldStyle(
                                                        Colors.black,
                                                        16,
                                                        FontWeight.normal)),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                                "+ C??? m???i 15 ph??t ti???p theo, "
                                                "kh??ch s??? ph???i tr??? th??m"
                                                " 3.000 ?????ng",
                                                style:
                                                    Helper.simpleTextFieldStyle(
                                                        Colors.black,
                                                        16,
                                                        FontWeight.normal)),
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "T???ng ti???n ph???i c???c: ${widget.bikeModel.deposit} ??",
                      style: Helper.simpleTextFieldStyle(
                          Colors.redAccent, 15, FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.bikeModel.state == "S???n S??ng") {
                        // H??m x??? l?? Qu?? tr??nh Thu?? xe
                        // Tr??? v??? dialog ????? ng?????i d??ng x??c nh???n thu?? xe
                        bikeDetailController.getMoneyCard();
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("B???n mu???n thu?? xe n??y? Vui l??ng "
                                    "nh???p m?? s??? xe t????ng ???ng v?? t??i kho???n"
                                    " s??? t??? ?????ng b??? tr??? ti???n c???c."
                                    " M?? xe:' ${widget.bikeModel.codeBike}' "),
                                content: Form(
                                  key: formKey,
                                  child: TextFormField(
                                    validator: Helper.validatorCodeBike,
                                    decoration: const InputDecoration(
                                        hintText: "Nh???p m?? s??? xe...",
                                        labelText: "M?? xe:"),
                                    autofocus: true,
                                    controller: codeBike,
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Hu???")),
                                  FlatButton(
                                      onPressed: () {
                                        bikeDetailController.handleRentBike(
                                            stopWatchTimer: _stopWatchTimer,
                                            flutterLocalNotificationsPlugin:
                                                flutterLocalNotificationsPlugin,
                                            bikeModel: widget.bikeModel,
                                            context: context,
                                            time: time,
                                            nameParking: widget.nameParking,
                                            codeBike: codeBike,
                                            location: location,
                                            pr: pr);
                                      },
                                      child: const Text("Thu?? ngay"))
                                ],
                              );
                            });
                      } else if (widget.bikeModel.state == "Ch??a S???n S??ng") {
                        await Helper.alertDialogNotiStateBike(
                            context,
                            // ignore: lines_longer_than_80_chars
                            "Xe n??y ???? ???????c thu??, qu?? kh??ch vui l??ng ch???n xe kh??c.");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: MediaQuery.of(context).size.width / 6),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Color(0xFFEF9A9A),
                                Color(0xFFEF5350),
                              ])),
                      child: Text(
                        "Thu?? xe",
                        style: Helper.simpleTextFieldStyle(
                            Colors.white, 15, FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget circleOffer(String image, double scale) {
    final card = Card(
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Image.network(image,
          fit: BoxFit.fill, width: MediaQuery.of(context).size.width),
    );
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: pagerHeight * scale,
        width: pagerHeight * scale,
        child: card,
      ),
    );
  }
}
