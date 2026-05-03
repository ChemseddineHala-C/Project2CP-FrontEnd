// import 'package:flutter/cupertino.dart';
import 'package:fishapp/consumer/setupconsumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class Interfaceconsumerpage extends StatefulWidget {
  const Interfaceconsumerpage({super.key});

  @override
  State<Interfaceconsumerpage> createState() => _InterfaceconsumerpageState();
}
class _InterfaceconsumerpageState extends State<Interfaceconsumerpage> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String assetconsumer='images/consumer.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Let's Fishing", style: TextStyle(
            fontWeight: FontWeight.bold, color:isDark?Colors.white: Colors.black)),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.fromBorderSide( BorderSide(color:isDark?Colors.white12: Colors.transparent)),
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
          // Container(
          //   width: 300,
          //   height: 300,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(color: Colors.white, width: 6),
          //     image: DecorationImage(
          //       image: SvgPicture.asset(
          //         assetname,
          //         width: 300,
          //         height: 300,
          //       ),
          //       // AssetImage("images/sea.png"),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent, width: 6),
            ),
            child: SvgPicture.asset(
              assetconsumer,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 50),
          _textcenter("Welcome!",isDark),
          _text("we need a few more details about you",isDark),
          _text("Let's complete your profile.",isDark),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF033F78),
                minimumSize: const Size(70, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: MaterialButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SetupConspage()));
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