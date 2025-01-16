import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/fee.dart';
import '../models/student.dart';
import '../database/database_helper.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Fee> _fees = [];
  Map<int, Student> _students = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Check if fees table exists
      final db = await _databaseHelper.database;
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'fees']);

      if (tables.isEmpty) {
        // Table doesn't exist, recreate database
        await _databaseHelper.deleteDatabase();
        // Get new database instance
        await _databaseHelper.database;
      }

      // Load fees and students from database
      _fees = await _databaseHelper.getAllFees();
      final students = await _databaseHelper.getAllStudents();
      _students = {
        for (var student in students)
          if (student.id != null) student.id!: student
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fee Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCards(),
                Expanded(child: _buildFeesList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFeeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards() {
    double totalFees = 0;
    double collectedFees = 0;
    double pendingFees = 0;

    for (final fee in _fees) {
      totalFees += fee.amount;
      if (fee.status == 'paid') {
        collectedFees += fee.amount;
      } else {
        pendingFees += fee.amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Fees',
              totalFees,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Collected',
              collectedFees,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              pendingFees,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                symbol: '₹',
                decimalDigits: 0,
              ).format(amount),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fees.length,
      itemBuilder: (context, index) {
        final fee = _fees[index];
        final student = _students[fee.studentId];
        final isOverdue =
            fee.dueDate.isBefore(DateTime.now()) && fee.status != 'paid';

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  student?.name ?? 'Unknown Student',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: fee.status == 'paid'
                        ? Colors.green
                        : isOverdue
                            ? Colors.red
                            : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fee.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  fee.description ?? '',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      NumberFormat.currency(
                        symbol: '₹',
                        decimalDigits: 0,
                      ).format(fee.amount),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(fee.dueDate)}',
                      style: GoogleFonts.poppins(
                        color: isOverdue ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(
                    fee.status == 'paid' ? 'Mark as Unpaid' : 'Mark as Paid',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    setState(() {
                      _fees[index] = Fee(
                        id: fee.id,
                        studentId: fee.studentId,
                        amount: fee.amount,
                        dueDate: fee.dueDate,
                        status: fee.status == 'paid' ? 'pending' : 'paid',
                        description: fee.description,
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text('Edit', style: GoogleFonts.poppins()),
                  onTap: () => _showAddFeeDialog(fee: fee),
                ),
                PopupMenuItem(
                  child: Text(
                    'Delete',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    // TODO: Implement delete
                    setState(() {
                      _fees.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Fees',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Show Paid', style: GoogleFonts.poppins()),
              value: true,
              onChanged: (value) {
                // TODO: Implement filtering
              },
            ),
            CheckboxListTile(
              title: Text('Show Pending', style: GoogleFonts.poppins()),
              value: true,
              onChanged: (value) {
                // TODO: Implement filtering
              },
            ),
            CheckboxListTile(
              title: Text('Show Overdue', style: GoogleFonts.poppins()),
              value: true,
              onChanged: (value) {
                // TODO: Implement filtering
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showAddFeeDialog({Fee? fee}) {
    final formKey = GlobalKey<FormState>();
    final isEditing = fee != null;
    int selectedStudentId = fee?.studentId ?? _students.keys.first;
    double amount = fee?.amount ?? 0;
    String description = fee?.description ?? '';
    DateTime dueDate =
        fee?.dueDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing ? 'Edit Fee' : 'Add New Fee',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Student',
                  ),
                  value: selectedStudentId,
                  items: _students.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value.name,
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedStudentId = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: amount.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    amount = double.tryParse(value ?? '') ?? 0;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter fee description',
                  ),
                  initialValue: description,
                  onSaved: (value) => description = value ?? '',
                ),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(dueDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => dueDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final newFee = Fee(
                  id: fee?.id,
                  studentId: selectedStudentId,
                  amount: amount,
                  dueDate: dueDate,
                  status: fee?.status ?? 'pending',
                  description: description,
                );
                setState(() {
                  if (isEditing) {
                    final index = _fees.indexWhere((f) => f.id == fee.id);
                    _fees[index] = newFee;
                  } else {
                    _fees.add(newFee);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              isEditing ? 'Update' : 'Save',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
