import 'package:intl/intl.dart';

class SustainabilityTips {
  static final List<String> entries = [
    // Sustainability tips
    "Recycle your waste to conserve natural resources.",
    "Use reusable bags to reduce plastic waste.",
    "Save energy by turning off lights when not in use.",
    "Consider walking or biking for short trips to reduce carbon emissions.",
    "Plant a tree to help absorb CO2 from the atmosphere.",
    "Conserve water by taking shorter showers and fixing leaks.",
    "Support local produce to reduce transportation emissions.",
    "Use environmentally friendly cleaning products.",
    "Reduce meat consumption to lower your carbon footprint.",
    "Donate items you no longer use instead of throwing them away.",
    // Did you know? facts
    "Did you know that producing a single pair of jeans can use over 10,000 liters of water?",
    "Did you know that recycling aluminum cans saves 95% of the energy required to make the same amount of aluminum from raw materials?",
    "Did you know that livestock farming produces from 20% to 50% of all man-made greenhouse gas emissions?",
    "Did you know that about 8 million tons of plastic are dumped into our oceans every year?",
    "Did you know that turning off the tap while brushing your teeth can save up to 6 liters of water per minute?",
    "Did you know that the fashion industry is the second-largest polluter in the world, just after the oil industry?",
    "Did you know that nearly one-third of all food produced in the world is discarded or wasted?",
    "Did you know that we lose 18 million acres of forest each year, equivalent to 27 soccer fields every minute?",
    "Did you know that renewable energy sources like solar and wind have become the cheapest energy sources in most of the world?",
    "Did you know that only 20% of global e-waste is formally recycled, with the rest typically dumped, traded, or recycled under sub-standard conditions?",
  ];

  static String getDailyTip() {
    var dayOfYear = DateTime.now().dayOfYear();
    return entries[dayOfYear % entries.length];
  }
}

extension DateTimeExtension on DateTime {
  int dayOfYear() {
    final date = DateFormat('y-MM-dd').parse(toString());
    final startOfYear = DateTime(date.year);
    final diff = date.difference(startOfYear);
    return diff.inDays;
  }
}
