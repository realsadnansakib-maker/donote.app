import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DoNoteApp());
}

// ─── THEME ───────────────────────────────────────────────────────────────────

class AppTheme {
  // Dark
  static const darkBg       = Color(0xFF0A0E1A);
  static const darkSurface  = Color(0xFF141828);
  static const darkSurface2 = Color(0xFF1E2340);
  // Light
  static const lightBg      = Color(0xFFF0F2FF);
  static const lightSurface = Color(0xFFFFFFFF);
  // Accents
  static const purple  = Color(0xFF6C63FF);
  static const purple2 = Color(0xFF4A42D0);
  static const cyan    = Color(0xFF00D4FF);
  static const pink    = Color(0xFFFF6584);
  static const green   = Color(0xFF43E97B);
  static const orange  = Color(0xFFFF9F43);
}

// ─── MODELS ──────────────────────────────────────────────────────────────────

class TodoItem {
  final int id;
  String title;
  bool isDone;
  String category;
  Color color;
  DateTime? dueDate;
  TimeOfDay? dueTime;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.category,
    required this.color,
    this.dueDate,
    this.dueTime,
  });

  String get dueDateLabel {
    if (dueDate == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    String s = '${dueDate!.day} ${months[dueDate!.month - 1]}';
    if (dueTime != null) {
      final h = dueTime!.hourOfPeriod == 0 ? 12 : dueTime!.hourOfPeriod;
      final m = dueTime!.minute.toString().padLeft(2, '0');
      final period = dueTime!.period == DayPeriod.am ? 'AM' : 'PM';
      s += ' · $h:$m $period';
    }
    return s;
  }
}

// ─── APP ─────────────────────────────────────────────────────────────────────

class DoNoteApp extends StatefulWidget {
  const DoNoteApp({super.key});

  @override
  State<DoNoteApp> createState() => _DoNoteAppState();
}

class _DoNoteAppState extends State<DoNoteApp> {
  bool isDark = true;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        fontFamily: 'Nunito',
        colorScheme: isDark
            ? ColorScheme.dark(primary: AppTheme.purple)
            : ColorScheme.light(primary: AppTheme.purple),
      ),
      home: HomeScreen(isDark: isDark, onToggleTheme: toggleTheme),
    );
  }
}

// ─── HOME SCREEN ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<TodoItem> _todos = [
    TodoItem(id: 1, title: 'Morning yoga session',    isDone: true,  category: 'Health',   color: AppTheme.purple),
    TodoItem(id: 2, title: 'Review project proposal', isDone: false, category: 'Work',     color: AppTheme.cyan),
    TodoItem(id: 3, title: 'Buy groceries',           isDone: false, category: 'Personal', color: AppTheme.pink),
    TodoItem(id: 4, title: 'Read 30 pages',           isDone: false, category: 'Learning', color: AppTheme.green),
  ];

  Color get bg       => widget.isDark ? AppTheme.darkBg      : AppTheme.lightBg;
  Color get surface  => widget.isDark ? AppTheme.darkSurface  : AppTheme.lightSurface;
  Color get surface2 => widget.isDark ? AppTheme.darkSurface2 : AppTheme.lightSurface;
  Color get textColor => widget.isDark ? Colors.white : const Color(0xFF1a1a2e);
  Color get dimText   => widget.isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45);

  void _toggleTodo(int id) {
    setState(() {
      final t = _todos.firstWhere((t) => t.id == id);
      t.isDone = !t.isDone;
    });
  }

  void _deleteTodo(int id) {
    setState(() => _todos.removeWhere((t) => t.id == id));
  }

  void _clearDone() {
    setState(() => _todos.removeWhere((t) => t.isDone));
  }

  void _addTodo(String title, String cat, Color color, DateTime? date, TimeOfDay? time) {
    setState(() {
      _todos.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        category: cat,
        color: color,
        dueDate: date,
        dueTime: time,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background orbs
          _buildOrbs(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          // Bottom nav
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),
          // FAB
          if (_selectedIndex == 1)
            Positioned(
              bottom: 90, right: 24,
              child: _buildFAB(),
            ),
        ],
      ),
    );
  }

  // ── BACKGROUND ORBS ──
  Widget _buildOrbs() {
    return Stack(children: [
      Positioned(
        top: -80, right: -60,
        child: Container(
          width: 280, height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.purple.withOpacity(0.25),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      Positioned(
        bottom: 60, left: -80,
        child: Container(
          width: 240, height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.cyan.withOpacity(0.15),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }

  // ── TOP BAR ──
  Widget _buildTopBar() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning 👋'
        : hour < 17 ? 'Good Afternoon 👋'
        : 'Good Evening 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple2],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.4),
                  blurRadius: 14, offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: Text('📝', style: TextStyle(fontSize: 20))),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: TextStyle(color: dimText, fontSize: 12, fontWeight: FontWeight.w500)),
              Text('Do Note', style: TextStyle(
                color: textColor, fontSize: 22,
                fontWeight: FontWeight.w900, letterSpacing: -0.5,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return CalendarTab(isDark: widget.isDark, todos: _todos);
      case 1: return TodoTab(
        isDark: widget.isDark, todos: _todos,
        onToggle: _toggleTodo, onDelete: _deleteTodo, onClearDone: _clearDone,
      );
      case 2: return SettingsTab(
        isDark: widget.isDark, onToggleTheme: widget.onToggleTheme,
      );
      default: return SizedBox();
    }
  }

  // ── BOTTOM NAV ──
  Widget _buildBottomNav() {
    final items = [
      {'icon': '📅', 'label': 'Calendar'},
      {'icon': '✅', 'label': 'Tasks'},
      {'icon': '⚙️', 'label': 'Settings'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppTheme.darkBg.withOpacity(0.95)
            : AppTheme.lightBg.withOpacity(0.97),
        border: Border(top: BorderSide(
          color: widget.isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.07),
        )),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: active
                    ? AppTheme.purple.withOpacity(0.15)
                    : Colors.transparent,
                border: active
                    ? Border.all(color: AppTheme.purple.withOpacity(0.25))
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(items[i]['icon']!, style: TextStyle(fontSize: 22)),
                  SizedBox(height: 4),
                  Text(
                    items[i]['label']!,
                    style: TextStyle(
                      color: active ? AppTheme.purple
                          : widget.isDark
                              ? Colors.white.withOpacity(0.30)
                              : Colors.black.withOpacity(0.38),
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── FAB ──
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => _showAddTaskSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [AppTheme.purple, AppTheme.purple2],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.45),
              blurRadius: 20, offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text('Add Task', style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800,
            )),
          ],
        ),
      ),
    );
  }

  // ── ADD TASK SHEET ──
  void _showAddTaskSheet(BuildContext context) {
    final cats = [
      {'name': 'Work',     'color': AppTheme.cyan},
      {'name': 'Personal', 'color': AppTheme.pink},
      {'name': 'Health',   'color': AppTheme.purple},
      {'name': 'Learning', 'color': AppTheme.green},
    ];
    String selectedCat = 'Work';
    Color selectedColor = AppTheme.cyan;
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? AppTheme.darkSurface2 : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('New Task', style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1a1a2e),
                  fontSize: 22, fontWeight: FontWeight.w900,
                )),
                SizedBox(height: 16),
                // Title input
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  style: TextStyle(color: widget.isDark ? Colors.white : const Color(0xFF1a1a2e)),
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    filled: true,
                    fillColor: widget.isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 16),
                // Date & Time row
                Text('Due Date & Time', style: TextStyle(
                  color: widget.isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45),
                  fontSize: 12, fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (c, w) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(primary: AppTheme.purple),
                            ),
                            child: w!,
                          ),
                        );
                        if (d != null) setSheet(() => selectedDate = d);
                      },
                      child: _dateTimeChip(
                        '📅',
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime,
                          builder: (c, w) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(primary: AppTheme.purple),
                            ),
                            child: w!,
                          ),
                        );
                        if (t != null) setSheet(() => selectedTime = t);
                      },
                      child: _dateTimeChip(
                        '⏰',
                        selectedTime.format(context),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 16),
                // Category
                Text('Category', style: TextStyle(
                  color: widget.isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45),
                  fontSize: 12, fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: cats.map((c) {
                    final isSelected = selectedCat == c['name'];
                    final col = c['color'] as Color;
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        selectedCat = c['name'] as String;
                        selectedColor = col;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? col.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected ? col : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          c['name'] as String,
                          style: TextStyle(
                            color: isSelected ? col : Colors.white.withOpacity(0.38),
                            fontSize: 12, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 22),
                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        _addTodo(
                          titleCtrl.text.trim(),
                          selectedCat,
                          selectedColor,
                          selectedDate,
                          selectedTime,
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Add Task', style: TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTimeChip(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(
              color: widget.isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.54),
              fontSize: 12, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }
}

// ─── CALENDAR TAB ─────────────────────────────────────────────────────────────

class CalendarTab extends StatefulWidget {
  final bool isDark;
  final List<TodoItem> todos;

  const CalendarTab({super.key, required this.isDark, required this.todos});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _currentMonth = DateTime(2026, 3);
  int _selectedDay = 8;

  Color get surface => widget.isDark ? AppTheme.darkSurface : Colors.white;
  Color get textColor => widget.isDark ? Colors.white : const Color(0xFF1a1a2e);
  Color get dimText => widget.isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalHeader(),
          SizedBox(height: 12),
          _buildSummaryRow(),
          SizedBox(height: 16),
          _buildDayLabels(),
          SizedBox(height: 6),
          _buildCalGrid(),
          SizedBox(height: 20),
          Text('Upcoming Events', style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.w800,
          )),
          SizedBox(height: 12),
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildCalHeader() {
    final months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return Row(
      children: [
        _navBtn('‹', () => setState(() {
          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
        })),
        Expanded(
          child: Center(
            child: Text(
              '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        _navBtn('›', () => setState(() {
          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
        })),
      ],
    );
  }

  Widget _navBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: surface,
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: dimText, fontSize: 18, fontWeight: FontWeight.w700,
          )),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final pending = widget.todos.where((t) => !t.isDone).length;
    final done = widget.todos.where((t) => t.isDone).length;
    return Row(
      children: [
        _summaryCard('${widget.todos.length}', 'Total',   AppTheme.purple),
        SizedBox(width: 10),
        _summaryCard('$pending',               'Pending', AppTheme.cyan),
        SizedBox(width: 10),
        _summaryCard('$done',                  'Done',    AppTheme.green),
      ],
    );
  }

  Widget _summaryCard(String num, String lbl, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(num, style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w900,
            )),
            SizedBox(height: 2),
            Text(lbl, style: TextStyle(color: dimText, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabels() {
    const days = ['S','M','T','W','T','F','S'];
    return Row(
      children: days.map((d) => Expanded(
        child: Center(
          child: Text(d, style: TextStyle(
            color: dimText, fontSize: 11, fontWeight: FontWeight.w800,
          )),
        ),
      )).toList(),
    );
  }

  Widget _buildCalGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final prevDays = DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    final List<_CalDay> days = [];
    for (int i = firstDay - 1; i >= 0; i--) {
      days.add(_CalDay(day: prevDays - i, isCurrentMonth: false));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(_CalDay(day: d, isCurrentMonth: true));
    }
    final remaining = (7 - days.length % 7) % 7;
    for (int i = 1; i <= remaining; i++) {
      days.add(_CalDay(day: i, isCurrentMonth: false));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4,
      ),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final isToday = day.isCurrentMonth &&
            _currentMonth.month == 3 && _currentMonth.year == 2026 && day.day == 8;
        final isSelected = day.isCurrentMonth && day.day == _selectedDay &&
            _currentMonth.month == 3 && _currentMonth.year == 2026;
        final hasDot = isToday && widget.todos.any((t) => !t.isDone);

        return GestureDetector(
          onTap: () {
            if (day.isCurrentMonth) setState(() => _selectedDay = day.day);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isToday
                  ? LinearGradient(
                      colors: [AppTheme.purple, AppTheme.purple2],
                    )
                  : null,
              color: isToday ? null
                  : isSelected ? AppTheme.purple.withOpacity(0.18)
                  : Colors.transparent,
              border: isSelected && !isToday
                  ? Border.all(color: AppTheme.purple.withOpacity(0.4))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: !day.isCurrentMonth
                        ? (widget.isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.26))
                        : isToday ? Colors.white
                        : isSelected ? AppTheme.purple
                        : textColor,
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
                if (hasDot) ...[
                  SizedBox(height: 2),
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? Colors.white.withOpacity(0.70) : AppTheme.cyan,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    if (widget.todos.isEmpty) {
      return Center(
        child: Text('No tasks yet', style: TextStyle(color: dimText, fontSize: 13)),
      );
    }
    final sorted = [
      ...widget.todos.where((t) => !t.isDone),
      ...widget.todos.where((t) => t.isDone),
    ];
    return Column(
      children: sorted.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: t.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 4, height: 44,
                decoration: BoxDecoration(
                  color: t.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        color: t.isDone
                            ? (widget.isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38))
                            : textColor,
                        fontSize: 14, fontWeight: FontWeight.w700,
                        decoration: t.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '🏷 ${t.category}${t.dueDateLabel.isNotEmpty ? ' · 📅 ${t.dueDateLabel}' : ''}',
                      style: TextStyle(color: dimText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.isDone ? '✓ Done' : 'Pending',
                  style: TextStyle(color: t.color, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _CalDay {
  final int day;
  final bool isCurrentMonth;
  _CalDay({required this.day, required this.isCurrentMonth});
}

// ─── TODO TAB ────────────────────────────────────────────────────────────────

class TodoTab extends StatelessWidget {
  final bool isDark;
  final List<TodoItem> todos;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final VoidCallback onClearDone;

  const TodoTab({
    super.key,
    required this.isDark,
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onClearDone,
  });

  Color get surface => isDark ? AppTheme.darkSurface : Colors.white;
  Color get textColor => isDark ? Colors.white : const Color(0xFF1a1a2e);
  Color get dimText => isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45);

  @override
  Widget build(BuildContext context) {
    final pending = todos.where((t) => !t.isDone).toList();
    final done = todos.where((t) => t.isDone).toList();
    final pct = todos.isEmpty ? 0.0 : done.length / todos.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(done.length, todos.length, pct),
          SizedBox(height: 24),
          if (pending.isNotEmpty) ...[
            _buildSectionHeader('Pending', pending.length, false),
            SizedBox(height: 10),
            ...pending.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTodoCard(t),
            )),
            SizedBox(height: 8),
          ],
          if (done.isNotEmpty) ...[
            _buildSectionHeader('Completed', done.length, true),
            SizedBox(height: 10),
            ...done.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTodoCard(t),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(int done, int total, double pct) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.purple, AppTheme.purple2],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.4),
            blurRadius: 28, offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Tasks", style: TextStyle(
                    color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '$done',
                        style: TextStyle(
                          color: Colors.white, fontSize: 36,
                          fontWeight: FontWeight.w900, height: 1,
                        ),
                      ),
                      TextSpan(
                        text: '/$total',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45), fontSize: 20, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                  ),
                  Text('tasks done', style: TextStyle(
                    color: Colors.white.withOpacity(0.54), fontSize: 12,
                  )),
                ],
              ),
              Spacer(),
              SizedBox(
                width: 72, height: 72,
                child: CustomPaint(
                  painter: CircleProgressPainter(pct),
                  child: Center(
                    child: Text(
                      '${(pct * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.24),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label, int count, bool showClear) {
    return Row(
      children: [
        Text(label, style: TextStyle(
          color: textColor, fontSize: 16, fontWeight: FontWeight.w800,
        )),
        SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.purple.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count', style: TextStyle(
            color: AppTheme.purple, fontSize: 11, fontWeight: FontWeight.w800,
          )),
        ),
        if (showClear && count > 0) ...[
          Spacer(),
          GestureDetector(
            onTap: onClearDone,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.pink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.pink.withOpacity(0.3)),
              ),
              child: Text('🗑 Clear All', style: TextStyle(
                color: AppTheme.pink, fontSize: 11, fontWeight: FontWeight.w800,
              )),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodoCard(TodoItem t) {
    return Dismissible(
      key: Key('${t.id}'),
      direction: t.isDone ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppTheme.pink.withOpacity(0.2),
        ),
        child: Icon(Icons.delete_rounded, color: AppTheme.pink),
      ),
      onDismissed: (_) => onDelete(t.id),
      child: GestureDetector(
        onTap: () => onToggle(t.id),
        child: AnimatedOpacity(
          opacity: t.isDone ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: t.isDone
                    ? (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.06))
                    : t.color.withOpacity(0.28),
              ),
              boxShadow: t.isDone ? [] : [
                BoxShadow(
                  color: t.color.withOpacity(0.07),
                  blurRadius: 12, offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.isDone ? t.color : Colors.transparent,
                    border: Border.all(
                      color: t.isDone ? t.color : Colors.white.withOpacity(0.24),
                      width: 2,
                    ),
                  ),
                  child: t.isDone
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : null,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          color: t.isDone
                              ? (isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38))
                              : textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: t.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(t.category, style: TextStyle(
                              color: t.color, fontSize: 10, fontWeight: FontWeight.w800,
                            )),
                          ),
                          if (t.dueDateLabel.isNotEmpty) ...[
                            SizedBox(width: 6),
                            Text('📅 ${t.dueDateLabel}', style: TextStyle(
                              color: dimText, fontSize: 10, fontWeight: FontWeight.w500,
                            )),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (t.isDone)
                  GestureDetector(
                    onTap: () => onDelete(t.id),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.pink.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.pink.withOpacity(0.25)),
                      ),
                      child: Center(
                        child: Text('🗑', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  )
                else
                  Icon(Icons.drag_handle_rounded,
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SETTINGS TAB ────────────────────────────────────────────────────────────

class SettingsTab extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SettingsTab({super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _selectedLang = 'English';

  final _langs = [
    {'flag': '🇬🇧', 'label': 'English'},
    {'flag': '🇧🇩', 'label': 'বাংলা'},
    {'flag': '🇮🇳', 'label': 'हिंदी'},
    {'flag': '🇸🇦', 'label': 'العربية'},
    {'flag': '🇫🇷', 'label': 'Français'},
    {'flag': '🇩🇪', 'label': 'Deutsch'},
    {'flag': '🇨🇳', 'label': '中文'},
    {'flag': '🇪🇸', 'label': 'Español'},
  ];

  Color get surface => widget.isDark ? AppTheme.darkSurface : Colors.white;
  Color get textColor => widget.isDark ? Colors.white : const Color(0xFF1a1a2e);
  Color get dimText => widget.isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.45);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: TextStyle(
            color: textColor, fontSize: 22, fontWeight: FontWeight.w900,
          )),
          Text('Customize your experience', style: TextStyle(
            color: dimText, fontSize: 13,
          )),
          SizedBox(height: 24),

          _sectionTitle('Appearance'),
          _settingsCard([
            _settingsRow(
              icon: '🌙',
              iconBg: AppTheme.purple.withOpacity(0.15),
              label: 'Dark Mode',
              sub: 'Switch between dark & light',
              trailing: GestureDetector(
                onTap: widget.onToggleTheme,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46, height: 26,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: widget.isDark
                        ? AppTheme.purple
                        : Colors.black.withOpacity(0.15),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: widget.isDark
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),

          SizedBox(height: 20),
          _sectionTitle('General'),
          _settingsCard([
            _settingsRow(
              icon: '🌐',
              iconBg: AppTheme.cyan.withOpacity(0.15),
              label: 'Language',
              sub: _selectedLang,
              trailing: Icon(Icons.chevron_right_rounded, color: dimText),
              onTap: () => _showLangSheet(context),
            ),
          ]),

          SizedBox(height: 20),
          _sectionTitle('About'),
          _settingsCard([
            _settingsRow(
              icon: '📱',
              iconBg: AppTheme.green.withOpacity(0.15),
              label: 'About Do Note',
              sub: 'Version 1.0',
              trailing: Icon(Icons.chevron_right_rounded, color: dimText),
              onTap: () => _showAboutSheet(context),
            ),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            _settingsRow(
              icon: '⭐',
              iconBg: AppTheme.orange.withOpacity(0.15),
              label: 'Rate the App',
              sub: 'Love it? Give us 5 stars!',
              trailing: Icon(Icons.chevron_right_rounded, color: dimText),
            ),
          ]),

          SizedBox(height: 32),
          Center(
            child: Column(children: [
              Text('📝', style: TextStyle(fontSize: 28)),
              SizedBox(height: 6),
              Text('Do Note', style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.w900,
              )),
              SizedBox(height: 2),
              Text('Made with ❤️ · v1.0', style: TextStyle(color: dimText, fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: dimText, fontSize: 11,
          fontWeight: FontWeight.w800, letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }

  Widget _settingsRow({
    required String icon,
    required Color iconBg,
    required String label,
    required String sub,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: TextStyle(fontSize: 18))),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    color: textColor, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                  Text(sub, style: TextStyle(color: dimText, fontSize: 11)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLangSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.darkSurface2 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.24), borderRadius: BorderRadius.circular(2),
              ),
            )),
            SizedBox(height: 16),
            Text('🌐 Language', style: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.w900,
            )),
            SizedBox(height: 12),
            ..._langs.map((l) => GestureDetector(
              onTap: () {
                setState(() => _selectedLang = l['label']!);
                Navigator.pop(ctx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedLang == l['label']
                      ? AppTheme.purple.withOpacity(0.12)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Text(l['flag']!, style: TextStyle(fontSize: 22)),
                    SizedBox(width: 14),
                    Text(l['label']!, style: TextStyle(
                      color: _selectedLang == l['label'] ? AppTheme.purple : textColor,
                      fontSize: 14, fontWeight: FontWeight.w700,
                    )),
                    if (_selectedLang == l['label']) ...[
                      Spacer(),
                      Icon(Icons.check_rounded, color: AppTheme.purple, size: 18),
                    ],
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.darkSurface2 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.24), borderRadius: BorderRadius.circular(2),
              ),
            )),
            SizedBox(height: 16),
            Text('📝', style: TextStyle(fontSize: 52)),
            SizedBox(height: 10),
            Text('Do Note', style: TextStyle(
              color: textColor, fontSize: 22, fontWeight: FontWeight.w900,
            )),
            Text('Version 1.0', style: TextStyle(color: dimText, fontSize: 12)),
            SizedBox(height: 20),
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.purple.withOpacity(0.2)),
              ),
              child: Text(
                'Do Note is a simple and friendly task manager app designed to help you stay organized and productive. With this app, you can easily create tasks, manage your daily work, and track your progress.',
                style: TextStyle(color: widget.isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.54),
                    fontSize: 13, height: 1.7),
              ),
            ),
            SizedBox(height: 12),
            // Developer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DEVELOPER', style: TextStyle(
                    color: dimText, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1,
                  )),
                  SizedBox(height: 10),
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [AppTheme.purple, AppTheme.purple2],
                        ),
                      ),
                      child: Center(child: Text('S', style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900,
                      ))),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sadnan Sakib', style: TextStyle(
                          color: textColor, fontSize: 14, fontWeight: FontWeight.w800,
                        )),
                        Text('👨‍💻 60%  ·  🤖 AI 40%', style: TextStyle(
                          color: dimText, fontSize: 11,
                        )),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Thank you
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.purple.withOpacity(0.15),
                  AppTheme.cyan.withOpacity(0.1),
                ]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.purple.withOpacity(0.2)),
              ),
              child: Column(children: [
                Text('🙏', style: TextStyle(fontSize: 20)),
                SizedBox(height: 6),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Thank you for using ',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.54),
                        fontSize: 13, height: 1.6,
                      ),
                    ),
                    const TextSpan(
                      text: 'Do Note',
                      style: TextStyle(
                        color: AppTheme.purple, fontWeight: FontWeight.w800, fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: '.\nStay organized and productive!',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.54),
                        fontSize: 13, height: 1.6,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── CIRCLE PROGRESS PAINTER ─────────────────────────────────────────────────

class CircleProgressPainter extends CustomPainter {
  final double progress;
  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter old) => old.progress != progress;
}
