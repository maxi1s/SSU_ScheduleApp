import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String title;
  final T? value;
  final List<T> items;
  final String Function(T item)? displayText;
  final IconData? icon;
  final Function(T?) onChanged;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayText,
    this.icon,
    this.enabled = true,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    _toggleDropdown();
  }

  String _getDisplayText(T item) {
    if (widget.displayText != null) {
      return widget.displayText!(item);
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.enabled ? Colors.black87 : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // Основной контейнер дропдауна
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.enabled
                  ? (_isExpanded ? Colors.blue : Colors.grey)
                  : Colors.grey[300]!,
              width: _isExpanded ? 2 : 1,
            ),
            boxShadow: [
              if (_isExpanded)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              // Выбранное значение
              ListTile(
                leading: widget.icon != null
                    ? Icon(widget.icon, color: _getIconColor())
                    : null,
                title: Text(
                  widget.value != null
                      ? _getDisplayText(widget.value as T)
                      : 'Выберите ${widget.title.toLowerCase()}',
                  style: TextStyle(
                    color: widget.value != null ? Colors.black87 : Colors.grey,
                    fontWeight: widget.value != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: RotationTransition(
                  turns: _animation,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _getIconColor(),
                  ),
                ),
                onTap: _toggleDropdown,
                tileColor: Colors.transparent,
              ),

              // Выпадающий список
              SizeTransition(
                sizeFactor: _animation,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = widget.value == item;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _selectItem(item),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[50]
                                  : (Theme.of(context).hoverColor),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: isSelected
                                  ? const Icon(Icons.check, color: Colors.blue, size: 20)
                                  : const SizedBox(width: 20),
                              title: Text(
                                _getDisplayText(item),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.blue : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getIconColor() {
    if (!widget.enabled) return Colors.grey;
    return _isExpanded ? Colors.blue : Colors.grey[600]!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}