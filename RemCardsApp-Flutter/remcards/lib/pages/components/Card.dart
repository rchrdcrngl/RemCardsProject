import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remcards/pages/components/RemCard.dart';
import '../EditCard.dart';


//============ values ================================
Map<int,Icon> iconMap = {
  0:Icon(Icons.adjust_rounded, color: Colors.white),
  1:Icon(Icons.double_arrow_rounded, color: Colors.white),
  2:Icon(Icons.history_toggle_off_rounded, color: Colors.white),
  3:Icon(Icons.stars_rounded, color: Colors.white),
  4:Icon(Icons.check_circle_rounded, color: Colors.white)};

Map<int,Color> color = {
  0: Color(0xFF2980b9),
  1: Color(0xFFf1c40f),
  2: Color(0xFFe74c3c),
};

Widget RCard({RemCard remcard, BuildContext context, Function deleteCard, Function refresh, Function incrementStatus}) {
    remcard.tskstat = remcard.tskstat % 5;
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => {deleteCard(remcard.id), refresh()},
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: Card(
        elevation: 2,
        child: InkWell(
            child: ClipPath(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(remcard.tskdesc,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          Text(remcard.subjcode,
                              style: TextStyle(fontFamily: 'Montserrat')),
                          Text(remcard.tskdate,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300))
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          incrementStatus(remcard.id, remcard.tskstat);
                          refresh();
                        },
                        child: iconMap[remcard.tskstat]??Icon(Icons.adjust_rounded, color: Colors.white),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                          backgroundColor: MaterialStateProperty.all(
                              color[remcard.tsklvl]??Color(0xFF2980b9)), // <-- Button color
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )),
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => editCardForm(
                        remcard: remcard,
                        callback: refresh),
                  ));
            }),
      ),
    );
  }