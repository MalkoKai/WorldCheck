import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:xen_popup_card/xen_popup_card.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

const List<String> list = <String>['with Myself', 'with Friends', 'with My Love', 'with Family'];

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen(
      {super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> with SingleTickerProviderStateMixin{

  late TabController controller;

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";

  String dropdownValue = list.first;

  // APP BAR
  //
  // [XenCardAppBar]
  XenCardAppBar appBar = const XenCardAppBar(
    child: Text(
      "Add Travel",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
    ),
    // To remove shadow from appbar
    shadow: BoxShadow(color: Colors.transparent),
  );

  // GUTTER
  //
  // [XenCardGutter]
  XenCardGutter gutter = XenCardGutter(
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontSize: 20),
        ),
        onPressed: () {


        },
        child: const Text('Confirm'),
        ),
    ),
  );

  /*
  DateTime? _selectedDate;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
*/
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void initState() {
    controller = TabController(length: 2, initialIndex: 0, vsync: this);
    super.initState();
  }

  Widget build(BuildContext context) {

    GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;

    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now();

    return Scaffold(
      body: Container(
        height: sizeHeight,
        width: sizeWidth,
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
            ),
            SimpleMap(
              // String of instructions to draw the map.
              instructions: SMapWorld.instructions,

              // Default color for all countries.
              defaultColor: Colors.grey,

              // Matching class to specify custom colors for each area.
              colors: SMapWorldColors(
                uS: Colors.green,   // This makes USA green
                cN: Colors.green,   // This makes China green
                rU: Colors.green,   // This makes Russia green
              ).toMap(),


              // Details of what area is being touched, giving you the ID, name and tapdetails
              callback: (id, name, tapdetails) {
                print(id);
              },
            ),
            const Spacer(),
            Row(
              children: [
                Spacer(),
                FloatingActionButton(
                  onPressed: () {
                    // Add your logic for handling the button press here
                    showDialog(
                        context: context,
                        builder: (builder) => XenPopupCard(
                      appBar: appBar,
                      gutter: gutter,
                      body: ListView(
                        children: [
                          SfDateRangePicker(
                              onSelectionChanged: _onSelectionChanged,
                              selectionMode: DateRangePickerSelectionMode.range,
                          ),
                          //SfDateRangePicker(),
                          CSCPicker(
                            ///Enable disable state dropdown [OPTIONAL PARAMETER]
                            showStates: true,

                            /// Enable disable city drop down [OPTIONAL PARAMETER]
                            showCities: true,

                            ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
                            flagState: CountryFlag.DISABLE,

                            ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                            dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                                border:
                                Border.all(color: Colors.grey.shade300, width: 1)),

                            ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                            disabledDropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.grey.shade300,
                                border:
                                Border.all(color: Colors.grey.shade300, width: 1)),

                            ///placeholders for dropdown search field
                            countrySearchPlaceholder: "Country",
                            stateSearchPlaceholder: "State",
                            citySearchPlaceholder: "City",

                            ///labels for dropdown
                            countryDropdownLabel: "*Country",
                            stateDropdownLabel: "*State",
                            cityDropdownLabel: "*City",

                            ///Default Country
                            //defaultCountry: CscCountry.India,

                            ///Disable country dropdown (Note: use it with default country)
                            //disableCountry: true,

                            ///Country Filter [OPTIONAL PARAMETER]
                            //countryFilter: [CscCountry.India,CscCountry.United_States,CscCountry.Canada],

                            ///selected item style [OPTIONAL PARAMETER]
                            selectedItemStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),

                            ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                            dropdownHeadingStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),

                            ///DropdownDialog Item style [OPTIONAL PARAMETER]
                            dropdownItemStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),

                            ///Dialog box radius [OPTIONAL PARAMETER]
                            dropdownDialogRadius: 10.0,

                            ///Search bar radius [OPTIONAL PARAMETER]
                            searchBarRadius: 10.0,

                            ///triggers once country selected in dropdown
                            onCountryChanged: (value) {
                              setState(() {
                                ///store value in country variable
                                if(value != null) {
                                  countryValue = value;
                                }
                              });
                            },

                            ///triggers once state selected in dropdown
                            onStateChanged: (value) {
                              setState(() {
                                ///store value in state variable
                                if(value != null) {
                                  stateValue = value;
                                }
                              });
                            },

                            ///triggers once city selected in dropdown
                            onCityChanged: (value) {
                              setState(() {
                                ///store value in city variable
                                if(value != null) {
                                  cityValue = value;
                                }
                              });
                            },
                          ),

                          ///print newly selected country state and city in Text Widget
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  address = "$cityValue, $stateValue, $countryValue";
                                });
                              },
                              child: Text("Print Data")),
                          Text(address),
                          DropdownButton<String>(
                            value: dropdownValue,
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                            items: list.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        ],

                      ),
                    )
                    );
                  },
                  tooltip: 'Add',
                  child: Icon(Icons.add),
                ),
                SizedBox(
                  width: 25,
                  height: 25,
                )
              ],
            ),
            SizedBox(
              width: 25,
              height: 25,
            )
          ],
      ),
      )
    );
  }
}