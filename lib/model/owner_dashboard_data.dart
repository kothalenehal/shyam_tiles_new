/// Owner dashboard data model and repository helper.
/// Supports filtering by Day, Week, Month, or Custom Date / Range.

enum DashboardPeriodType {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  customDate,
  customRange,
}

class DashboardFilter {
  final DashboardPeriodType type;
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;

  const DashboardFilter({
    required this.type,
    required this.label,
    this.startDate,
    this.endDate,
  });

  static DashboardFilter today() => const DashboardFilter(
        type: DashboardPeriodType.today,
        label: 'Today',
      );

  static DashboardFilter yesterday() => const DashboardFilter(
        type: DashboardPeriodType.yesterday,
        label: 'Yesterday',
      );

  static DashboardFilter thisWeek() => const DashboardFilter(
        type: DashboardPeriodType.thisWeek,
        label: 'This week',
      );

  static DashboardFilter lastWeek() => const DashboardFilter(
        type: DashboardPeriodType.lastWeek,
        label: 'Last week',
      );

  static DashboardFilter thisMonth() => const DashboardFilter(
        type: DashboardPeriodType.thisMonth,
        label: 'This month',
      );

  static DashboardFilter lastMonth() => const DashboardFilter(
        type: DashboardPeriodType.lastMonth,
        label: 'Last month',
      );

  static DashboardFilter singleDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final label = '${date.day} ${months[date.month - 1]} ${date.year}';
    return DashboardFilter(
      type: DashboardPeriodType.customDate,
      label: label,
      startDate: date,
      endDate: date,
    );
  }

  static DashboardFilter range(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final label = '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]}';
    return DashboardFilter(
      type: DashboardPeriodType.customRange,
      label: label,
      startDate: start,
      endDate: end,
    );
  }
}

class OwnerDashboardData {
  final String periodLabel;
  final DashboardFilter filter;
  final List<OwnerKpi> kpis;
  final List<OwnerBreakdown> branchSales;
  final List<OwnerBreakdown> categorySales;
  final List<OwnerBreakdown> salesmanSales;
  final List<OwnerCustomer> topCustomers;
  final List<OwnerAlert> managementAlerts;
  final int openOrders;
  final int activeCustomers;
  final int enquiries;
  final int totalSkus;
  final int lowStock;

  const OwnerDashboardData({
    required this.periodLabel,
    required this.filter,
    required this.kpis,
    required this.branchSales,
    required this.categorySales,
    required this.salesmanSales,
    required this.topCustomers,
    required this.managementAlerts,
    required this.openOrders,
    required this.activeCustomers,
    required this.enquiries,
    required this.totalSkus,
    required this.lowStock,
  });

  OwnerDashboardData copyWith({
    List<OwnerBreakdown>? branchSales,
    List<OwnerBreakdown>? categorySales,
    List<OwnerBreakdown>? salesmanSales,
    List<OwnerCustomer>? topCustomers,
    List<OwnerAlert>? managementAlerts,
    List<OwnerKpi>? kpis,
    int? openOrders,
    int? activeCustomers,
    int? enquiries,
    int? totalSkus,
    int? lowStock,
  }) {
    return OwnerDashboardData(
      periodLabel: periodLabel,
      filter: filter,
      kpis: kpis ?? this.kpis,
      branchSales: branchSales ?? this.branchSales,
      categorySales: categorySales ?? this.categorySales,
      salesmanSales: salesmanSales ?? this.salesmanSales,
      topCustomers: topCustomers ?? this.topCustomers,
      managementAlerts: managementAlerts ?? this.managementAlerts,
      openOrders: openOrders ?? this.openOrders,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      enquiries: enquiries ?? this.enquiries,
      totalSkus: totalSkus ?? this.totalSkus,
      lowStock: lowStock ?? this.lowStock,
    );
  }

  OwnerDashboardData forLocation(String location) {
    if (location.isEmpty || location.toLowerCase() == 'all locations') {
      return this;
    }

    final loc = location.toLowerCase();
    if (loc.contains('kolhapur')) {
      return OwnerDashboardData(
        periodLabel: periodLabel,
        filter: filter,
        kpis: const [
          OwnerKpi('Total sales', '₹5.8 L', '+14%', true),
          OwnerKpi('Orders booked', '12', '+3', true),
          OwnerKpi('Collections', '₹4.5 L', '+11%', true),
          OwnerKpi('Outstanding', '₹7.2 L', '-2%', true),
        ],
        branchSales: const [
          OwnerBreakdown('Kolhapur', 5.8, '₹5.8 L'),
        ],
        categorySales: const [
          OwnerBreakdown('Tiles', 56, '56%'),
          OwnerBreakdown('Granite', 24, '24%'),
          OwnerBreakdown('Sanitaryware', 12, '12%'),
          OwnerBreakdown('Kadappa', 8, '8%'),
        ],
        salesmanSales: const [
          OwnerBreakdown('Surbhi Sikchi', 92, '92%'),
          OwnerBreakdown('Sudarshan Anuse', 84, '84%'),
        ],
        topCustomers: const [
          OwnerCustomer('Shree Tiles', '₹2.1 L'),
          OwnerCustomer('Royal Ceramic', '₹1.8 L'),
        ],
        managementAlerts: const [
          OwnerAlert('Kolhapur delivery pending',
              '2 dispatches scheduled today', 'View'),
          OwnerAlert('Kolhapur stock check',
              '18 tile items low in warehouse', 'Replenish'),
        ],
        openOrders: 11,
        activeCustomers: 14,
        enquiries: 22,
        totalSkus: 1420,
        lowStock: 68,
      );
    } else if (loc.contains('belgav')) {
      return OwnerDashboardData(
        periodLabel: periodLabel,
        filter: filter,
        kpis: const [
          OwnerKpi('Total sales', '₹3.6 L', '+8%', true),
          OwnerKpi('Orders booked', '7', '+1', true),
          OwnerKpi('Collections', '₹2.8 L', '+7%', true),
          OwnerKpi('Outstanding', '₹4.8 L', '-3%', true),
        ],
        branchSales: const [
          OwnerBreakdown('Belgav', 3.6, '₹3.6 L'),
        ],
        categorySales: const [
          OwnerBreakdown('Tiles', 50, '50%'),
          OwnerBreakdown('Granite', 26, '26%'),
          OwnerBreakdown('Sanitaryware', 14, '14%'),
          OwnerBreakdown('Kadappa', 10, '10%'),
        ],
        salesmanSales: const [
          OwnerBreakdown('Akshay Kurne', 76, '76%'),
          OwnerBreakdown('Archana Kumbhar', 63, '63%'),
        ],
        topCustomers: const [
          OwnerCustomer('Balaji Tiles', '₹1.4 L'),
          OwnerCustomer('Mahaveer Ceramics', '₹85 K'),
        ],
        managementAlerts: const [
          OwnerAlert('Belgav target status',
              'Branch reached 85% of monthly target', 'Details'),
          OwnerAlert('Stock replenishment',
              '14 granite slabs low in showroom', 'Order'),
        ],
        openOrders: 6,
        activeCustomers: 9,
        enquiries: 15,
        totalSkus: 980,
        lowStock: 74,
      );
    } else if (loc.contains('mudaltittha')) {
      return OwnerDashboardData(
        periodLabel: periodLabel,
        filter: filter,
        kpis: const [
          OwnerKpi('Total sales', '₹1.8 L', '+5%', true),
          OwnerKpi('Orders booked', '3', '+1', true),
          OwnerKpi('Collections', '₹1.4 L', '+5%', true),
          OwnerKpi('Outstanding', '₹2.6 L', '-1%', true),
        ],
        branchSales: const [
          OwnerBreakdown('Mudaltittha', 1.8, '₹1.8 L'),
        ],
        categorySales: const [
          OwnerBreakdown('Tiles', 48, '48%'),
          OwnerBreakdown('Granite', 28, '28%'),
          OwnerBreakdown('Sanitaryware', 14, '14%'),
          OwnerBreakdown('Kadappa', 10, '10%'),
        ],
        salesmanSales: const [
          OwnerBreakdown('Sudarshan Anuse', 80, '80%'),
          OwnerBreakdown('Akshay Kurne', 70, '70%'),
        ],
        topCustomers: const [
          OwnerCustomer('Kolhapur Builders', '₹1.1 L'),
          OwnerCustomer('Samarth Infra', '₹75 K'),
        ],
        managementAlerts: const [
          OwnerAlert('Mudaltittha payment follow-up',
              '1 overdue collection of ₹45,000', 'Call'),
        ],
        openOrders: 4,
        activeCustomers: 6,
        enquiries: 10,
        totalSkus: 840,
        lowStock: 52,
      );
    } else if (loc.contains('examba')) {
      return OwnerDashboardData(
        periodLabel: periodLabel,
        filter: filter,
        kpis: const [
          OwnerKpi('Total sales', '₹1.2 L', '+4%', true),
          OwnerKpi('Orders booked', '2', '0', false),
          OwnerKpi('Collections', '₹1.0 L', '+3%', true),
          OwnerKpi('Outstanding', '₹1.8 L', '0%', true),
        ],
        branchSales: const [
          OwnerBreakdown('Examba', 1.2, '₹1.2 L'),
        ],
        categorySales: const [
          OwnerBreakdown('Tiles', 52, '52%'),
          OwnerBreakdown('Granite', 22, '22%'),
          OwnerBreakdown('Sanitaryware', 16, '16%'),
          OwnerBreakdown('Kadappa', 10, '10%'),
        ],
        salesmanSales: const [
          OwnerBreakdown('Archana Kumbhar', 65, '65%'),
        ],
        topCustomers: const [
          OwnerCustomer('Shanti Construction', '₹80 K'),
          OwnerCustomer('Rural Infra', '₹55 K'),
        ],
        managementAlerts: const [
          OwnerAlert('Examba visit scheduled',
              'Weekly showroom inspection on Friday', 'Plan'),
        ],
        openOrders: 2,
        activeCustomers: 3,
        enquiries: 7,
        totalSkus: 650,
        lowStock: 54,
      );
    }

    return this;
  }

  static OwnerDashboardData demo({DashboardFilter? filter}) {
    final activeFilter = filter ?? DashboardFilter.thisMonth();

    switch (activeFilter.type) {
      case DashboardPeriodType.today:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹68,400', '+14%', true),
            OwnerKpi('Orders booked', '6', '+2', true),
            OwnerKpi('Collections', '₹42,500', '+8%', true),
            OwnerKpi('Outstanding', '₹18.6 L', '-1%', true),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 32, '₹32.5 K'),
            OwnerBreakdown('Belgav', 18, '₹18.0 K'),
            OwnerBreakdown('Mudaltittha', 12, '₹12.4 K'),
            OwnerBreakdown('Examba', 5.5, '₹5.5 K'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 55, '55%'),
            OwnerBreakdown('Granite', 22, '22%'),
            OwnerBreakdown('Sanitaryware', 15, '15%'),
            OwnerBreakdown('Kadappa', 8, '8%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 88, '₹24 K'),
            OwnerBreakdown('Sudarshan Anuse', 72, '₹18 K'),
            OwnerBreakdown('Akshay Kurne', 65, '₹15 K'),
            OwnerBreakdown('Archana Kumbhar', 50, '₹11 K'),
          ],
          topCustomers: const [
            OwnerCustomer('Shree Tiles', '₹28,000'),
            OwnerCustomer('Royal Ceramic', '₹22,500'),
            OwnerCustomer('Balaji Tiles', '₹17,900'),
          ],
          managementAlerts: const [
            OwnerAlert('Pending dispatch today', '4 orders scheduled for delivery today', 'View'),
            OwnerAlert('Credit limit alert', 'Customer Balaji Tiles exceeded 80% limit', 'Check'),
            OwnerAlert('Low stock items', '41 products need replenishment', 'View'),
          ],
          openOrders: 6,
          activeCustomers: 9,
          enquiries: 14,
          totalSkus: 2481,
          lowStock: 248,
        );

      case DashboardPeriodType.yesterday:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹54,200', '-6%', false),
            OwnerKpi('Orders booked', '5', '-1', false),
            OwnerKpi('Collections', '₹38,000', '+4%', true),
            OwnerKpi('Outstanding', '₹18.6 L', '0%', true),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 24, '₹24.0 K'),
            OwnerBreakdown('Belgav', 15, '₹15.2 K'),
            OwnerBreakdown('Mudaltittha', 10, '₹10.0 K'),
            OwnerBreakdown('Examba', 5, '₹5.0 K'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 50, '50%'),
            OwnerBreakdown('Granite', 25, '25%'),
            OwnerBreakdown('Sanitaryware', 15, '15%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 80, '₹20 K'),
            OwnerBreakdown('Sudarshan Anuse', 75, '₹17 K'),
            OwnerBreakdown('Akshay Kurne', 60, '₹10 K'),
            OwnerBreakdown('Archana Kumbhar', 45, '₹7 K'),
          ],
          topCustomers: const [
            OwnerCustomer('Mahalaxmi Builders', '₹24,000'),
            OwnerCustomer('Samarth Infra', '₹18,500'),
            OwnerCustomer('Kiran Enterprises', '₹11,700'),
          ],
          managementAlerts: const [
            OwnerAlert('Discount review', '2 invoices had discounts > 12%', 'Review'),
            OwnerAlert('Low stock items', '41 products need replenishment', 'View'),
          ],
          openOrders: 8,
          activeCustomers: 7,
          enquiries: 11,
          totalSkus: 2481,
          lowStock: 248,
        );

      case DashboardPeriodType.thisWeek:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹3.45 L', '+11%', true),
            OwnerKpi('Sales growth', '9.4%', '+3.2%', true),
            OwnerKpi('Collections', '₹2.80 L', '+12%', true),
            OwnerKpi('Outstanding', '₹18.6 L', '-2%', true),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 1.45, '₹1.45 L'),
            OwnerBreakdown('Belgav', 0.95, '₹0.95 L'),
            OwnerBreakdown('Mudaltittha', 0.65, '₹0.65 L'),
            OwnerBreakdown('Examba', 0.40, '₹0.40 L'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 53, '53%'),
            OwnerBreakdown('Granite', 23, '23%'),
            OwnerBreakdown('Sanitaryware', 14, '14%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 90, '90%'),
            OwnerBreakdown('Sudarshan Anuse', 82, '82%'),
            OwnerBreakdown('Akshay Kurne', 74, '74%'),
            OwnerBreakdown('Archana Kumbhar', 61, '61%'),
          ],
          topCustomers: const [
            OwnerCustomer('Shree Tiles', '₹85,000'),
            OwnerCustomer('Royal Ceramic', '₹62,000'),
            OwnerCustomer('Balaji Tiles', '₹45,000'),
          ],
          managementAlerts: const [
            OwnerAlert('Weekly target gap', 'Mudaltittha branch is 15% behind weekly plan', 'Details'),
            OwnerAlert('High discount exceptions', '3 orders need owner approval', 'Review'),
            OwnerAlert('Low stock items', '41 products need replenishment', 'View'),
          ],
          openOrders: 15,
          activeCustomers: 21,
          enquiries: 34,
          totalSkus: 2481,
          lowStock: 248,
        );

      case DashboardPeriodType.lastWeek:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹3.10 L', '+4%', true),
            OwnerKpi('Sales growth', '6.2%', '+1.1%', true),
            OwnerKpi('Collections', '₹2.50 L', '+5%', true),
            OwnerKpi('Outstanding', '₹18.9 L', '+1%', false),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 1.30, '₹1.30 L'),
            OwnerBreakdown('Belgav', 0.88, '₹0.88 L'),
            OwnerBreakdown('Mudaltittha', 0.58, '₹0.58 L'),
            OwnerBreakdown('Examba', 0.34, '₹0.34 L'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 51, '51%'),
            OwnerBreakdown('Granite', 24, '24%'),
            OwnerBreakdown('Sanitaryware', 15, '15%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 86, '86%'),
            OwnerBreakdown('Sudarshan Anuse', 79, '79%'),
            OwnerBreakdown('Akshay Kurne', 70, '70%'),
            OwnerBreakdown('Archana Kumbhar', 58, '58%'),
          ],
          topCustomers: const [
            OwnerCustomer('Mahalaxmi Builders', '₹72,000'),
            OwnerCustomer('Royal Ceramic', '₹58,000'),
            OwnerCustomer('Samarth Infra', '₹41,000'),
          ],
          managementAlerts: const [
            OwnerAlert('Completed week audit', '2 overdue payments settled', 'Archive'),
            OwnerAlert('Low stock items', '45 products replenished', 'History'),
          ],
          openOrders: 18,
          activeCustomers: 24,
          enquiries: 29,
          totalSkus: 2481,
          lowStock: 232,
        );

      case DashboardPeriodType.lastMonth:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹11.6 L', '+5.5%', true),
            OwnerKpi('Sales growth', '5.5%', '+0.8%', true),
            OwnerKpi('Collections', '₹10.1 L', '+7%', true),
            OwnerKpi('Outstanding', '₹19.2 L', '+2%', false),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 4.9, '₹4.9 L'),
            OwnerBreakdown('Belgav', 2.9, '₹2.9 L'),
            OwnerBreakdown('Mudaltittha', 2.2, '₹2.2 L'),
            OwnerBreakdown('Examba', 1.6, '₹1.6 L'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 50, '50%'),
            OwnerBreakdown('Granite', 25, '25%'),
            OwnerBreakdown('Sanitaryware', 15, '15%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 89, '89%'),
            OwnerBreakdown('Sudarshan Anuse', 81, '81%'),
            OwnerBreakdown('Akshay Kurne', 73, '73%'),
            OwnerBreakdown('Archana Kumbhar', 60, '60%'),
          ],
          topCustomers: const [
            OwnerCustomer('Shree Tiles', '₹1.9 L'),
            OwnerCustomer('Royal Ceramic', '₹1.6 L'),
            OwnerCustomer('Balaji Tiles', '₹1.3 L'),
          ],
          managementAlerts: const [
            OwnerAlert('Closed period summary', 'Target achieved: 94% across all branches', 'Report'),
            OwnerAlert('Quarterly tax preview', 'GST reconciliation ready for review', 'Review'),
          ],
          openOrders: 28,
          activeCustomers: 38,
          enquiries: 52,
          totalSkus: 2481,
          lowStock: 250,
        );

      case DashboardPeriodType.customDate:
      case DashboardPeriodType.customRange:
        return OwnerDashboardData(
          periodLabel: activeFilter.label,
          filter: activeFilter,
          kpis: const [
            OwnerKpi('Total sales', '₹2.15 L', '+7.5%', true),
            OwnerKpi('Sales growth', '7.5%', '+1.8%', true),
            OwnerKpi('Collections', '₹1.80 L', '+9%', true),
            OwnerKpi('Outstanding', '₹18.6 L', '-1%', true),
          ],
          branchSales: const [
            OwnerBreakdown('Kolhapur', 0.95, '₹0.95 L'),
            OwnerBreakdown('Belgav', 0.58, '₹0.58 L'),
            OwnerBreakdown('Mudaltittha', 0.38, '₹0.38 L'),
            OwnerBreakdown('Examba', 0.24, '₹0.24 L'),
          ],
          categorySales: const [
            OwnerBreakdown('Tiles', 51, '51%'),
            OwnerBreakdown('Granite', 24, '24%'),
            OwnerBreakdown('Sanitaryware', 15, '15%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: const [
            OwnerBreakdown('Surbhi Sikchi', 88, '88%'),
            OwnerBreakdown('Sudarshan Anuse', 82, '82%'),
            OwnerBreakdown('Akshay Kurne', 72, '72%'),
            OwnerBreakdown('Archana Kumbhar', 60, '60%'),
          ],
          topCustomers: const [
            OwnerCustomer('Shree Tiles', '₹65,000'),
            OwnerCustomer('Royal Ceramic', '₹48,000'),
            OwnerCustomer('Balaji Tiles', '₹32,000'),
          ],
          managementAlerts: const [
            OwnerAlert('Custom Range Filtered', 'Displaying metrics for selected historical date range', 'Info'),
          ],
          openOrders: 12,
          activeCustomers: 18,
          enquiries: 24,
          totalSkus: 2481,
          lowStock: 248,
        );

      case DashboardPeriodType.thisMonth:
      default:
        return const OwnerDashboardData(
          periodLabel: 'This month',
          filter: DashboardFilter(
            type: DashboardPeriodType.thisMonth,
            label: 'This month',
          ),
          kpis: [
            OwnerKpi('Total sales', '₹12.4 L', '+8%', true),
            OwnerKpi('Sales growth', '8.0%', '+2.1%', true),
            OwnerKpi('Collections', '₹9.8 L', '+6%', true),
            OwnerKpi('Outstanding', '₹18.6 L', '-3%', true),
          ],
          branchSales: [
            OwnerBreakdown('Kolhapur', 5.8, '₹5.8 L'),
            OwnerBreakdown('Belgav', 3.6, '₹3.6 L'),
            OwnerBreakdown('Mudaltittha', 1.8, '₹1.8 L'),
            OwnerBreakdown('Examba', 1.2, '₹1.2 L'),
          ],
          categorySales: [
            OwnerBreakdown('Tiles', 52, '52%'),
            OwnerBreakdown('Granite', 24, '24%'),
            OwnerBreakdown('Sanitaryware', 14, '14%'),
            OwnerBreakdown('Kadappa', 10, '10%'),
          ],
          salesmanSales: [
            OwnerBreakdown('Surbhi Sikchi', 92, '92%'),
            OwnerBreakdown('Sudarshan Anuse', 84, '84%'),
            OwnerBreakdown('Akshay Kurne', 76, '76%'),
            OwnerBreakdown('Archana Kumbhar', 63, '63%'),
          ],
          topCustomers: [
            OwnerCustomer('Shree Tiles', '₹2.1 L'),
            OwnerCustomer('Royal Ceramic', '₹1.8 L'),
            OwnerCustomer('Balaji Tiles', '₹1.4 L'),
          ],
          managementAlerts: [
            OwnerAlert('Below target salesmen', '3 salesmen are below 75% of target', 'Review'),
            OwnerAlert('High discount exceptions', '5 orders need margin review', 'Review'),
            OwnerAlert('Low stock items', '41 products need replenishment', 'View'),
          ],
          openOrders: 23,
          activeCustomers: 32,
          enquiries: 48,
          totalSkus: 2481,
          lowStock: 248,
        );
    }
  }
}

class OwnerKpi {
  final String label;
  final String value;
  final String change;
  final bool positive;

  const OwnerKpi(this.label, this.value, this.change, this.positive);
}

class OwnerBreakdown {
  final String label;
  final double amount;
  final String displayValue;

  const OwnerBreakdown(this.label, this.amount, this.displayValue);
}

class OwnerCustomer {
  final String name;
  final String value;

  const OwnerCustomer(this.name, this.value);
}

class OwnerAlert {
  final String title;
  final String detail;
  final String action;

  const OwnerAlert(this.title, this.detail, this.action);
}
