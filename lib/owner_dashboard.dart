import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model/owner_dashboard_data.dart';
import 'profile.dart';
import 'model/user.dart';
import 'common/api_constant.dart';
import 'common/reponse.dart';
import 'common/request.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  DashboardFilter _currentFilter = DashboardFilter.thisMonth();
  late OwnerDashboardData _data;
  int _selectedIndex = 0;
  String _selectedLocation = 'All locations';

  @override
  void initState() {
    super.initState();
    _data = OwnerDashboardData.demo(filter: _currentFilter);
  }

  void _applyFilter(DashboardFilter filter) {
    setState(() {
      _currentFilter = filter;
      _data = OwnerDashboardData.demo(filter: filter);
    });
  }

  OwnerDashboardData get _visibleData {
    return _data.forLocation(_selectedLocation);
  }

  void _selectLocation(String location) {
    setState(() => _selectedLocation = location);
  }

  void _openDataDetails(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _OwnerDataDetailsScreen(type: type)),
    );
  }

  Future<void> _pickSingleDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentFilter.startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Past Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1769aa),
              onPrimary: Colors.white,
              onSurface: Color(0xff16233b),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _applyFilter(DashboardFilter.singleDate(picked));
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange = _currentFilter.startDate != null &&
            _currentFilter.endDate != null
        ? DateTimeRange(
            start: _currentFilter.startDate!, end: _currentFilter.endDate!)
        : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Date Range (Past Weeks / Months)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1769aa),
              onPrimary: Colors.white,
              onSurface: Color(0xff16233b),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _applyFilter(DashboardFilter.range(picked.start, picked.end));
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onSelectPreset: (filter) {
          Navigator.pop(ctx);
          _applyFilter(filter);
        },
        onPickDate: () {
          Navigator.pop(ctx);
          _pickSingleDate();
        },
        onPickDateRange: () {
          Navigator.pop(ctx);
          _pickDateRange();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DashboardTab(
        data: _visibleData,
        currentFilter: _currentFilter,
        onFilterTap: _showFilterBottomSheet,
        onSelectFilter: _applyFilter,
        selectedLocation: _selectedLocation,
        onLocationChanged: _selectLocation,
        onDetails: _openDataDetails,
      ),
      _BusinessTab(
        data: _visibleData,
        currentFilter: _currentFilter,
        onFilterTap: _showFilterBottomSheet,
        onSelectFilter: _applyFilter,
        selectedLocation: _selectedLocation,
        onLocationChanged: _selectLocation,
        onDetails: _openDataDetails,
      ),
      const Profilescreen(),
    ];

    final isProfile = pages[_selectedIndex] is Profilescreen;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: isProfile
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text(
                _titleForIndex(_selectedIndex),
                style: GoogleFonts.poppins(
                  color: const Color(0xff16233b),
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Filter date / period',
                  icon: const Icon(Icons.date_range_outlined,
                      color: Color(0xff1769aa)),
                  onPressed: _showFilterBottomSheet,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 2),
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xffe8f2ff),
                      child: Text(
                        _initials(),
                        style: const TextStyle(
                          color: Color(0xff1d5fa7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: isProfile
          ? pages[_selectedIndex]
          : SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff1769aa),
        unselectedItemColor: const Color(0xff7c8798),
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined), label: 'Business'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    const titles = ['Owner dashboard', 'Business', 'Profile'];
    return titles[index];
  }

  String _initials() {
    final name = AppUser.sharedInstance.name.trim();
    if (name.isEmpty) return 'OW';
    final parts = name.split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

class _FilterBar extends StatelessWidget {
  final DashboardFilter currentFilter;
  final Function(DashboardFilter) onSelectFilter;
  final VoidCallback onMoreTap;

  const _FilterBar({
    required this.currentFilter,
    required this.onSelectFilter,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = currentFilter.type == DashboardPeriodType.customDate ||
        currentFilter.type == DashboardPeriodType.customRange;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            label: 'Today',
            selected: currentFilter.type == DashboardPeriodType.today,
            onTap: () => onSelectFilter(DashboardFilter.today()),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'This week',
            selected: currentFilter.type == DashboardPeriodType.thisWeek,
            onTap: () => onSelectFilter(DashboardFilter.thisWeek()),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'This month',
            selected: currentFilter.type == DashboardPeriodType.thisMonth,
            onTap: () => onSelectFilter(DashboardFilter.thisMonth()),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: isCustom ? currentFilter.label : 'Past / Custom ▾',
            selected: isCustom,
            icon: Icons.calendar_month_outlined,
            onTap: onMoreTap,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff1769aa) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xff1769aa) : const Color(0xffdde3ec),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x331769aa),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected ? Colors.white : const Color(0xff576579)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xff576579),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationFilter extends StatelessWidget {
  final String selectedLocation;
  final ValueChanged<String> onChanged;

  const _LocationFilter({
    required this.selectedLocation,
    required this.onChanged,
  });

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LocationBottomSheet(
        selectedLocation: selectedLocation,
        onSelected: (loc) {
          Navigator.pop(ctx);
          onChanged(loc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAll = selectedLocation == 'All locations';
    final displayName = isAll ? 'All Locations' : selectedLocation;

    return InkWell(
      onTap: () => _showBottomSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAll ? const Color(0xffdde3ec) : const Color(0xff9ec5e8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0a20304a),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isAll ? const Color(0xffeef5fb) : const Color(0xffe1effa),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 20,
                color: Color(0xff1769aa),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff8c99ab),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff16233b),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xfff0f6ff),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffcfe2f5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1769aa),
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xff1769aa),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBottomSheet extends StatelessWidget {
  final String selectedLocation;
  final ValueChanged<String> onSelected;

  const _LocationBottomSheet({
    required this.selectedLocation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const locations = [
      _LocationItem(
        id: 'All locations',
        title: 'All Locations',
      ),
      _LocationItem(
        id: 'Kolhapur',
        title: 'Kolhapur',
      ),
      _LocationItem(
        id: 'Belgav',
        title: 'Belgav',
      ),
      _LocationItem(
        id: 'Mudaltittha',
        title: 'Mudaltittha',
      ),
      _LocationItem(
        id: 'Examba',
        title: 'Examba',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Location',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16233b),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...locations.map((item) {
            final isSelected =
                item.id.toLowerCase() == selectedLocation.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(item.id),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xffeff6ff)
                        : const Color(0xfffafbfc),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff1769aa)
                          : const Color(0xffe5ebf3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff1769aa)
                              : const Color(0xffedf3f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff576579),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xff1769aa)
                                : const Color(0xff16233b),
                          ),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: isSelected
                            ? const Color(0xff1769aa)
                            : const Color(0xffcbd5e1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _LocationItem {
  final String id;
  final String title;

  const _LocationItem({
    required this.id,
    required this.title,
  });
}

class _FilterBottomSheet extends StatelessWidget {
  final DashboardFilter currentFilter;
  final Function(DashboardFilter) onSelectPreset;
  final VoidCallback onPickDate;
  final VoidCallback onPickDateRange;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onSelectPreset,
    required this.onPickDate,
    required this.onPickDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Time Period',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16233b),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('DAY OPTIONS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8c99ab),
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _OptionTile(
                  label: 'Today',
                  isSelected: currentFilter.type == DashboardPeriodType.today,
                  onTap: () => onSelectPreset(DashboardFilter.today()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionTile(
                  label: 'Yesterday',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.yesterday,
                  onTap: () => onSelectPreset(DashboardFilter.yesterday()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionTile(
                  label: 'Pick Date 📅',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.customDate,
                  onTap: onPickDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('WEEK OPTIONS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8c99ab),
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _OptionTile(
                  label: 'This week',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.thisWeek,
                  onTap: () => onSelectPreset(DashboardFilter.thisWeek()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionTile(
                  label: 'Last week',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.lastWeek,
                  onTap: () => onSelectPreset(DashboardFilter.lastWeek()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('MONTH OPTIONS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8c99ab),
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _OptionTile(
                  label: 'This month',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.thisMonth,
                  onTap: () => onSelectPreset(DashboardFilter.thisMonth()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionTile(
                  label: 'Last month',
                  isSelected:
                      currentFilter.type == DashboardPeriodType.lastMonth,
                  onTap: () => onSelectPreset(DashboardFilter.lastMonth()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('CUSTOM HISTORICAL RANGE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8c99ab),
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          InkWell(
            onTap: onPickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentFilter.type == DashboardPeriodType.customRange
                      ? const Color(0xff1769aa)
                      : const Color(0xffdde3ec),
                ),
                color: currentFilter.type == DashboardPeriodType.customRange
                    ? const Color(0xffeef5fb)
                    : const Color(0xfffafbfc),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range,
                      color: Color(0xff1769aa), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentFilter.type == DashboardPeriodType.customRange
                              ? 'Active Range: ${currentFilter.label}'
                              : 'Select Custom Date Range',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                            'Check past weeks, past months, or custom date spans',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xff7c8798))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xff7c8798)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff1769aa) : const Color(0xfff0f4f9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xff1769aa) : const Color(0xffdde3ec),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xff34445d),
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final OwnerDashboardData data;
  final DashboardFilter currentFilter;
  final VoidCallback onFilterTap;
  final Function(DashboardFilter) onSelectFilter;
  final String selectedLocation;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onDetails;

  const _DashboardTab({
    required this.data,
    required this.currentFilter,
    required this.onFilterTap,
    required this.onSelectFilter,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        const _GreetingCard(),
        _FilterBar(
          currentFilter: currentFilter,
          onSelectFilter: onSelectFilter,
          onMoreTap: onFilterTap,
        ),
        _LocationFilter(
          selectedLocation: selectedLocation,
          onChanged: onLocationChanged,
        ),
        const _SectionTitle('Operations', 'Static preview'),
        Row(
          children: [
            Expanded(
                child: _MiniMetric(
                    icon: Icons.receipt_long_outlined,
                    label: 'Open orders',
                    value: '${data.openOrders}',
                    onTap: () => onDetails('open_orders'))),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniMetric(
                    icon: Icons.people_outline,
                    label: 'Customers',
                    value: '${data.activeCustomers}',
                    onTap: () => onDetails('customers'))),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniMetric(
                    icon: Icons.inventory_2_outlined,
                    label: 'Low stock',
                    value: '${data.lowStock}',
                    onTap: () => onDetails('low_stock'))),
          ],
        ),
        const _SectionTitle('Sales mix', 'By category'),
        _SalesMixCard(
            items: data.categorySales, onTap: () => onDetails('sales_mix')),
        _SectionTitle('Inventory health', '${data.totalSkus} total SKUs'),
        _InventoryCard(data: data, onTap: () => onDetails('inventory')),
        const _InventoryHealthChart(),
        const _SectionTitle('Management attention', 'Requires review'),
        _AlertCard(alerts: data.managementAlerts),
      ],
    );
  }
}

class _BusinessTab extends StatelessWidget {
  final OwnerDashboardData data;
  final DashboardFilter currentFilter;
  final VoidCallback onFilterTap;
  final Function(DashboardFilter) onSelectFilter;
  final String selectedLocation;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onDetails;

  const _BusinessTab({
    required this.data,
    required this.currentFilter,
    required this.onFilterTap,
    required this.onSelectFilter,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        _FilterBar(
          currentFilter: currentFilter,
          onSelectFilter: onSelectFilter,
          onMoreTap: onFilterTap,
        ),
        _LocationFilter(
          selectedLocation: selectedLocation,
          onChanged: onLocationChanged,
        ),
        const _SectionTitle('Business metrics'),
        _KpiGrid(kpis: data.kpis),
        const _SectionTitle('Sales by branch', 'Branch comparison'),
        _VerticalBarChart(
            items: data.branchSales, color: const Color(0xff2f73d9)),
        const _SectionTitle(
            'Sales by category', 'Tiles, granite and sanitaryware mix'),
        _SalesMixCard(
            items: data.categorySales, onTap: () => onDetails('sales_mix')),
        const _SectionTitle(
            'Salesman target achievement', 'Tap chart for all salesmen'),
        _VerticalBarChart(
            items: data.salesmanSales,
            color: const Color(0xff2bb673),
            onTap: () => onDetails('salesmen')),
        const _SectionTitle('Top customers', 'Customer concentration'),
        _CustomerCard(customers: data.topCustomers),
        const _SectionTitle(
            'Collections and outstanding', 'Cash realization and receivables'),
        _CollectionsCard(data: data),
        const _SectionTitle('Incentives', 'Cost monitoring'),
        _IncentiveCard(),
      ],
    );
  }
}

class _PageScroll extends StatelessWidget {
  final List<Widget> children;
  const _PageScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: children
          .expand((child) => [child, const SizedBox(height: 14)])
          .toList(),
    );
  }
}

class _OwnerDetailRecord {
  final String title;
  final String subtitle;
  final List<String> lines;

  const _OwnerDetailRecord(this.title, this.subtitle, this.lines);
}

class _OwnerDataDetailsScreen extends StatelessWidget {
  final String type;

  const _OwnerDataDetailsScreen({required this.type});

  String get _title {
    switch (type) {
      case 'open_orders':
        return 'Open orders';
      case 'customers':
        return 'Customers';
      case 'low_stock':
        return 'Low stock';
      case 'sales_mix':
        return 'Sales mix details';
      case 'inventory':
        return 'Inventory health details';
      case 'salesmen':
        return 'All salesmen';
      default:
        return 'Salesman details';
    }
  }

  List<_OwnerDetailRecord> get _records {
    switch (type) {
      case 'open_orders':
        return const [
          _OwnerDetailRecord('ST-1042 · Royal Ceramic', 'Ready for dispatch', [
            'Showroom: Kolhapur',
            'Delivery: Today, 4:00 PM',
            'Order value: ₹68,500'
          ]),
          _OwnerDetailRecord('ST-1043 · Shree Tiles', 'Loading scheduled', [
            'Showroom: Belgav',
            'Delivery: Today, 5:30 PM',
            'Order value: ₹42,800'
          ]),
          _OwnerDetailRecord(
              'ST-1044 · Balaji Tiles', 'Vehicle assignment pending', [
            'Showroom: Mudaltittha',
            'Delivery: Today, 6:00 PM',
            'Order value: ₹31,200'
          ]),
        ];
      case 'customers':
        return const [
          _OwnerDetailRecord(
              'Royal Ceramic', 'Active customer · 4 open orders', [
            'Showroom: Kolhapur',
            'Outstanding: ₹2,40,000',
            'Last enquiry: Today'
          ]),
          _OwnerDetailRecord('Balaji Tiles', 'Collection follow-up required', [
            'Showroom: Belgav',
            'Outstanding: ₹4,18,000',
            'Last invoice: Yesterday'
          ]),
          _OwnerDetailRecord('Shree Tiles', 'Active customer · 3 enquiries', [
            'Showroom: Mudaltittha',
            'Outstanding: ₹1,26,500',
            'Last enquiry: Today'
          ]),
        ];
      case 'low_stock':
        return const [
          _OwnerDetailRecord('Vitrified Tile 600x600', '12 boxes remaining', [
            'Location: Mudaltittha',
            'Minimum level: 50 boxes',
            'Shortage: 38 boxes'
          ]),
          _OwnerDetailRecord('Granite Slab Black', '8 pieces remaining', [
            'Location: Kolhapur',
            'Minimum level: 30 pieces',
            'Shortage: 22 pieces'
          ]),
          _OwnerDetailRecord('Sanitaryware WC', '5 pieces remaining', [
            'Location: Belgav',
            'Minimum level: 20 pieces',
            'Shortage: 15 pieces'
          ]),
        ];
      case 'sales_mix':
        return const [
          _OwnerDetailRecord('Tiles', '56% of sales', [
            '₹6.98 L sales value',
            'Top branch: Kolhapur',
            'Top product: Vitrified Tile 600x600'
          ]),
          _OwnerDetailRecord('Granite', '24% of sales', [
            '₹2.99 L sales value',
            'Top branch: Belgav',
            'Top product: Granite Slab Black'
          ]),
          _OwnerDetailRecord('Sanitaryware', '12% of sales', [
            '₹1.49 L sales value',
            'Top branch: Mudaltittha',
            'Top product: Sanitaryware WC'
          ]),
          _OwnerDetailRecord('Kadappa', '8% of sales', [
            '₹1.00 L sales value',
            'Top branch: Examba',
            'Top product: Kadappa Stone'
          ]),
        ];
      case 'inventory':
        return const [
          _OwnerDetailRecord('Vitrified Tile 600x600', 'Healthy · 820 boxes', [
            'Location: Kolhapur',
            'Minimum: 500 boxes',
            'Movement this month: +120 boxes'
          ]),
          _OwnerDetailRecord('Granite Slab Black', 'Low stock · 148 pieces', [
            'Location: Belgav',
            'Minimum: 300 pieces',
            'Pending purchase: 100 pieces'
          ]),
          _OwnerDetailRecord('Sanitaryware WC', 'Low stock · 96 pieces', [
            'Location: Mudaltittha',
            'Minimum: 180 pieces',
            'Pending purchase: 60 pieces'
          ]),
        ];
      case 'salesmen':
        return const [
          _OwnerDetailRecord('Surbhi Sikchi', '92% achievement · On track', [
            'Branch: Kolhapur',
            'Target: ₹6,00,000 · Actual: ₹5,52,000',
            'Invoices: 32 · Gap: ₹48,000'
          ]),
          _OwnerDetailRecord('Sudarshan Anuse', '84% achievement · On track', [
            'Branch: Belgav',
            'Target: ₹6,00,000 · Actual: ₹5,04,000',
            'Invoices: 27 · Gap: ₹96,000'
          ]),
          _OwnerDetailRecord(
              'Akshay Kurne', '74% achievement · Needs attention', [
            'Branch: Mudaltittha',
            'Target: ₹5,00,000 · Actual: ₹3,70,000',
            'Invoices: 21 · Gap: ₹1,30,000'
          ]),
          _OwnerDetailRecord(
              'Archana Kumbhar', '63% achievement · Below target', [
            'Branch: Examba',
            'Target: ₹4,00,000 · Actual: ₹2,52,000',
            'Invoices: 18 · Gap: ₹1,48,000'
          ]),
        ];
      default:
        return const [
          _OwnerDetailRecord('Surbhi Sikchi', '92% target achievement', [
            'Branch: Kolhapur',
            'Target: ₹6,00,000 · Achieved: ₹5,52,000',
            'Gap: ₹48,000'
          ]),
          _OwnerDetailRecord('Sudarshan Anuse', '84% target achievement', [
            'Branch: Belgav',
            'Target: ₹6,00,000 · Achieved: ₹5,04,000',
            'Gap: ₹96,000'
          ]),
          _OwnerDetailRecord('Archana Kumbhar', '63% target achievement', [
            'Branch: Examba',
            'Target: ₹4,00,000 · Achieved: ₹2,52,000',
            'Gap: ₹1,48,000'
          ]),
        ];
    }
  }

  Future<ResponseSmartAuditor> _loadSalesmen() {
    return Request.sharedInstance.postRequest(
      {
        'target_type': 'monthly',
        'target_period':
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
      },
      APIConstant.ownerSalesmenPerformance,
    );
  }

  List<_OwnerDetailRecord> _recordsFromApi(dynamic body) {
    if (body is! List || body.isEmpty) return _records;
    return body.map<_OwnerDetailRecord>((item) {
      final row = Map<String, dynamic>.from(item as Map);
      final name = '${row['salesman_name'] ?? 'Salesman'}';
      final target = '${row['target_amount'] ?? 0}';
      final actual = '${row['actual_sales'] ?? 0}';
      final achievement = '${row['achievement_pct'] ?? 0}%';
      return _OwnerDetailRecord(name, '$achievement achievement', [
        'Branch: ${row['location'] ?? 'All locations'}',
        'Target: ₹$target · Actual: ₹$actual',
        'Invoices: ${row['invoice_count'] ?? 'Pending ERP data'} · Gap: ${row['variance_amount'] ?? 0}',
      ]);
    }).toList();
  }

  Widget _buildScreen(BuildContext context, List<_OwnerDetailRecord> records) =>
      Scaffold(
        backgroundColor: const Color(0xfff5f7fb),
        appBar: AppBar(
            title: Text(_title),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff16233b),
            elevation: 0),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (type == 'salesmen')
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text('Current month · top performers first',
                    style: TextStyle(
                        color: Color(0xff68758b), fontWeight: FontWeight.w600)),
              ),
            ...records
                .map((record) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff16233b))),
                          const SizedBox(height: 4),
                          Text(record.subtitle,
                              style: const TextStyle(
                                  color: Color(0xff1769aa),
                                  fontWeight: FontWeight.w600)),
                          const Divider(height: 20),
                          ...record.lines.map((line) => Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Text(line,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff34445d))),
                              )),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (type != 'salesmen') return _buildScreen(context, _records);
    return FutureBuilder<ResponseSmartAuditor>(
      future: _loadSalesmen(),
      builder: (context, snapshot) {
        final records = snapshot.hasData && snapshot.data!.status
            ? _recordsFromApi(snapshot.data!.body)
            : _records;
        return _buildScreen(context, records);
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final name = AppUser.sharedInstance.name.trim();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
            colors: [Color(0xff1b568c), Color(0xff2b87bd)]),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning${name.isEmpty ? '' : ', $name'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Here is what is happening across your business.',
                  style:
                      GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle(this.title, [this.subtitle]);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xff16233b),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 11, color: Color(0xff7c8798)),
            ),
        ],
      );
}

class _KpiGrid extends StatelessWidget {
  final List<OwnerKpi> kpis;
  const _KpiGrid({required this.kpis});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kpis.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.75),
        itemBuilder: (_, index) {
          final kpi = kpis[index];
          return Container(
            padding: const EdgeInsets.all(13),
            decoration: _cardDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(kpi.label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xff68758b))),
                  Text(kpi.value,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: const Color(0xff16233b),
                          fontWeight: FontWeight.w700)),
                  Text('${kpi.positive ? '↑' : '↓'} ${kpi.change} vs previous',
                      style: TextStyle(
                          fontSize: 11,
                          color: kpi.positive
                              ? const Color(0xff169c70)
                              : Colors.red)),
                ]),
          );
        },
      );
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _MiniMetric(
      {required this.icon,
      required this.label,
      required this.value,
      this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: _cardDecoration(),
          child: Column(children: [
            Icon(icon, color: const Color(0xff1d6ea8)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 18)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Color(0xff68758b)))
          ]),
        ),
      );
}

class _SalesMixCard extends StatelessWidget {
  final List<OwnerBreakdown> items;
  final VoidCallback? onTap;

  const _SalesMixCard({required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xff2f73d9),
      const Color(0xff2bb673),
      const Color(0xffffb52e),
      const Color(0xff8556d8),
      const Color(0xff9aa7b8),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            SizedBox(
              width: 142,
              height: 142,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  values: items.map((item) => item.amount).toList(),
                  colors: colors,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sales',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11),
                      ),
                      Text(
                        '100%',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xff16233b),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < items.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              items[index].label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xff34445d)),
                            ),
                          ),
                          Text(
                            items[index].displayValue,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.30;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    var startAngle = -math.pi / 2;

    for (var index = 0; index < values.length; index++) {
      final sweep = (values[index] / total) * math.pi * 2;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

class _VerticalBarChart extends StatelessWidget {
  final List<OwnerBreakdown> items;
  final Color color;
  final VoidCallback? onTap;

  const _VerticalBarChart(
      {required this.items, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final max =
        items.fold<double>(0, (value, item) => math.max(value, item.amount));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: _cardDecoration(),
        child: SizedBox(
          height: 170,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.displayValue,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: max == 0
                              ? 4
                              : math.max(8, item.amount / max * 108),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color, color.withAlpha(115)],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xff68758b)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryHealthChart extends StatelessWidget {
  const _InventoryHealthChart();

  @override
  Widget build(BuildContext context) {
    const labels = ['Tiles', 'Granite', 'Sanitaryware', 'Kadappa'];
    const values = [72.0, 43.0, 31.0, 18.0];
    const colors = [
      Color(0xff2bb673),
      Color(0xff2f73d9),
      Color(0xffffb52e),
      Color(0xff8556d8),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ChartLegend(color: colors[0], label: 'Healthy'),
              const SizedBox(width: 12),
              _ChartLegend(color: colors[2], label: 'Low'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var index = 0; index < labels.length; index++)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 34,
                        height: values[index] * 1.35,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colors[index],
                              colors[index].withAlpha(115)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(labels[index],
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xff68758b))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xff68758b))),
        ],
      );
}

class _InventoryCard extends StatelessWidget {
  final OwnerDashboardData data;
  final VoidCallback? onTap;
  const _InventoryCard({required this.data, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(children: [
            Expanded(
                child: _InventoryValue('Total SKUs', '${data.totalSkus}',
                    const Color(0xff2b78bd))),
            Expanded(
                child: _InventoryValue(
                    'In stock',
                    '${data.totalSkus - data.lowStock}',
                    const Color(0xff21a579))),
            Expanded(
                child: _InventoryValue(
                    'Low stock', '${data.lowStock}', const Color(0xffe5a329))),
          ]),
        ),
      );
}

class _InventoryValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InventoryValue(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xff68758b)))
      ]);
}

class _AlertDetailRow {
  final String label;
  final String value;

  const _AlertDetailRow(this.label, this.value);
}

class _AlertRecord {
  final String title;
  final String subtitle;
  final List<_AlertDetailRow> details;

  const _AlertRecord(this.title, this.subtitle, this.details);
}

class _AlertDetailsScreen extends StatelessWidget {
  final OwnerAlert alert;
  final List<_AlertRecord> records;

  const _AlertDetailsScreen({required this.alert, required this.records});

  void _showActionMessage(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _openRecordAction(BuildContext context, _AlertRecord record) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.title,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff16233b))),
              const SizedBox(height: 4),
              const Text('What would you like to do?',
                  style: TextStyle(color: Color(0xff68758b))),
              const SizedBox(height: 16),
              _ActionTile(
                  icon: Icons.check_circle_outline,
                  label: 'Mark as reviewed',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showActionMessage(context, 'Marked as reviewed',
                        'This record is now ready to be removed from active attention after ERP/backend integration.');
                  }),
              _ActionTile(
                  icon: Icons.open_in_new,
                  label: 'Open full record',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showActionMessage(context, 'Full record',
                        'This opens the linked invoice, customer, order, or product record after ERP APIs are connected.');
                  }),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: Text(alert.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff16233b),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(alert.detail, style: const TextStyle(color: Color(0xff68758b))),
          const SizedBox(height: 16),
          Text('${records.length} sample records',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16233b))),
          const SizedBox(height: 10),
          ...records.map((record) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff16233b))),
                      const SizedBox(height: 4),
                      Text(record.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff68758b))),
                      const Divider(height: 20),
                      ...record.details.map((row) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: 105,
                                      child: Text(row.label,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff68758b)))),
                                  Expanded(
                                      child: Text(row.value,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff34445d)))),
                                ]),
                          )),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () =>
                                  _openRecordAction(context, record),
                              child: Text(alert.action))),
                    ]),
              )),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: const Color(0xff1769aa)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}

class _AlertCard extends StatelessWidget {
  final List<OwnerAlert> alerts;
  const _AlertCard({required this.alerts});

  void _showDetails(BuildContext context, OwnerAlert alert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AlertDetailsScreen(
          alert: alert,
          records: _recordsFor(alert.title),
        ),
      ),
    );
  }

  List<_AlertRecord> _recordsFor(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('dispatch')) {
      return const [
        _AlertRecord('ST-1042 · Royal Ceramic', 'Ready for dispatch', [
          _AlertDetailRow('Showroom', 'Kolhapur'),
          _AlertDetailRow('Delivery', 'Today, 4:00 PM'),
          _AlertDetailRow('Value', '₹68,500')
        ]),
        _AlertRecord('ST-1043 · Shree Tiles', 'Loading scheduled', [
          _AlertDetailRow('Showroom', 'Belgav'),
          _AlertDetailRow('Delivery', 'Today, 5:30 PM'),
          _AlertDetailRow('Value', '₹42,800')
        ]),
        _AlertRecord('ST-1044 · Balaji Tiles', 'Vehicle assignment pending', [
          _AlertDetailRow('Showroom', 'Mudaltittha'),
          _AlertDetailRow('Delivery', 'Today, 6:00 PM'),
          _AlertDetailRow('Value', '₹31,200')
        ]),
      ];
    }
    if (normalized.contains('credit')) {
      return const [
        _AlertRecord('Balaji Tiles', '83.6% credit used', [
          _AlertDetailRow('Showroom', 'Belgav'),
          _AlertDetailRow('Limit', '₹5,00,000'),
          _AlertDetailRow('Outstanding', '₹4,18,000')
        ]),
        _AlertRecord('Royal Ceramic', '81.2% credit used', [
          _AlertDetailRow('Showroom', 'Kolhapur'),
          _AlertDetailRow('Limit', '₹8,00,000'),
          _AlertDetailRow('Outstanding', '₹6,49,600')
        ]),
        _AlertRecord('Mahalaxmi Builders', '80.4% credit used', [
          _AlertDetailRow('Showroom', 'Examba'),
          _AlertDetailRow('Limit', '₹10,00,000'),
          _AlertDetailRow('Outstanding', '₹8,04,000')
        ]),
      ];
    }
    if (normalized.contains('stock')) {
      return const [
        _AlertRecord('Vitrified Tile 600x600', '38 boxes below minimum', [
          _AlertDetailRow('Location', 'Mudaltittha'),
          _AlertDetailRow('Current', '12 boxes'),
          _AlertDetailRow('Minimum', '50 boxes')
        ]),
        _AlertRecord('Granite Slab Black', '22 pieces below minimum', [
          _AlertDetailRow('Location', 'Kolhapur'),
          _AlertDetailRow('Current', '8 pieces'),
          _AlertDetailRow('Minimum', '30 pieces')
        ]),
        _AlertRecord('Sanitaryware WC', '15 pieces below minimum', [
          _AlertDetailRow('Location', 'Belgav'),
          _AlertDetailRow('Current', '5 pieces'),
          _AlertDetailRow('Minimum', '20 pieces')
        ]),
      ];
    }
    if (normalized.contains('target')) {
      return const [
        _AlertRecord('Archana Kumbhar', '63% of monthly target', [
          _AlertDetailRow('Branch', 'Examba'),
          _AlertDetailRow('Target', '₹4,00,000'),
          _AlertDetailRow('Achieved', '₹2,52,000')
        ]),
        _AlertRecord('Akshay Kurne', '74% of monthly target', [
          _AlertDetailRow('Branch', 'Mudaltittha'),
          _AlertDetailRow('Target', '₹5,00,000'),
          _AlertDetailRow('Achieved', '₹3,70,000')
        ]),
        _AlertRecord('Sudarshan Anuse', '84% of monthly target', [
          _AlertDetailRow('Branch', 'Belgav'),
          _AlertDetailRow('Target', '₹6,00,000'),
          _AlertDetailRow('Achieved', '₹5,04,000')
        ]),
      ];
    }
    return const [
      _AlertRecord('EX-2026-018', 'High discount exception', [
        _AlertDetailRow('Showroom', 'Kolhapur'),
        _AlertDetailRow('Customer', 'Royal Ceramic'),
        _AlertDetailRow('Amount', '₹42,000')
      ]),
      _AlertRecord('EX-2026-019', 'Low margin exception', [
        _AlertDetailRow('Showroom', 'Belgav'),
        _AlertDetailRow('Customer', 'Balaji Tiles'),
        _AlertDetailRow('Amount', '₹31,500')
      ]),
      _AlertRecord('EX-2026-020', 'High discount exception', [
        _AlertDetailRow('Showroom', 'Mudaltittha'),
        _AlertDetailRow('Customer', 'Shree Tiles'),
        _AlertDetailRow('Amount', '₹27,800')
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: _cardDecoration(),
        child: Column(
            children: alerts
                .map((alert) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.warning_amber_rounded,
                          color: Color(0xffe5a329)),
                      title: Text(alert.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: Text(alert.detail,
                          style: const TextStyle(fontSize: 11)),
                      onTap: () => _showDetails(context, alert),
                      trailing: Text(alert.action,
                          style: const TextStyle(
                              color: Color(0xff1d6ea8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ))
                .toList()),
      );
}

class _CustomerCard extends StatelessWidget {
  final List<OwnerCustomer> customers;
  const _CustomerCard({required this.customers});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: customers
            .map(
              (customer) => ListTile(
                dense: true,
                leading: const CircleAvatar(
                  radius: 15,
                  child: Icon(Icons.storefront_outlined, size: 16),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  customer.value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CollectionsCard extends StatelessWidget {
  final OwnerDashboardData data;
  const _CollectionsCard({required this.data});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Collections\n${data.kpis[2].value}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xff169c70), fontWeight: FontWeight.w700)),
        Text('Outstanding\n${data.kpis[3].value}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xffd36b45), fontWeight: FontWeight.w700))
      ]));
}

class _IncentiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Total accrued\n₹1.24 L',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('As % of sales\n1.0%',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700))
          ]));
}

BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0d20304a), blurRadius: 10, offset: Offset(0, 3))
        ]);
