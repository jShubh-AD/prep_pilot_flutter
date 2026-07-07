import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubjectCard extends StatefulWidget {
  final SubjectItem subjects;
  final VoidCallback onTap;
  final int index;

  const SubjectCard({
    super.key,
    required this.subjects,
    required this.onTap,
    required this.index,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  final List<List<Color>> _gradients = [
    [Color(0xFF6366F1), Color(0xFF4F46E5)],
    [Color(0xFFEC4899), Color(0xFFD946EF)],
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFF3B82F6), Color(0xFF2563EB)],
    [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradient() {
    return _gradients[widget.index % _gradients.length];
  }

  IconData _getIcon() {
    final name = widget.subjects.subjectName.toString().toLowerCase();

    if (name.contains('java') || name.contains('oop')) {
      return Icons.code;
    } else if (name.contains('ai') || name.contains('model')) {
      return Icons.psychology;
    } else if (name.contains('os') || name.contains('system')) {
      return Icons.settings_applications;
    } else if (name.contains('db') || name.contains('sql')) {
      return Icons.storage;
    } else if (name.contains('math')) {
      return Icons.functions;
    }
    return Icons.menu_book;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGradient();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[1].withOpacity(_isHovered ? 0.5 : 0.3),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: Offset(0, _isHovered ? 6 : 4),
                )
              ],
            ),

            // ⭐ FIXED HEIGHT STRUCTURE
            child: SizedBox(
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TOP ROW
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 8),

                      if (widget.subjects.subjectCodes != null &&
                          widget.subjects.subjectCodes!.isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.subjects.subjectCodes!.first,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// SUBJECT NAME
                  Text(
                    widget.subjects.subjectName ?? 'Unknown Subject',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  /// PUSH BOTTOM
                  const Spacer(),

                  /// BOTTOM ROW (FIXED ALIGNMENT)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Start Now',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}