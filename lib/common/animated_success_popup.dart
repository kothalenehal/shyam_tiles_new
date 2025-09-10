import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedSuccessPopup extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AnimatedSuccessPopup({
    Key? key,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<AnimatedSuccessPopup> createState() => _AnimatedSuccessPopupState();
}

class _AnimatedSuccessPopupState extends State<AnimatedSuccessPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _checkmarkController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation controller - faster and smoother
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Fade animation controller - slightly longer for smoother fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Checkmark animation controller - faster drawing
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Bounce animation controller - smoother bounce
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Pulse animation controller for subtle breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Scale animation - smoother elastic curve
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));
    
    // Fade animation - smoother fade
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    // Checkmark animation - smoother drawing
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeOutQuart,
    ));
    
    // Bounce animation - gentler bounce
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // Pulse animation for subtle breathing effect
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start all animations simultaneously for smoother experience
    _fadeController.forward();
    _scaleController.forward();
    
    // Slight delay for checkmark to start after scale begins
    await Future.delayed(const Duration(milliseconds: 150));
    _checkmarkController.forward();
    
    // Bounce animation starts after checkmark begins
    await Future.delayed(const Duration(milliseconds: 200));
    _bounceController.forward();
    
    // Start pulse animation after bounce
    await Future.delayed(const Duration(milliseconds: 300));
    _pulseController.repeat(reverse: true);
    
    // Auto dismiss after 2.5 seconds for better user experience
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    // Reverse animations with slight stagger for smoother exit
    _fadeController.reverse();
    
    // Slight delay before scale reverse for smoother transition
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.reverse();
    
    // Wait for animations to complete before dismissing
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted && widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _checkmarkController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _checkmarkAnimation,
        _bounceAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  width: 280,
                  height: 200,
                                     decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(20),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.15),
                         blurRadius: 25,
                         offset: const Offset(0, 8),
                         spreadRadius: 2,
                       ),
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.08),
                         blurRadius: 40,
                         offset: const Offset(0, 16),
                         spreadRadius: 4,
                       ),
                     ],
                   ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                                             // Success icon with animation
                       Transform.scale(
                         scale: _bounceAnimation.value * _pulseAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                                                     decoration: BoxDecoration(
                             color: const Color(0xFF4CAF50),
                             shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(
                                 color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                                 blurRadius: 15,
                                 offset: const Offset(0, 6),
                                 spreadRadius: 1,
                               ),
                               BoxShadow(
                                 color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                                 blurRadius: 25,
                                 offset: const Offset(0, 12),
                                 spreadRadius: 2,
                               ),
                             ],
                           ),
                          child: AnimatedBuilder(
                            animation: _checkmarkController,
                            builder: (context, child) {
                                                           return Transform.rotate(
                               angle: _checkmarkAnimation.value * 0.1, // Subtle rotation
                               child: CustomPaint(
                                 painter: CheckmarkPainter(
                                   progress: _checkmarkAnimation.value,
                                   color: Colors.white,
                                 ),
                                 size: const Size(60, 60),
                               ),
                             );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Success message
                      Text(
                        'Success!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Product message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw smoother checkmark with better proportions
    path.moveTo(size.width * 0.22, size.height * 0.52);
    path.lineTo(size.width * 0.42, size.height * 0.72);
    path.lineTo(size.width * 0.78, size.height * 0.28);

    // Animate the checkmark drawing with smoother interpolation
    final animatedPath = Path();
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;
    final animatedLength = pathLength * progress;

    if (animatedLength > 0) {
      final extractPath = pathMetrics.extractPath(0, animatedLength);
      animatedPath.addPath(extractPath, Offset.zero);
    }

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// Helper function to show the animated success popup
void showAnimatedSuccessPopup(
  BuildContext context,
  String message, {
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AnimatedSuccessPopup(
        message: message,
        onDismiss: () {
          Navigator.of(context).pop();
          if (onDismiss != null) {
            onDismiss();
          }
        },
      );
    },
  );
}
