import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';

class DailyMoodScreen extends StatefulWidget {
  const DailyMoodScreen({Key? key}) : super(key: key);

  @override
  State<DailyMoodScreen> createState() => _DailyMoodScreenState();
}

class _DailyMoodScreenState extends State<DailyMoodScreen> {
  double moodValue = 5;
  bool outOfRoutine = false;
  DateTime selectedDate = DateTime.now();
  final TextEditingController routineController = TextEditingController();
  final TextEditingController otherEmotionController = TextEditingController();
  final List<String> selectedEmotions = [];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final List<_Emotion> emotions = [
      _Emotion(localizations?.anger ?? 'Rabia/Ira', Icons.sentiment_very_dissatisfied, Colors.red),
      _Emotion(localizations?.anxiety ?? 'Ansiedad/estrés', Icons.sentiment_dissatisfied, Colors.orange),
      _Emotion(localizations?.fear ?? 'Miedo', Icons.sentiment_very_satisfied, Colors.blue),
      _Emotion(localizations?.joy ?? 'Alegría', Icons.sentiment_satisfied, Colors.orangeAccent),
      _Emotion(localizations?.surprise ?? 'Sorpresa', Icons.sentiment_neutral, Colors.purple),
      _Emotion(localizations?.sadness ?? 'Tristeza', Icons.sentiment_dissatisfied, Colors.amber[800]!),
    ];

    void toggleEmotion(String emotion) {
      setState(() {
        if (selectedEmotions.contains(emotion)) {
          selectedEmotions.remove(emotion);
        } else {
          selectedEmotions.add(emotion);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.moodScreenTitle ?? '¿Cómo ha sido tu día?'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              localizations?.moodScreenQuestion ?? '¿Qué tal ha sido tu día?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            // Selector de fecha
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          localizations?.selectDate ?? 'Seleccionar fecha',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (selectedDate.day != DateTime.now().day || 
                            selectedDate.month != DateTime.now().month || 
                            selectedDate.year != DateTime.now().year)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations?.differentDate ?? 'Fecha diferente',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF0039AE)),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 32),
                Expanded(
                  child: Slider(
                    value: moodValue,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: moodValue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        moodValue = value;
                      });
                    },
                  ),
                ),
                const Icon(Icons.sentiment_very_satisfied, color: Color.fromARGB(255, 255, 177, 59), size: 32),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: outOfRoutine,
                  onChanged: (value) {
                    setState(() {
                      outOfRoutine = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    localizations?.outOfRoutineQuestion ?? '¿Ha ocurrido algo que te haya sacado de tu rutina?',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (outOfRoutine)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                child: TextField(
                  controller: routineController,
                  decoration: InputDecoration(
                    labelText: localizations?.routineDescriptionLabel ?? 'Describe brevemente qué ha pasado',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
            const SizedBox(height: 10),
            Text(
              localizations?.selectEmotions ?? 'Si has sentido alguna de estas emociones, márcala/s',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: emotions.map((e) {
                      final selected = selectedEmotions.contains(e.name);
                      return GestureDetector(
                        onTap: () => toggleEmotion(e.name),
                        child: Card(
                          color: selected ? e.color.withOpacity(0.7) : Colors.white,
                          elevation: selected ? 6 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: selected ? e.color : Colors.grey.shade300, width: 2),
                          ),
                          child: SizedBox(
                            width: 130,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(e.icon, color: e.color, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  e.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(localizations?.otherEmotionLabel ?? 'Si has sentido alguna otra emoción escríbela'),
            const SizedBox(height: 8),
            TextField(
              controller: otherEmotionController,
              decoration: InputDecoration(
                hintText: localizations?.otherEmotionHint ?? 'Escribe aquí...',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            SafeArea(
              bottom: true,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(localizations?.save ?? 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final username = prefs.getString('username');
                    if (username == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations?.noUserFound ?? 'No se encontró el usuario.')),
                      );
                      return;
                    }
                    final data = {
                      'username': username,
                      'mood_value': moodValue.round(),
                      'out_of_routine': outOfRoutine,
                      'routine_description': outOfRoutine ? routineController.text.trim() : null,
                      'emotions': selectedEmotions,
                      'other_emotion': otherEmotionController.text.trim().isNotEmpty ? otherEmotionController.text.trim() : null,
                      'date_time': selectedDate.toIso8601String(),
                    };
                    final api = ApiService(context: context);
                    final success = await api.sendMoodData(data);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations?.moodSaved ?? '¡Estado de ánimo guardado correctamente!')),
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations?.moodSaveError ?? 'Error al guardar el estado de ánimo.')),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Emotion {
  final String name;
  final IconData icon;
  final Color color;
  _Emotion(this.name, this.icon, this.color);
} 