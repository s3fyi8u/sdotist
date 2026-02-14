import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _displayController = TextEditingController(); // Added display controller
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _displayController.text = widget.value ?? ''; // Initialize text
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _displayController.text = widget.value ?? ''; // Update text on change
    }
  }

  void _showSelectionSheet(BuildContext context) {
    _searchController.clear();
    _filteredItems = widget.items;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            
            return Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7, // Limit height
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Select ${widget.label}',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            _filteredItems = widget.items
                                .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // List
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(
                              child: Text('No results found'),
                            )
                          : ListView.separated(
                              itemCount: _filteredItems.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              separatorBuilder: (ctx, i) => Divider(
                                height: 1, 
                                color: isDark ? Colors.white10 : Colors.grey[200],
                              ),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = item == widget.value;
                                return ListTile(
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor 
                                          : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  trailing: isSelected 
                                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                      : null,
                                  onTap: () {
                                    widget.onChanged(item);
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSelectionSheet(context),
      child: AbsorbPointer( // Prevents keyboard from opening
        child: TextFormField(
          controller: _displayController, // Use controller
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: const Icon(Icons.school_outlined, color: Colors.grey),
            suffixIcon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50], // Match CustomTextField
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey[300]!, 
                width: 1.0
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
                width: 1.5,
              ),
            ),
             errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}

