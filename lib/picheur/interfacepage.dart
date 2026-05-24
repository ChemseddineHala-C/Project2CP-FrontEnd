import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'filinfo.dart';

class Interfacepage extends StatefulWidget {

  const Interfacepage({super.key});

  @override
  State<Interfacepage> createState() => _InterfacepageState();
}
class _InterfacepageState extends State<Interfacepage> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String assetname='images/boat.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Let's Fishing", style: TextStyle(
            fontWeight: FontWeight.bold, color:isDark?Colors.white: Colors.black)),
        actions: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.fromBorderSide( BorderSide(color:isDark?Colors.white12: Colors.grey)),
            ),
            child:Container(
                padding: EdgeInsets.all(10),
                child: IconButton(onPressed: (){}, icon: Icon(Icons.help_outline,color:isDark?Colors.white: Colors.grey,))),
          )
        ],
      ),
      body:Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 6),
            ),
            child: SvgPicture.asset(
              assetname,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 50),
          _textcenter("Welcome Captain!",isDark),
          _text("To start trading in the marketplace,",isDark),
          _text("we need a few more details about you",isDark),
          _text("and your vessel",isDark),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF033F78),
                minimumSize: const Size(70, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: MaterialButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Infopage()));
              },child: const Text("Start Setup", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),)
          ),
        ],
      ),
    );
  }
}

Widget _textcenter(String txt,bool isDark){
  return Center(
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 11, color:isDark?Colors.white: Colors.black),
        children: [
          TextSpan(text:txt,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 36)),
        ],
      ),
    ),
  );

}

Widget _text(String text,bool isDark){
  return Center(
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 11, color:isDark?Colors.white54: Colors.grey),
        children: [
          TextSpan(text:text,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Color(0xFF475569))),
        ],
      ),
    ),
  );

}
