import 'package:flutter/material.dart';
import 'package:lorem_ipsum_generator/lorem_ipsum_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSummaryScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const ProfileSummaryScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen> {
  bool _isGenerated = false;
  String _selectedTone = 'Default';
  String _generatedText = '';
  List<String> _currentTags = [];
  bool _isLoading = true;

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  final List<Map<String, dynamic>> _tones = [
    {'name': 'Default', 'icon': Icons.auto_awesome},
    {'name': 'Friendly', 'icon': Icons.sentiment_satisfied_alt},
    {'name': 'Professional', 'icon': Icons.work_outline},
    {'name': 'Humorous', 'icon': Icons.sentiment_very_satisfied},
  ];

  final Map<String, List<String>> _toneTags = {
    'Default': ['Creative', 'Adventurous', 'Curious', 'Outgoing', 'Calm', 'Passionate'],
    'Friendly': ['Warm', 'Approachable', 'Kind', 'Cheerful', 'Sociable', 'Helpful', 'Empathetic'],
    'Professional': ['Focused', 'Driven', 'Organized', 'Reliable', 'Strategic', 'Leader', 'Visionary'],
    'Humorous': ['Witty', 'Playful', 'Funny', 'Jokester', 'Clever', 'Silly', 'Sarcastic'],
  };

  final List<Color> _tagColors = [Colors.green, Colors.blue, Colors.redAccent];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final savedIsGenerated = await asyncPrefs.getBool('isGenerated_${widget.userId}') ?? false;
    
    if (savedIsGenerated) {
      _isGenerated = savedIsGenerated;
      _selectedTone = await asyncPrefs.getString('selectedTone_${widget.userId}') ?? 'Default';
      _generatedText = await asyncPrefs.getString('generatedText_${widget.userId}') ?? '';
      _currentTags = await asyncPrefs.getStringList('currentTags_${widget.userId}') ?? [];
      
      setState(() => _isLoading = false);
    } 
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profile_summaries')
          .select()
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _isGenerated = true;
          _selectedTone = response['selected_tone'];
          _generatedText = response['generated_text'];
          _currentTags = List<String>.from(response['current_tags']);
          _isLoading = false;
        });

        await asyncPrefs.setBool('isGenerated_${widget.userId}', true);
        await asyncPrefs.setString('selectedTone_${widget.userId}', _selectedTone);
        await asyncPrefs.setString('generatedText_${widget.userId}', _generatedText);
        await asyncPrefs.setStringList('currentTags_${widget.userId}', _currentTags);
      } else if (!savedIsGenerated) {
         setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Gagal sinkronisasi dari Supabase: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateSummary() async {
    setState(() => _isLoading = true);

    List<String> availableTags = List.from(_toneTags[_selectedTone] ?? _toneTags['Default']!);
    availableTags.shuffle();
    final newTags = availableTags.take(3).toList();
    
    final newText = LoremIpsumGenerator.generate(words: 70);

    setState(() {
      _currentTags = newTags;
      _generatedText = newText;
      _isGenerated = true;
    });

    await asyncPrefs.setBool('isGenerated_${widget.userId}', true);
    await asyncPrefs.setString('selectedTone_${widget.userId}', _selectedTone);
    await asyncPrefs.setString('generatedText_${widget.userId}', _generatedText);
    await asyncPrefs.setStringList('currentTags_${widget.userId}', _currentTags);

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profile_summaries').upsert({
        'user_id': widget.userId,
        'selected_tone': _selectedTone,
        'generated_text': _generatedText,
        'current_tags': _currentTags,
      });
    } catch (e) {
      debugPrint('Failed to save to Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved locally, but failed to sync to cloud.')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _deleteSummary() async {
    setState(() {
      _isGenerated = false;
      _selectedTone = 'Default';
      _generatedText = '';
      _currentTags = [];
      _isLoading = true;
    });

    await asyncPrefs.setBool('isGenerated_${widget.userId}', false);
    await asyncPrefs.remove('selectedTone_${widget.userId}');
    await asyncPrefs.remove('generatedText_${widget.userId}');
    await asyncPrefs.remove('currentTags_${widget.userId}');

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('profile_summaries')
          .delete()
          .eq('user_id', widget.userId);
    } catch (e) {
      debugPrint('Gagal menghapus dari Supabase: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isGenerated ? 'My Profile Summary' : 'Select Your Summary Tone',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isGenerated
                    ? _buildGeneratedView(cardColor, textColor, isDark)
                    : _buildSelectionView(cardColor, textColor, isDark),
              ),
      ),
    );
  }

  Widget _buildSelectionView(Color cardColor, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What tone would you like the profile summary to be generated in?',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _tones.length,
            itemBuilder: (context, index) {
              final tone = _tones[index];
              final isSelected = _selectedTone == tone['name'];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTone = tone['name']!);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tone['icon'] as IconData, 
                        size: 24, 
                        color: isSelected ? Colors.blue : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tone['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                          ),
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: _generateSummary,
            child: const Text(
              'Generate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedView(Color cardColor, Color textColor, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.auto_awesome, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(_currentTags.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildTag(_currentTags[index], _tagColors[index]),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _generatedText,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      height: 1.5
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_off_alt,
                        color: isDark ? Colors.grey.shade500 : Colors.grey
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.thumb_down_off_alt,
                        color: isDark ? Colors.grey.shade500 : Colors.grey
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _deleteSummary,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text(
                  'Delete Summary',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '*This profile summary is generated by artificial intelligence and is not intended to be precise.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade500 : Colors.grey
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
