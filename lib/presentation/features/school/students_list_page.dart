import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/school/school_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../data/models/school.dart';
import '../../widgets/gradient_background.dart';

/// Full students list page with search and pagination
class StudentsListPage extends ConsumerStatefulWidget {
  final String schoolId;

  const StudentsListPage({
    required this.schoolId,
    super.key,
  });

  @override
  ConsumerState<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends ConsumerState<StudentsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 0; // Reset to first page on search
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final params = SchoolStudentsParams(
      schoolId: widget.schoolId,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );
    final studentsAsync = ref.watch(schoolStudentsProvider(params));

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('All Students'),
        ),
        body: AppScaffoldBody(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    ResponsiveCard(
                      enableHover: false,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    SizedBox(height: ResponsiveSpacing.lg(context)),

                    // Students list
                    studentsAsync.when(
                      data: (students) {
                        if (students.isEmpty) {
                          return ResponsiveCard(
                            enableHover: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(48),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'No students found'
                                          : 'No students match your search',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    if (_searchQuery.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try a different search term',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Students cards/table
                            if (context.isMobile)
                              // Mobile: Card list
                              Column(
                                children: students
                                    .map((student) => _buildStudentCard(
                                          context,
                                          theme,
                                          student,
                                        ))
                                    .toList(),
                              )
                            else
                              // Desktop: Table
                              ResponsiveCard(
                                enableHover: false,
                                child: _buildStudentsTable(
                                  context,
                                  theme,
                                  students,
                                ),
                              ),

                            SizedBox(height: ResponsiveSpacing.lg(context)),

                            // Pagination controls
                            ResponsiveCard(
                              enableHover: false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Page ${_currentPage + 1}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 0
                                            ? _previousPage
                                            : null,
                                        tooltip: 'Previous page',
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: students.length == _pageSize
                                            ? _nextPage
                                            : null,
                                        tooltip: 'Next page',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => ResponsiveCard(
                        enableHover: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading students',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    ThemeData theme,
    SchoolStudent student,
  ) {
    final lastActive = student.lastActivity != null
        ? DateFormat.yMMMd().format(student.lastActivity!)
        : 'Never';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ResponsiveCard(
        enableHover: true,
        onTap: () {
          context.push('/school/student/${student.userId}');
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                student.displayName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.displayName ?? 'Unknown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email ?? 'No email',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last active: $lastActive',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTable(
    BuildContext context,
    ThemeData theme,
    List<SchoolStudent> students,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Profile')),
          DataColumn(label: Text('Strength')),
          DataColumn(label: Text('Last Active')),
          DataColumn(label: Text('Actions')),
        ],
        rows: students.map((student) {
          final lastActive = student.lastActivity != null
              ? DateFormat.yMMMd().format(student.lastActivity!)
              : 'Never';

          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        student.displayName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(student.displayName ?? 'Unknown'),
                  ],
                ),
              ),
              DataCell(Text(student.email ?? 'N/A')),
              DataCell(
                Text('${student.profileCompletion.toStringAsFixed(0)}%'),
              ),
              DataCell(
                Text('${student.discoveryPercent}%'),
              ),
              DataCell(Text(lastActive)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View details',
                  onPressed: () {
                    context.push('/school/student/${student.userId}');
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
