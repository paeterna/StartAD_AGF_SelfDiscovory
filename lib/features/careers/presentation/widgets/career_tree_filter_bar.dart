import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../data/models/career_tree.dart';
import '../../../../core/theme/app_colors.dart';

/// Filter bar for the career tree
class CareerTreeFilterBar extends StatelessWidget {
  const CareerTreeFilterBar({
    super.key,
    required this.filter,
    required this.sort,
    required this.onSearchChanged,
    required this.onMinScoreChanged,
    required this.onShowOnlyGreenToggled,
    required this.onIncludeUnknownToggled,
    required this.onSortChanged,
    required this.onReset,
  });

  final CareerTreeFilter filter;
  final CareerTreeSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<double> onMinScoreChanged;
  final VoidCallback onShowOnlyGreenToggled;
  final VoidCallback onIncludeUnknownToggled;
  final ValueChanged<CareerTreeSort> onSortChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            isDark
                ? AppColors.glassDark
                : AppColors.glassLight,
            isDark
                ? AppColors.glassDark.withValues(alpha: 0.8)
                : AppColors.glassLight.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? AppColors.glassDarkBorder
              : AppColors.glassBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search careers or categories...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: filter.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => onSearchChanged(''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),

                const SizedBox(height: 16),

                // Filters row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Min score slider
                    Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Min Match: ${(filter.minMatchScore * 100).round()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Slider(
                            value: filter.minMatchScore,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            label: '${(filter.minMatchScore * 100).round()}%',
                            onChanged: onMinScoreChanged,
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),

                    // Show only green filter
                    FilterChip(
                      label: const Text('High Match Only (80%+)'),
                      selected: filter.showOnlyGreen,
                      onSelected: (_) => onShowOnlyGreenToggled(),
                      avatar: filter.showOnlyGreen
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.7),
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: filter.showOnlyGreen
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),

                    // Include unknown filter
                    FilterChip(
                      label: const Text('Include Unknown'),
                      selected: filter.includeUnknown,
                      onSelected: (_) => onIncludeUnknownToggled(),
                      avatar: filter.includeUnknown
                          ? const Icon(Icons.check_circle, size: 18)
                          : null,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.7),
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: filter.includeUnknown
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),

                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButton<CareerTreeSort>(
                        value: sort,
                        underline: const SizedBox(),
                        items: CareerTreeSort.values.map((sortOption) {
                          return DropdownMenuItem(
                            value: sortOption,
                            child: Text(sortOption.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) onSortChanged(value);
                        },
                        dropdownColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                      ),
                    ),

                    // Reset button
                    if (!filter.isDefault)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: onReset,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                // Active filters summary
                if (!filter.isDefault) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (filter.searchQuery.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentViolet.withValues(alpha: 0.2),
                                AppColors.accentViolet.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Chip(
                            label: Text('Search: "${filter.searchQuery}"'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => onSearchChanged(''),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: AppColors.accentViolet.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      if (filter.minMatchScore > 0.0)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentViolet.withValues(alpha: 0.2),
                                AppColors.accentViolet.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Chip(
                            label: Text('Min: ${(filter.minMatchScore * 100).round()}%'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => onMinScoreChanged(0.0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: AppColors.accentViolet.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
