import 'package:flutter/material.dart';

// Widget للقائمة القابلة للبحث
class SearchableListModal extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selectedItem;
  final Function(String?) onItemSelected;
  final String allItemsText;
  final String searchHint;

  const SearchableListModal({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.allItemsText,
    required this.searchHint,
  });

  @override
  State<SearchableListModal> createState() => _SearchableListModalState();
}

class _SearchableListModalState extends State<SearchableListModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // حقل البحث
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _searchController.clear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // عداد النتائج
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'النتائج: ${_filteredItems.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          
          // القائمة
          Expanded(
            child: ListView(
              children: [
                // خيار "جميع العناصر"
                Card(
                  elevation: widget.selectedItem == null ? 2 : 0,
                  color: widget.selectedItem == null 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    title: Text(
                      widget.allItemsText,
                      style: TextStyle(
                        fontWeight: widget.selectedItem == null 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                        color: widget.selectedItem == null 
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                    leading: widget.selectedItem == null
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    onTap: () {
                      widget.onItemSelected(null);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // العناصر المفلترة
                if (_filteredItems.isEmpty && _searchController.text.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'جرب البحث بكلمات أخرى',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredItems.map((item) => Card(
                        elevation: widget.selectedItem == item ? 2 : 0,
                        color: widget.selectedItem == item 
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          title: Text(
                            item,
                            style: TextStyle(
                              fontWeight: widget.selectedItem == item 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              color: widget.selectedItem == item 
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                          leading: widget.selectedItem == item
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                )
                              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                          onTap: () {
                            widget.onItemSelected(item);
                          },
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
