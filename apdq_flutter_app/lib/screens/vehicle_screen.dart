import 'package:apdq_flutter_app/blocs/search/search_api_service.dart';
import 'package:apdq_flutter_app/blocs/vehicle/vehicle_bloc.dart';
import 'package:apdq_flutter_app/blocs/vehicle/vehicle_event.dart';
import 'package:apdq_flutter_app/blocs/vehicle/vehicle_state.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/screens/pdf_viewer_screen.dart';
import 'package:apdq_flutter_app/screens/search_screen.dart';
import 'package:apdq_flutter_app/widgets/customBottomNav.dart';
import 'package:apdq_flutter_app/widgets/notificationIcon.dart';
import 'package:flutter/material.dart';
import 'package:apdq_flutter_app/models/vehicle_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleScreen extends StatelessWidget {
  final int year;
  final String brand;
  final String model;

  const VehicleScreen({
    super.key,
    required this.year,
    required this.brand,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    // We use BlocProvider to create and provide the VehicleBloc
    return BlocProvider(
      create: (context) => VehicleBloc(
        vehicleApiService: VehicleApiService(),
      )..add(LoadVehicleDetails(
          year: year,
          brand: brand,
          model: model,
        )),
      child: const VehicleScreenView(),
    );
  }
}

class VehicleScreenView extends StatelessWidget {
  const VehicleScreenView({super.key});

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == VehicleStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == VehicleStatus.error || state.vehicle == null) {
          return const Scaffold(
            body: Center(child: Text('Error loading vehicle details')),
          );
        }

        final vehicle = state.vehicle!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFEBF6F1),
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SearchScreen(),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logorbsmall.png',
                  height: 30,
                ),
              ],
            ),
            actions: const [
              NotificationSystem(),
            ],
          ),
          body: Container(
            color: const Color(0xFFEBF6F1),
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (vehicle.images.isNotEmpty)
                    Image.network(
                      '${EnvConfig.filesBaseUrl}/${vehicle.images.first.filePath}',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildInfoCard(context, vehicle),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const NavigationBarWithNotifications(
            currentIndex: 0,
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, Vehicle vehicle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${vehicle.brand} ${vehicle.model}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 30),
            // Deactivation Time
            if (vehicle.delayTimeDeactivation != null) ...[
              Center(
                child: Text(
                  '${vehicle.delayTimeDeactivation} minutes (estimé)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Center(
                child: Text(
                  'Durée de la procédure de désactivation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            // Neutral Time
            if (vehicle.delayTimeNeutral != null) ...[
              Center(
                child: Text(
                  '${vehicle.delayTimeNeutral} minutes (estimé)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Center(
                child: Text(
                  'Durée de la procédure de mise au neutre',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // PDF Buttons
            if (vehicle.neutralPdfs.isNotEmpty)
              _buildProcedureButton(
                context,
                'Procédure mise au neutre',
                () => _openPdf(context, vehicle.neutralPdfs.first),
              ),

            const SizedBox(height: 12),

            if (vehicle.deactivationPdfs.isNotEmpty)
              _buildProcedureButton(
                context,
                'Procédure désactivation',
                () => _openPdf(context, vehicle.deactivationPdfs.first),
                outlined: true, // Enable outlined gradient border
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureButton(
      BuildContext context, String text, VoidCallback onPressed,
      {bool outlined = false}) {
    return SizedBox(
      width: double.infinity, // Full width
      child: outlined
          ? Container(
              // Use container with decoration for gradient border
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF12BCC1), Color(0xFF5CBA47)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                margin:
                    const EdgeInsets.all(2), // This creates the border width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF12BCC1), Color(0xFF5CBA47)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }

  void _openPdf(BuildContext context, FileBase pdf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          pdfUrl: '${EnvConfig.filesBaseUrl}/${pdf.filePath}',
          title: pdf.fileName,
        ),
      ),
    );
  }
}
