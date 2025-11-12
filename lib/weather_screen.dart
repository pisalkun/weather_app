
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0;
  double windSpeed = 0;
  int pressure = 0;
  int humidity = 0;
  double opacity = 1.0; 
  String weatherMain = 'Clear';
  String weatherIconCode = '01d';
  List<Map<String, dynamic>> forecastList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    fetchForecast().whenComplete(() {
      setState(() => loading = false);
    });
  }

  Future<void> fetchWeather() async {
    const apiKey = '7fc4455b11173c9cb486f55e5bd76318';
    const city = 'Phnom Penh';
    final url =
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = (data['main']['temp'] as num).toDouble();
        final wind = (data['wind']['speed'] as num).toDouble();
        final hum = data['main']['humidity'];
        final press = data['main']['pressure'];

        setState(() {
          temperature = temp;
          windSpeed = wind;
          humidity = hum;
          pressure = press;
          weatherMain = data['weather'][0]['main'];
          weatherIconCode = data['weather'][0]['icon'];
          loading = false;
        });
      } else {
        debugPrint("Error: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Failed to fetch weather: $e");
      setState(() => loading = false);
    }
  }
  Future<void> fetchForecast() async {
  final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=Phnom%20Penh&appid=7fc4455b11173c9cb486f55e5bd76318&units=metric');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      setState(() {
        forecastList = list .where((item){
          final hour = int.parse(item['dt_txt'].substring(11,13));
          return hour %3 == 0;
        })
        
        .map((item) {
          DateTime forecastDate = DateTime.parse(item['dt_txt']);
          DateTime now = DateTime.now();
          String dayLabel;
          
          if(forecastDate.day == now.day &&
          forecastDate.month == now.month &&
          forecastDate.year  == now.year
          ){
            dayLabel = 'Today';
          }
          else if(
            forecastDate.day == now.add(Duration(days: 1)).day &&
            forecastDate.month == now.add(Duration(days: 1)).month &&
            forecastDate.year == now.add(Duration(days: 1)).year
          ){
            dayLabel = 'Tomorrow';
          }
          else{
            dayLabel = '${forecastDate.day}/${forecastDate.month}';
          }
          return {
            'temp': (item['main']['temp'] as num).toDouble(),
            'time': item['dt_txt'],
            'weather': item['weather'][0]['main'],
            'icon': item['weather'][0]['icon'],
            'day': dayLabel,
          };
        }).toList();
      });
    }
  } catch (e) {
    debugPrint("Failed to fetch forecast: $e");
  }
}

Future<void> _refresh() async {
  setState(() {
    opacity = 0.0;
  });

  await Future.delayed(const Duration(milliseconds: 300)); // fade out duration

  setState(() => loading = true);
  await fetchWeather();
  await fetchForecast();

  setState(() {
    loading = false;
    opacity = 1.0;
  });
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    debugPrint('building widget...');
      if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        
        title: Text(
          'Weather Menu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions:  [
          IconButton(
          icon:loading
          ? const RotationTransition(turns:AlwaysStoppedAnimation(0.5),
                  child: Icon(Icons.refresh),
                )
          :const Icon(Icons.refresh),
          onPressed: loading ? null : _refresh,
          )
        ],
      ),
      body: Stack(
        children:[        
            Positioned.fill(
              child: Image.asset(
              'assets/backgroundimage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
            padding:  EdgeInsets.all(screenWidth*0.05),
            child: Column(
              children: [
                //main card 
                GlassCard(
                  child: Column(
                    children: [
                      AutoSizeText('$temperature°C',
                        style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: Colors.white),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                       SizedBox(height: screenHeight*0.02),
                      Image.network(
                         'http://openweathermap.org/img/wn/$weatherIconCode@2x.png',
                            width: 64,
                            height: 64,
                      ),
                      AutoSizeText(weatherMain,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white,),
                      maxLines: 1,
                      minFontSize: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(height: screenHeight*0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Weather Forcast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),  
                  ),
                ),
                SizedBox(height: screenHeight*0.02),
                // weather card 
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                        children: forecastList.map((f) {
                            return Forcast(
                              day: f['day'],
                              time: f['time'].toString().substring(11,16), // show HH:mm
                              temp: f['temp'],
                              iconCode: f['icon'],
                            );
                          }).toList(),
                  )
                ),
                SizedBox(height: screenHeight*0.02),
                // Additional information card
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text('Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight*0.02),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: InfoCard(icon: Icons.water_drop, label: 'Humidity', value: '$humidity%')),
                      SizedBox(height: 8,),
                      Expanded(child: InfoCard(icon: Icons.air, label: 'Wind', value: '$windSpeed m/s')),
                      SizedBox(height: 8,),
                      Expanded(child: InfoCard(icon: Icons.speed, label: 'Pressure', value: '$pressure hPa')),
                    ],
                  ),
                )
              ],
            ),
           ),
          ),
        ]
      ),
    );
  }
}
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(screenWidth*0.05),
      decoration: BoxDecoration(
        color: Color.fromARGB(13, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromARGB(51, 255, 255, 255)),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: child,
    );
  }
}

class Forcast extends StatelessWidget {
  
  final String time;
  final double temp;
  final String iconCode;
  final String day;
  const Forcast({super.key,required this.time, required this.temp, required this.iconCode, required this.day});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding:  EdgeInsets.all(screenWidth*0.05),
      decoration: BoxDecoration(
        color: Color.fromARGB(13, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromARGB(51, 255, 255, 255)),
      ),
      child: Column(
        children:  [
          Text(day ,
          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),
          ),
          Text(time,
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: screenHeight*0.02),
          Image.network(
            'http://openweathermap.org/img/wn/$iconCode@2x.png',
            height: 48,
            width: 48,
          ),
          SizedBox(height: screenHeight*0.02),
          Text('${temp.toStringAsFixed(1)}°C',
          style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),
          ),
        ],
      ),
    );
  }
}  

class InfoCard extends StatelessWidget {
    final IconData icon;
  final String label;
  final String value;
  const InfoCard({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: 120,
      child: Card(
        elevation: 0,
        color: Color.fromARGB(25, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(screenWidth*0.05),
          child: Column(
            children: [
              Icon(icon,size: 48, color: Colors.white,),
              SizedBox(height: screenHeight*0.02 ),
              AutoSizeText(label,
              style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),
              maxLines: 1,
              minFontSize: 10,
              ),
              SizedBox(height: screenHeight*0.02),
              AutoSizeText(value,
              style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),
              maxLines: 1,
              minFontSize: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}