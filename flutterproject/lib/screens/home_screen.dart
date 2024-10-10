import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/meal.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Meal> _meals = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _nameController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _addMeal() async {
    if (_nameController.text.isEmpty || _selectedTime == null) return;

    final meal = Meal(
      name: _nameController.text,
      time: _selectedTime!,
    );

    setState(() {
      _meals.add(meal);
      _scheduleNotification(meal);
      _nameController.clear();
      _selectedTime = null;
    });
  }

  Future<void> _scheduleNotification(Meal meal) async {
    final scheduledTime = DateTime.now().add(Duration(
      hours: meal.time.hour,
      minutes: meal.time.minute,
    ));

    await _notificationsPlugin.zonedSchedule(
      0,
      'Meal Reminder',
      'Time to eat ${meal.name}!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_channel',
          'Meal Reminder',
          channelDescription: 'Reminds you to eat your meals',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    setState(() {
      _selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Meal Name'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addMeal,
              child: Text('Set Reminder'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_meals[index].name),
                    subtitle:
                        Text('Time: ${_meals[index].time.format(context)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
