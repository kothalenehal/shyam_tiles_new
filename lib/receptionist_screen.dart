import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shyam_tiles/common/app_constant.dart';
import 'package:shyam_tiles/common/reponse.dart';
import 'package:shyam_tiles/login.dart';
import 'package:shyam_tiles/model/user.dart';
import 'package:shyam_tiles/model/visitor.dart';
import 'package:shyam_tiles/shared_preference.dart';

class ReceptionistScreen extends StatefulWidget {
  const ReceptionistScreen({super.key});

  @override
  State<ReceptionistScreen> createState() => _ReceptionistScreenState();
}

class _ReceptionistScreenState extends State<ReceptionistScreen> {
  int _currentIndex = 0;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isConverted = false;
  SalesmanItem? _selectedSalesman;
  List<SalesmanItem> _salesmenList = [];
  bool _isLoadingSalesmen = false;

  // Visitor List
  List<VisitorItem> _visitors = [];
  bool _isLoadingVisitors = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSalesmen();
    _loadVisitors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesmen() async {
    setState(() => _isLoadingSalesmen = true);
    final salesmen = await VisitorService.fetchSalesmen(
      location: AppUser.sharedInstance.location,
    );
    if (mounted) {
      setState(() {
        _salesmenList = salesmen;
        _isLoadingSalesmen = false;
      });
    }
  }

  Future<void> _loadVisitors() async {
    setState(() => _isLoadingVisitors = true);
    final visitors = await VisitorService.fetchVisitors(AppUser.sharedInstance.id);
    if (mounted) {
      setState(() {
        _visitors = visitors;
        _isLoadingVisitors = false;
      });
    }
  }

  void _showSalesmanPicker({
    SalesmanItem? currentSelected,
    required ValueChanged<SalesmanItem?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String sheetSearch = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _salesmenList.where((s) {
              if (sheetSearch.isEmpty) return true;
              final q = sheetSearch.toLowerCase();
              return s.name.toLowerCase().contains(q) ||
                  s.location.toLowerCase().contains(q) ||
                  s.contact.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assign Salesman',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff333333),
                              ),
                            ),
                            Text(
                              'Select a salesman for this visitor',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (val) {
                        setSheetState(() => sheetSearch = val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or location...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  // List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        // None / Not Assigned Option
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(Icons.person_off_outlined,
                                color: Colors.grey, size: 20),
                          ),
                          title: Text(
                            'None / Not Assigned',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: currentSelected == null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: currentSelected == null
                                  ? Colors.redAccent
                                  : Colors.black87,
                            ),
                          ),
                          trailing: currentSelected == null
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            onSelected(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        const Divider(height: 1),
                        ...filtered.map((salesman) {
                          final isSelected =
                              currentSelected?.id == salesman.id;
                          final initials = salesman.name.isNotEmpty
                              ? salesman.name
                                  .trim()
                                  .split(' ')
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                              : 'S';

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            selected: isSelected,
                            selectedTileColor: Colors.green.withValues(alpha: 0.08),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.green.shade100
                                  : const Color(0xff333333).withValues(alpha: 0.1),
                              child: Text(
                                initials,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.green.shade800
                                      : const Color(0xff333333),
                                ),
                              ),
                            ),
                            title: Text(
                              salesman.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.green.shade900
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: salesman.location.isNotEmpty
                                ? Text(
                                    salesman.location,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : null,
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.chevron_right,
                                    color: Colors.grey, size: 18),
                            onTap: () {
                              onSelected(salesman);
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                        if (filtered.isEmpty) ...[
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              'No salesmen found',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openEditVisitorSheet(VisitorItem visitor) {
    final editFormKey = GlobalKey<FormState>();
    final editNameController = TextEditingController(text: visitor.visitorName);
    final editContactController = TextEditingController(text: visitor.contact);
    final editReasonController = TextEditingController(text: visitor.reason ?? '');
    bool editIsConverted = visitor.isConverted;
    SalesmanItem? editSalesman;

    try {
      if (visitor.salesmanId != null) {
        editSalesman = _salesmenList.firstWhere(
          (s) => s.id == visitor.salesmanId,
          orElse: () => SalesmanItem(
            id: visitor.salesmanId!,
            name: visitor.salesmanName ?? '',
            contact: visitor.salesmanContact ?? '',
            location: '',
          ),
        );
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setEditState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Visitor (Today)',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff333333),
                              ),
                            ),
                            Text(
                              'Update conversion status, reason, or salesman',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Form(
                        key: editFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Visitor Name
                            Text(
                              'Visitor Name *',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: editNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Enter full name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter visitor name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 2. Contact Number
                            Text(
                              'Contact Number *',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: editContactController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                hintText: '10-digit mobile number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter contact number';
                                }
                                if (val.trim().length != 10) {
                                  return 'Please enter a valid 10-digit contact number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // 3. Converted Switch Button
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: editIsConverted
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: editIsConverted
                                      ? Colors.green.shade400
                                      : Colors.orange.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        editIsConverted
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        color: editIsConverted ? Colors.green : Colors.orange.shade800,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Converted to Customer?',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            editIsConverted
                                                ? 'Yes, visitor converted'
                                                : 'No, visitor did not convert',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: editIsConverted
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: editIsConverted,
                                    activeThumbColor: Colors.green,
                                    onChanged: (val) {
                                      setEditState(() {
                                        editIsConverted = val;
                                        if (val) {
                                          editReasonController.clear();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. Reason for Not Converted
                            Text(
                              'Reason for Not Converted ${editIsConverted ? '(Disabled)' : '*'}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: editIsConverted ? Colors.grey : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: editReasonController,
                              enabled: !editIsConverted,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: editIsConverted
                                    ? 'Not required (visitor converted to customer)'
                                    : 'Explain why visitor did not convert...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: editIsConverted ? Colors.grey.shade200 : Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 5. Assigned Salesman Selector
                            Text(
                              'Assigned Salesman',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                _showSalesmanPicker(
                                  currentSelected: editSalesman,
                                  onSelected: (val) {
                                    setEditState(() => editSalesman = val);
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.support_agent,
                                        color: Color(0xff333333), size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: editSalesman != null
                                          ? Text(
                                              '${editSalesman!.name}${editSalesman!.location.isNotEmpty ? ' (${editSalesman!.location})' : ''}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              'Select a salesman (optional)',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                    ),
                                    if (editSalesman != null)
                                      GestureDetector(
                                        onTap: () {
                                          setEditState(() => editSalesman = null);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade300,
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 14, color: Colors.black87),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff333333),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!editFormKey.currentState!.validate()) return;
                                  if (!editIsConverted && editReasonController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a reason why the visitor was not converted.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  UtilFunctions.loader(ColorConstant.APP_MAIN_COLOR);
                                  final response = await VisitorService.updateVisitor(
                                    id: visitor.id,
                                    receptionistId: AppUser.sharedInstance.id,
                                    visitorName: editNameController.text.trim(),
                                    contact: editContactController.text.trim(),
                                    isConverted: editIsConverted,
                                    reason: editIsConverted ? null : editReasonController.text.trim(),
                                    salesmanId: editSalesman?.id,
                                  );
                                  UtilFunctions.hideLoader();

                                  if (!mounted) return;

                                  if (response.status) {
                                    Navigator.pop(sheetCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Visitor updated successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _loadVisitors();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response.errorMessage.isNotEmpty
                                              ? response.errorMessage
                                              : 'Failed to update visitor.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: Text(
                                  'Save Changes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitVisitor() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isConverted && _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason why the visitor was not converted.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    UtilFunctions.loader(ColorConstant.APP_MAIN_COLOR);

    final ResponseSmartAuditor response = await VisitorService.submitVisitor(
      receptionistId: AppUser.sharedInstance.id,
      visitorName: _nameController.text.trim(),
      contact: _contactController.text.trim(),
      isConverted: _isConverted,
      reason: _isConverted ? null : _reasonController.text.trim(),
      salesmanId: _selectedSalesman?.id,
    );

    UtilFunctions.hideLoader();

    if (response.status) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _nameController.clear();
        _contactController.clear();
        _reasonController.clear();
        setState(() {
          _isConverted = false;
          _selectedSalesman = null;
        });

        // Refresh list and optionally switch to list tab
        _loadVisitors();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage.isNotEmpty
                  ? response.errorMessage
                  : 'Failed to save visitor data.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await SharedPreference.clearPreferences();
              AppUser.sharedInstance.id = 0;
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff333333),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receptionist Portal',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${AppUser.sharedInstance.name} • ${AppUser.sharedInstance.location.isNotEmpty ? AppUser.sharedInstance.location : 'Branch'}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildFormTab() : _buildListTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _loadVisitors();
          }
        },
        selectedItemColor: const Color(0xff333333),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'New Visitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Visitors List',
          ),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge, color: Color(0xff333333)),
                    const SizedBox(width: 8),
                    Text(
                      'Visitor Entry Form',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff333333),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // 1. Visitor Name
                Text(
                  'Visitor Name *',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Enter full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter visitor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Contact Number
                Text(
                  'Contact Number *',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: '10-digit mobile number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter contact number';
                    }
                    if (val.trim().length != 10) {
                      return 'Please enter a valid 10-digit contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Converted Switch Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isConverted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isConverted
                          ? Colors.green.shade400
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isConverted
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: _isConverted ? Colors.green : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Converted to Customer?',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isConverted
                                    ? 'Yes, visitor converted'
                                    : 'No, visitor did not convert',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _isConverted
                                      ? Colors.green.shade800
                                      : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isConverted,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _isConverted = val;
                            if (val) {
                              _reasonController.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Reason for Not Converted
                Text(
                  'Reason for Not Converted ${_isConverted ? '(Disabled)' : '*'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isConverted ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  enabled: !_isConverted,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _isConverted
                        ? 'Not required (visitor converted to customer)'
                        : 'Explain why visitor did not convert (e.g. price, size unavailable)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: _isConverted ? Colors.grey.shade200 : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Assigned Salesman Selector
                Text(
                  'Assigned Salesman',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                _isLoadingSalesmen
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          _showSalesmanPicker(
                            currentSelected: _selectedSalesman,
                            onSelected: (val) {
                              setState(() => _selectedSalesman = val);
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.support_agent,
                                  color: Color(0xff333333), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedSalesman != null
                                    ? Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _selectedSalesman!.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_selectedSalesman!
                                              .location.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blueGrey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                _selectedSalesman!.location,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .blueGrey.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      )
                                    : Text(
                                        'Select a salesman (optional)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                              ),
                              if (_selectedSalesman != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedSalesman = null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.black87),
                                  ),
                                )
                              else
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 28),

                // 6. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitVisitor,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Save Visitor',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTab() {
    final filteredVisitors = _visitors.where((v) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return v.visitorName.toLowerCase().contains(q) ||
          v.contact.contains(q) ||
          (v.salesmanName ?? '').toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadVisitors,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search by visitor name or contact...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          Expanded(
            child: _isLoadingVisitors
                ? const Center(child: CircularProgressIndicator())
                : filteredVisitors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _visitors.isEmpty
                                  ? 'No visitors logged yet'
                                  : 'No matching visitors found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredVisitors.length,
                        itemBuilder: (ctx, idx) {
                          final v = filteredVisitors[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1.5,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          v.visitorName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: v.isConverted
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              v.isConverted
                                                  ? Icons.check
                                                  : Icons.close,
                                              size: 14,
                                              color: v.isConverted
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade900,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              v.isConverted
                                                  ? 'Converted'
                                                  : 'Not Converted',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: v.isConverted
                                                    ? Colors.green.shade800
                                                    : Colors.orange.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Contact
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 15, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        v.contact,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Reason (if not converted)
                                  if (!v.isConverted &&
                                      v.reason != null &&
                                      v.reason!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.info_outline,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Reason: ${v.reason!}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Assigned Salesman
                                  if (v.salesmanName != null &&
                                      v.salesmanName!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.support_agent,
                                            size: 15, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Salesman: ${v.salesmanName!}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        v.createdAt,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (v.isCreatedToday)
                                        InkWell(
                                          onTap: () => _openEditVisitorSheet(v),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff333333)
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xff333333)
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.edit_outlined,
                                                    size: 13,
                                                    color: Color(0xff333333)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Edit',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xff333333),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
