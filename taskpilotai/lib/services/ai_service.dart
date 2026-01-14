import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class AIService {
  final String? apiKey;
  final String baseUrl = 'https://api.openai.com/v1';

  AIService({this.apiKey});

  Future<Map<String, dynamic>> parseTaskFromText(String userInput) async {
    if (apiKey == null || apiKey!.isEmpty) {
      // Fallback to simple parsing if no API key
      return _simpleParseTask(userInput);
    }

    try {
      final prompt = '''
Parse the following task description and extract structured information.
Return a JSON object with: title, description, priority (low/medium/high), suggested_tags (array), and estimated_due_date (YYYY-MM-DD or null).

User input: "$userInput"

Return only valid JSON, no markdown formatting.
''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task management assistant. Parse user input and return structured task data as JSON only.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final cleanedContent = content.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanedContent);
      } else {
        return _simpleParseTask(userInput);
      }
    } catch (e) {
      return _simpleParseTask(userInput);
    }
  }

  Future<List<String>> suggestTags(String taskTitle, List<Task> existingTasks) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _extractSimpleTags(taskTitle);
    }

    try {
      final existingTags = existingTasks
          .expand((task) => task.tags)
          .toSet()
          .take(10)
          .join(', ');

      final prompt = '''
Given the task title: "$taskTitle"
And existing tags in the system: $existingTags

Suggest 2-4 relevant tags for this task. Return only a JSON array of tag strings.
''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task tagging assistant. Return only a JSON array of tag strings.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.5,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final cleanedContent = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final tags = jsonDecode(cleanedContent) as List;
        return tags.cast<String>();
      } else {
        return _extractSimpleTags(taskTitle);
      }
    } catch (e) {
      return _extractSimpleTags(taskTitle);
    }
  }

  Future<TaskPriority> suggestPriority(String taskTitle, String? description) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return TaskPriority.medium;
    }

    try {
      final prompt = '''
Analyze this task and determine its priority level (low, medium, or high).
Consider urgency, importance, and deadlines.

Task: "$taskTitle"
${description != null ? 'Description: "$description"' : ''}

Return only one word: "low", "medium", or "high".
''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task prioritization assistant. Return only one word: low, medium, or high.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.2,
          'max_tokens': 10,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim().toLowerCase();
        if (content.contains('high')) return TaskPriority.high;
        if (content.contains('low')) return TaskPriority.low;
        return TaskPriority.medium;
      } else {
        return TaskPriority.medium;
      }
    } catch (e) {
      return TaskPriority.medium;
    }
  }

  Future<List<Task>> breakDownTask(String complexTask) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return [Task(
        id: '',
        title: complexTask,
        createdAt: DateTime.now(),
      )];
    }

    try {
      final prompt = '''
Break down this complex task into 3-5 smaller, actionable subtasks.
Return a JSON array of task titles (strings only).

Complex task: "$complexTask"
''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task breakdown assistant. Return only a JSON array of task title strings.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.4,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final cleanedContent = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final titles = jsonDecode(cleanedContent) as List;
        
        return titles.map((title) => Task(
          id: '',
          title: title.toString(),
          createdAt: DateTime.now(),
        )).toList();
      } else {
        return [Task(
          id: '',
          title: complexTask,
          createdAt: DateTime.now(),
        )];
      }
    } catch (e) {
      return [Task(
        id: '',
        title: complexTask,
        createdAt: DateTime.now(),
      )];
    }
  }

  Future<String> generateTaskSummary(List<Task> tasks) async {
    if (apiKey == null || apiKey!.isEmpty || tasks.isEmpty) {
      return 'You have ${tasks.length} tasks.';
    }

    try {
      final taskSummary = tasks.take(10).map((t) => '- ${t.title} (${t.status.name})').join('\n');
      
      final prompt = '''
Summarize these tasks in a brief, motivating way (2-3 sentences):
$taskSummary
''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a productivity assistant. Provide brief, motivating task summaries.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'You have ${tasks.length} tasks.';
      }
    } catch (e) {
      return 'You have ${tasks.length} tasks.';
    }
  }

  // Fallback methods when API is not available
  Map<String, dynamic> _simpleParseTask(String input) {
    final words = input.toLowerCase().split(' ');
    TaskPriority priority = TaskPriority.medium;
    
    if (words.any((w) => ['urgent', 'asap', 'important', 'critical'].contains(w))) {
      priority = TaskPriority.high;
    } else if (words.any((w) => ['later', 'someday', 'maybe'].contains(w))) {
      priority = TaskPriority.low;
    }

    return {
      'title': input,
      'description': null,
      'priority': priority.name,
      'suggested_tags': _extractSimpleTags(input),
      'estimated_due_date': null,
    };
  }

  List<String> _extractSimpleTags(String text) {
    final commonTags = ['work', 'personal', 'urgent', 'shopping', 'health', 'finance'];
    final lowerText = text.toLowerCase();
    return commonTags.where((tag) => lowerText.contains(tag)).take(3).toList();
  }
}

