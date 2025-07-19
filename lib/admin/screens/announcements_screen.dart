// lib/admin/screens/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AnnouncementsScreen extends StatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isUrgent = false;
  List<String> _selectedUserGroups = [];

  final List<String> _userGroups = [
    'All Users',
    'New Users',
    'Verified Users',
    'Premium Users',
    'High Volume Traders',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Color(0xFF1B4332),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateAnnouncementDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAnnouncementStats(),
          Expanded(
            child: _buildAnnouncementsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAnnouncementDialog,
        backgroundColor: Color(0xFF1B4332),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnnouncementStats() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active', '3', Colors.green),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildStatCard('Scheduled', '2', Colors.orange),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildStatCard('Expired', '8', Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _mockAnnouncements.length,
      itemBuilder: (context, index) {
        final announcement = _mockAnnouncements[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: _buildStatusIcon(announcement['status']),
            title: Text(
              announcement['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement['targetGroup']),
                SizedBox(height: 4),
                Text(
                  'Created: ${announcement['createdDate']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (value) => _handleAnnouncementAction(value, announcement),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(announcement['content']),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        if (announcement['isUrgent'])
                          Chip(
                            label: Text('URGENT'),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        Spacer(),
                        Text(
                          'Views: ${announcement['views']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'Active':
        return CircleAvatar(
          backgroundColor: Colors.green,
          radius: 12,
          child: Icon(Icons.check, size: 16, color: Colors.white),
        );
      case 'Scheduled':
        return CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 12,
          child: Icon(Icons.schedule, size: 16, color: Colors.white),
        );
      case 'Expired':
        return CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 12,
          child: Icon(Icons.close, size: 16, color: Colors.white),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 12,
        );
    }
  }

  void _showCreateAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Announcement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content *',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Target Audience',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _userGroups.map((group) {
                          return FilterChip(
                            label: Text(group),
                            selected: _selectedUserGroups.contains(group),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedUserGroups.add(group);
                                } else {
                                  _selectedUserGroups.remove(group);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectStartDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _startDate?.toString().split(' ')[0] ?? 'Select date',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectEndDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Date (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _endDate?.toString().split(' ')[0] ?? 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text('Mark as Urgent'),
                        subtitle: Text('Urgent announcements appear at the top'),
                        value: _isUrgent,
                        onChanged: (value) {
                          setState(() {
                            _isUrgent = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _createAnnouncement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B4332),
                    ),
                    child: Text('Create Announcement'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate?.add(Duration(days: 7)) ?? DateTime.now().add(Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _createAnnouncement() {
    if (_titleController.text.trim().isEmpty || 
        _contentController.text.trim().isEmpty ||
        _startDate == null ||
        _selectedUserGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create announcement using AdminProvider
    context.read<AdminProvider>().createAnnouncement(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate,
      isUrgent: _isUrgent,
      targetUserIds: _selectedUserGroups,
    );

    // Clear form and close dialog
    _titleController.clear();
    _contentController.clear();
    _startDate = null;
    _endDate = null;
    _isUrgent = false;
    _selectedUserGroups.clear();

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Announcement created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleAnnouncementAction(String action, Map<String, dynamic> announcement) {
    switch (action) {
      case 'edit':
        _editAnnouncement(announcement);
        break;
      case 'duplicate':
        _duplicateAnnouncement(announcement);
        break;
      case 'delete':
        _deleteAnnouncement(announcement);
        break;
    }
  }

  void _editAnnouncement(Map<String, dynamic> announcement) {
    // Pre-fill form with existing data
    _titleController.text = announcement['title'];
    _contentController.text = announcement['content'];
    _isUrgent = announcement['isUrgent'];
    _selectedUserGroups = [announcement['targetGroup']];
    
    _showCreateAnnouncementDialog();
  }

  void _duplicateAnnouncement(Map<String, dynamic> announcement) {
    _titleController.text = 'Copy of ${announcement['title']}';
    _contentController.text = announcement['content'];
    _isUrgent = announcement['isUrgent'];
    _selectedUserGroups = [announcement['targetGroup']];
    
    _showCreateAnnouncementDialog();
  }

  void _deleteAnnouncement(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Announcement deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// Mock data for announcements
final List<Map<String, dynamic>> _mockAnnouncements = [
  {
    'title': 'System Maintenance Notice',
    'content': 'Our system will undergo scheduled maintenance on Sunday, July 21st from 2:00 AM to 4:00 AM. During this time, some services may be temporarily unavailable.',
    'status': 'Active',
    'targetGroup': 'All Users',
    'createdDate': '2025-07-18',
    'isUrgent': true,
    'views': 1234,
  },
  {
    'title': 'New Gold Investment Features',
    'content': 'We\'re excited to announce new features including fractional gold purchases starting from RM 10 and improved portfolio analytics.',
    'status': 'Active',
    'targetGroup': 'Verified Users',
    'createdDate': '2025-07-15',
    'isUrgent': false,
    'views': 856,
  },
  {
    'title': 'Welcome New Users!',
    'content': 'Welcome to RMS Gold Account-i! Complete your KYC verification to start trading gold with zero commission for your first month.',
    'status': 'Active',
    'targetGroup': 'New Users',
    'createdDate': '2025-07-10',
    'isUrgent': false,
    'views': 432,
  },
  {
    'title': 'Holiday Trading Hours',
    'content': 'Please note that trading hours will be adjusted during the upcoming public holidays. Check our schedule for details.',
    'status': 'Scheduled',
    'targetGroup': 'All Users',
    'createdDate': '2025-07-08',
    'isUrgent': false,
    'views': 0,
  },
  {
    'title': 'Security Enhancement',
    'content': 'We\'ve implemented additional security measures to protect your account. Please ensure your app is updated to the latest version.',
    'status': 'Expired',
    'targetGroup': 'All Users',
    'createdDate': '2025-07-01',
    'isUrgent': false,
    'views': 2156,
  },
];
