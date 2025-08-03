import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'dart:math' as math;

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'RobotoMono',
      ),
      darkTheme: ThemeData.dark().copyWith(
        primarySwatch: Colors.blue,
        fontFamily: 'RobotoMono',
      ),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> with TickerProviderStateMixin {
  String _expression = '';
  String _result = '0';
  List<String> _history = [];
  double _memory = 0;
  bool _isDarkMode = false;
  bool _isScientificMode = false;
  bool _shouldResetOnNext = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadHistory();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isScientificMode = prefs.getBool('scientificMode') ?? false;
      _memory = prefs.getDouble('memory') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('scientificMode', _isScientificMode);
    await prefs.setDouble('memory', _memory);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
  }

  void _addToHistory(String expression, String result) {
    final entry = '$expression = $result';
    setState(() {
      _history.insert(0, entry);
      if (_history.length > 50) _history.removeLast();
    });
    _saveHistory();
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    _saveHistory();
  }

  void _vibrate() {
    if (Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.light);
    }
  }

  void _onButtonPressed(String buttonText) {
    _vibrate();
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      if (_shouldResetOnNext && '0123456789.'.contains(buttonText)) {
        _expression = '';
        _result = '0';
        _shouldResetOnNext = false;
      }

      switch (buttonText) {
        case 'AC':
          _expression = '';
          _result = '0';
          break;
        case 'C':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          break;
        case '=':
          _calculateResult();
          break;
        case 'MC':
          _memory = 0;
          _saveSettings();
          break;
        case 'MR':
          _expression += _memory.toString();
          break;
        case 'MS':
          if (_result != '0') {
            _memory = double.tryParse(_result) ?? 0;
            _saveSettings();
          }
          break;
        case 'M+':
          if (_result != '0') {
            _memory += double.tryParse(_result) ?? 0;
            _saveSettings();
          }
          break;
        case 'M-':
          if (_result != '0') {
            _memory -= double.tryParse(_result) ?? 0;
            _saveSettings();
          }
          break;
        case 'sin':
          _expression += 'sin(';
          break;
        case 'cos':
          _expression += 'cos(';
          break;
        case 'tan':
          _expression += 'tan(';
          break;
        case 'ln':
          _expression += 'ln(';
          break;
        case 'log':
          _expression += 'log(';
          break;
        case '√':
          _expression += 'sqrt(';
          break;
        case '^':
          _expression += '^';
          break;
        case 'π':
          _expression += math.pi.toString();
          break;
        case 'e':
          _expression += math.e.toString();
          break;
        case '(':
        case ')':
        case '+':
        case '-':
        case '*':
        case '/':
        case '%':
        case '.':
          _expression += buttonText;
          break;
        default:
          if ('0123456789'.contains(buttonText)) {
            _expression += buttonText;
          }
          break;
      }
    });
  }

  void _calculateResult() {
    try {
      String expression = _expression;
      
      // Replace common mathematical functions and constants
      expression = expression.replaceAll('×', '*');
      expression = expression.replaceAll('÷', '/');
      
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      
      double result = exp.evaluate(EvaluationType.REAL, cm);
      
      if (result.isInfinite || result.isNaN) {
        _result = 'Error';
      } else {
        _result = _formatNumber(result);
        _addToHistory(_expression, _result);
        _shouldResetOnNext = true;
      }
    } catch (e) {
      _result = 'Error';
    }
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      String formatted = number.toStringAsFixed(10);
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.black : Colors.grey[100],
        appBar: AppBar(
          title: Text('Calculator'),
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          foregroundColor: _isDarkMode ? Colors.white : Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
                _saveSettings();
              },
            ),
            IconButton(
              icon: Icon(_isScientificMode ? Icons.functions : Icons.calculate),
              onPressed: () {
                setState(() {
                  _isScientificMode = !_isScientificMode;
                });
                _saveSettings();
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: _showHistory,
            ),
          ],
        ),
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: TextStyle(
                          fontSize: 24,
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'RobotoMono',
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'RobotoMono',
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Button area
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _isScientificMode ? _buildScientificKeypad() : _buildBasicKeypad(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicKeypad() {
    return Column(
      children: [
        _buildButtonRow(['MC', 'MR', 'MS', 'M+', 'M-']),
        _buildButtonRow(['AC', 'C', '%', '÷']),
        _buildButtonRow(['7', '8', '9', '×']),
        _buildButtonRow(['4', '5', '6', '-']),
        _buildButtonRow(['1', '2', '3', '+']),
        _buildButtonRow(['0', '.', '=']),
      ],
    );
  }

  Widget _buildScientificKeypad() {
    return Column(
      children: [
        _buildButtonRow(['MC', 'MR', 'MS', 'M+', 'M-']),
        _buildButtonRow(['sin', 'cos', 'tan', 'ln', 'log']),
        _buildButtonRow(['(', ')', '^', '√', 'π']),
        _buildButtonRow(['AC', 'C', '%', '÷', 'e']),
        _buildButtonRow(['7', '8', '9', '×']),
        _buildButtonRow(['4', '5', '6', '-']),
        _buildButtonRow(['1', '2', '3', '+']),
        _buildButtonRow(['0', '.', '=']),
      ],
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) => _buildButton(button)).toList(),
      ),
    );
  }

  Widget _buildButton(String text) {
    Color buttonColor;
    Color textColor;
    
    if (['='].contains(text)) {
      buttonColor = Colors.blue;
      textColor = Colors.white;
    } else if (['AC', 'C', '÷', '×', '-', '+', '%', '^'].contains(text)) {
      buttonColor = _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
      textColor = _isDarkMode ? Colors.white : Colors.black;
    } else if (['MC', 'MR', 'MS', 'M+', 'M-', 'sin', 'cos', 'tan', 'ln', 'log', '√', 'π', 'e', '(', ')'].contains(text)) {
      buttonColor = _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
      textColor = _isDarkMode ? Colors.blue[300]! : Colors.blue[700]!;
    } else {
      buttonColor = _isDarkMode ? Colors.grey[850]! : Colors.white;
      textColor = _isDarkMode ? Colors.white : Colors.black;
    }

    return Expanded(
      flex: text == '0' ? 2 : 1,
      child: Container(
        margin: EdgeInsets.all(4),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ElevatedButton(
            onPressed: () => _onButtonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: text.length > 2 ? 14 : 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.clear_all),
                        onPressed: () {
                          _clearHistory();
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _history.isEmpty
                  ? Center(
                      child: Text(
                        'No calculations yet',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _history[index],
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                          onTap: () {
                            final parts = _history[index].split(' = ');
                            if (parts.length == 2) {
                              setState(() {
                                _expression = parts[0];
                                _result = parts[1];
                              });
                            }
                            Navigator.pop(context);
                          },
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
