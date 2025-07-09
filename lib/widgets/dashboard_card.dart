import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? valueWidget;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    this.value,
    this.valueWidget,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important!
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28), // Slightly smaller icon
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: valueWidget ??
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value ?? '',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
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