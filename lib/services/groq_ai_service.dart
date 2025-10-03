import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqAIService {
  // 🔒 CONFIGURACIÓN SEGURA - NO HAY CLAVES HARDCODEADAS
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'mixtral-8x7b-32768';
  
  // 🤖 API Key desde variables de entorno ÚNICAMENTE
  static String get _apiKey {
    // SOLO variables de entorno - NO claves hardcodeadas
    const key = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
    return key;
  }

  // 🧠 Generar consejo personalizado basado en contexto
  static Future<String> generateGymTip({
    required String muscleGroup,
    required String exerciseName,
    required String contextType, // 'rest', 'motivation', 'technique', 'nutrition'
    required int setNumber,
    required int totalSets,
  }) async {
    try {
      // ⚠️ Verificar que hay API key configurada
      if (_apiKey == 'TU_CLAVE_GROQ_AQUI' || _apiKey.isEmpty) {
        return _getFallbackTip(muscleGroup, contextType);
      }

      final prompt = _buildPrompt(
        muscleGroup: muscleGroup,
        exerciseName: exerciseName,
        contextType: contextType,
        setNumber: setNumber,
        totalSets: totalSets,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? '';
        return content.trim().isNotEmpty ? content.trim() : _getFallbackTip(muscleGroup, contextType);
      } else {
        print('🚨 Error Groq API: ${response.statusCode} - ${response.body}');
        return _getFallbackTip(muscleGroup, contextType);
      }
    } catch (e) {
      print('🚨 Error IA: $e');
      return _getFallbackTip(muscleGroup, contextType);
    }
  }

  // 📝 Tips de respaldo cuando la IA no está disponible
  static String _getFallbackTip(String muscleGroup, String contextType) {
    final Map<String, Map<String, List<String>>> tips = {
      'Pecho': {
        'motivation': [
          '💪 ¡Empuja con fuerza bro! Cada rep construye un pecho de acero',
          '🔥 Siente la quemadura en el pecho, eso es crecimiento puro',
          '⚡ Visualiza tu pecho creciendo con cada repetición',
        ],
        'technique': [
          '⚠️ Mantén los omóplatos juntos y el pecho hacia afuera',
          '🎯 Controla la bajada, explota en la subida',
          '📐 Rango completo de movimiento para máxima activación',
        ],
        'rest': [
          '😤 Respira profundo, el próximo set va a ser épico',
          '💧 Hidrata bien entre series para máximo rendimiento',
          '🧠 Mentalízate: el próximo set es tu oportunidad de brillar',
        ],
      },
      'Espalda': {
        'motivation': [
          '🦅 Construye esas alas poderosas, cada pull cuenta',
          '💪 Tu espalda es tu armadura, hazla invencible',
          '🔥 Siente cómo se ensancha tu espalda con cada rep',
        ],
        'technique': [
          '🎯 Tira con los codos, no con las manos',
          '⚠️ Mantén el core activado para proteger la columna',
          '📏 Escápulas hacia abajo y atrás en cada repetición',
        ],
        'rest': [
          '🌬️ Estira esos lats, afloja la tensión acumulada',
          '💧 Hidratación key para siguiente serie de dominadas',
          '🧠 Visualiza tu V-taper creciendo con cada entrenamiento',
        ],
      },
      'Piernas': {
        'motivation': [
          '🦵 Piernas de titanio se forjan aquí, no abandones',
          '⚡ Cada sentadilla te acerca al siguiente level',
          '🔥 Las piernas son la base del poder, construye fuerte',
        ],
        'technique': [
          '⚠️ Rodillas alineadas con los pies, nunca hacia adentro',
          '🍑 Empuja con los glúteos, siente el poder posterior',
          '📐 Baja hasta paralelo, sube explosivo',
        ],
        'rest': [
          '😮‍💨 Respira hondo, las piernas necesitan oxígeno',
          '🦵 Sacude las piernas, activa la circulación',
          '💪 El próximo set va a definir tus cuádriceps',
        ],
      },
      'Brazos': {
        'motivation': [
          '💪 Brazos de acero se forjan rep por rep',
          '🔥 Siente cómo crece ese pico de bíceps',
          '⚡ Cada curl te acerca a los brazos que quieres',
        ],
        'technique': [
          '🎯 Movimiento controlado, siente cada fibra trabajar',
          '⚠️ No uses impulso, aísla el músculo objetivo',
          '🔄 Contracción completa arriba, estiramiento abajo',
        ],
        'rest': [
          '💧 Hidrata esos músculos para la próxima serie',
          '🧠 Conecta mente-músculo para máxima activación',
          '💪 El próximo set va a explotar esos brazos',
        ],
      },
    };

    final muscleTips = tips[muscleGroup] ?? tips['Pecho']!;
    final contextTips = muscleTips[contextType] ?? muscleTips['motivation']!;
    contextTips.shuffle();
    return contextTips.first;
  }

  // 🏗️ Construir prompt inteligente para Groq
  static String _buildPrompt({
    required String muscleGroup,
    required String exerciseName,
    required String contextType,
    required int setNumber,
    required int totalSets,
  }) {
    final contextMap = {
      'motivation': 'motivacional y energético',
      'technique': 'técnico y educativo',
      'nutrition': 'nutricional y de recuperación',
      'rest': 'de descanso y mentalización',
    };

    return '''
Eres un entrenador personal experto y motivador. Genera un consejo ${contextMap[contextType]} para alguien que está descansando entre series.

Contexto:
- Grupo muscular: $muscleGroup
- Ejercicio: $exerciseName  
- Serie actual: $setNumber de $totalSets
- Tipo de consejo: $contextType

Requisitos:
- Máximo 25 palabras
- Tono casual y motivador (como "bro", "hermano")
- Incluye un emoji relevante
- Específico para el grupo muscular
- Práctico y aplicable

Ejemplo: "💪 Perfecto bro! Respira hondo y visualiza tu $muscleGroup creciendo. El próximo set va a ser legendario 🔥"

Consejo:''';
  }

  // 🎯 Obtener consejo específico por tipo
  static Future<String> getMotivationalTip(String muscleGroup, String exercise) {
    return generateGymTip(
      muscleGroup: muscleGroup,
      exerciseName: exercise,
      contextType: 'motivation',
      setNumber: 1,
      totalSets: 4,
    );
  }

  static Future<String> getTechniqueTip(String muscleGroup, String exercise) {
    return generateGymTip(
      muscleGroup: muscleGroup,
      exerciseName: exercise,
      contextType: 'technique',
      setNumber: 1,
      totalSets: 4,
    );
  }
}