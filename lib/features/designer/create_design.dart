import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateDesignPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const CreateDesignPage({
    super.key,
    required this.order,
  });

  @override
  State<CreateDesignPage> createState() => _CreateDesignPageState();
}

class _CreateDesignPageState extends State<CreateDesignPage> {
  final supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();

  File? imageFile;
  bool sending = false;

  // 🎨 DESIGN CONTROLLERS
  final designTypeCtrl = TextEditingController();
  final widthCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  final materialCtrl = TextEditingController();
  final finishingCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // AUTO FILL FROM ORDER
    designTypeCtrl.text = widget.order['type'] ?? '';
    quantityCtrl.text = "${widget.order['qty'] ?? 1}";
  }

  @override
  void dispose() {
    designTypeCtrl.dispose();
    widthCtrl.dispose();
    heightCtrl.dispose();
    quantityCtrl.dispose();
    materialCtrl.dispose();
    finishingCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // 💾 SAVE DESIGN TO SUPABASE
  Future<void> saveDesign() async {
    final order = widget.order;

    await supabase.from('designs').insert({
      'order_id': order['id'],

      'design_type': designTypeCtrl.text.trim(),
      'width': widthCtrl.text.isEmpty ? null : double.tryParse(widthCtrl.text),
      'height':
      heightCtrl.text.isEmpty ? null : double.tryParse(heightCtrl.text),
      'quantity': int.tryParse(quantityCtrl.text) ?? 1,
      'material': materialCtrl.text.trim(),
      'finishing': finishingCtrl.text.trim(),
      'design_note': noteCtrl.text.trim(),

      // local only (for now)
      'image_path': imageFile?.path,

      'status': 'pending',
    });
  }

  // 📤 SEND TO PRINTER (TELEGRAM TEXT ONLY)
  Future<void> sendToPrinter() async {
    final order = widget.order;

    if (designTypeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter design type")),
      );
      return;
    }

    setState(() => sending = true);

    try {
      // 1. SAVE DESIGN
      await saveDesign();

      // 2. UPDATE ORDER STATUS
      await supabase.from('orders').update({
        'status': 'printing',
        'designed_at': DateTime.now().toIso8601String(),
      }).eq('id', order['id']);

      // 3. TELEGRAM MESSAGE (TEXT ONLY)
      final message = """
🖨 NEW PRINT JOB

👤 Customer: ${order['customer']}
📞 Phone: ${order['phone'] ?? '-'}

🎨 Design Type: ${designTypeCtrl.text}

📏 Size: ${widthCtrl.text.isEmpty ? '-' : widthCtrl.text} x ${heightCtrl.text.isEmpty ? '-' : heightCtrl.text}
📦 Quantity: ${quantityCtrl.text}
🧵 Material: ${materialCtrl.text.isEmpty ? '-' : materialCtrl.text}
✂️ Finishing: ${finishingCtrl.text.isEmpty ? '-' : finishingCtrl.text}

📝 Note:
${noteCtrl.text.isEmpty ? '-' : noteCtrl.text}

⚡ Status: READY FOR PRINT
""";

      await Share.share(message);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sent to Printer 🖨"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inputFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final buttonFontSize = (screenWidth * 0.038).clamp(15.0, 18.0);

    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar with back button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.04,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF1E293B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Title (no logo)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Design',
                      style: TextStyle(
                        fontSize: (screenWidth * 0.06).clamp(20.0, 30.0),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      'Fill design details and send to printer',
                      style: TextStyle(
                        fontSize: (screenWidth * 0.032).clamp(12.0, 15.0),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.06),
                  ],
                ),
              ),
            ),

            // Order info card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xFF3B82F6), size: 28),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['customer'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.04)
                                    .clamp(15.0, 18.0),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "📞 ${order['phone'] ?? '-'}  •  ${order['type'] ?? '-'}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: (screenWidth * 0.032)
                                    .clamp(12.0, 14.0),
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: screenWidth * 0.06),
            ),

            // Design form card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design Details',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Design Type
                      _buildTextField(
                        controller: designTypeCtrl,
                        hint: "Design Type",
                        keyboardType: TextInputType.text,
                        fontSize: inputFontSize,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Width & Height
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: widthCtrl,
                              hint: "Width",
                              keyboardType: TextInputType.number,
                              fontSize: inputFontSize,
                              screenWidth: screenWidth,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: _buildTextField(
                              controller: heightCtrl,
                              hint: "Height",
                              keyboardType: TextInputType.number,
                              fontSize: inputFontSize,
                              screenWidth: screenWidth,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Quantity
                      _buildTextField(
                        controller: quantityCtrl,
                        hint: "Quantity",
                        keyboardType: TextInputType.number,
                        fontSize: inputFontSize,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Material
                      _buildTextField(
                        controller: materialCtrl,
                        hint: "Material",
                        keyboardType: TextInputType.text,
                        fontSize: inputFontSize,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Finishing
                      _buildTextField(
                        controller: finishingCtrl,
                        hint: "Finishing",
                        keyboardType: TextInputType.text,
                        fontSize: inputFontSize,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Notes
                      _buildTextField(
                        controller: noteCtrl,
                        hint: "Notes",
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        fontSize: inputFontSize,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.06),

                      // Image picker
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: screenWidth * 0.5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: imageFile == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: screenWidth * 0.1,
                                  color: const Color(0xFF94A3B8)),
                              SizedBox(height: screenWidth * 0.02),
                              Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  fontSize: inputFontSize,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(imageFile!,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: screenWidth * 0.06),
            ),

            // Send button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.12,
                  child: ElevatedButton(
                    onPressed: sending ? null : sendToPrinter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: sending
                        ? SizedBox(
                      height: screenWidth * 0.06,
                      width: screenWidth * 0.06,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                        : Text(
                      'Send To Printer 🖨',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: screenWidth * 0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required double fontSize,
    required double screenWidth,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }
}