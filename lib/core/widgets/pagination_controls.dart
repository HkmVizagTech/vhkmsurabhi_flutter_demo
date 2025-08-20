// lib/core/widgets/pagination_controls.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';

class PaginationControls extends StatelessWidget {
  final PaginationMeta meta;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int)? onPageSelected;
  final Function(int)? onPageSizeChanged;
  final bool isLoading;
  final int currentPageSize;
  final List<int> pageSizeOptions;

  const PaginationControls({
    super.key,
    required this.meta,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.onPageSizeChanged,
    this.isLoading = false,
    this.currentPageSize = 10,
    this.pageSizeOptions = const [5, 10, 20, 40],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page info and page size selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page info
              Expanded(
                child: Text(
                  'Page ${meta.page} of ${meta.pages} (${meta.total} total items)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),

              // Page size selector
              if (onPageSizeChanged != null) ...[
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentPageSize,
                          isDense: true,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  if (value != null) {
                                    onPageSizeChanged!(value);
                                  }
                                },
                          items: pageSizeOptions.map((size) {
                            return DropdownMenuItem<int>(
                              value: size,
                              child: Text(size.toString(), style: theme.textTheme.bodyMedium),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              IconButton(
                onPressed: meta.hasPrev && !isLoading ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),

              const SizedBox(width: 8),

              // Page numbers (show current and nearby pages)
              ..._buildPageNumbers(context),

              const SizedBox(width: 8),

              // Next button
              IconButton(
                onPressed: meta.hasNext && !isLoading ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),
            ],
          ),

          if (isLoading) ...[const SizedBox(height: 8), const SizedBox(height: 2, child: LinearProgressIndicator())],
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> pageWidgets = [];

    // Handle edge case where pages is 0
    if (meta.pages <= 0) return pageWidgets;

    // Calculate which pages to show
    int startPage = (meta.page - 2).clamp(1, meta.pages);
    int endPage = (meta.page + 2).clamp(1, meta.pages);

    // Show first page if not in range
    if (startPage > 1) {
      pageWidgets.add(_buildPageButton(context, 1));
      if (startPage > 2) {
        pageWidgets.add(Text('...', style: theme.textTheme.bodyMedium));
      }
    }

    // Show page range
    for (int i = startPage; i <= endPage; i++) {
      pageWidgets.add(_buildPageButton(context, i));
    }

    // Show last page if not in range
    if (endPage < meta.pages) {
      if (endPage < meta.pages - 1) {
        pageWidgets.add(Text('...', style: theme.textTheme.bodyMedium));
      }
      pageWidgets.add(_buildPageButton(context, meta.pages));
    }

    return pageWidgets;
  }

  Widget _buildPageButton(BuildContext context, int pageNumber) {
    final theme = Theme.of(context);
    final isCurrentPage = pageNumber == meta.page;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isCurrentPage ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: isCurrentPage || isLoading ? null : () => onPageSelected?.call(pageNumber),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              pageNumber.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCurrentPage ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
