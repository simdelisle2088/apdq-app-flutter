import 'package:apdq_flutter_app/blocs/login/login_bloc.dart';
import 'package:apdq_flutter_app/blocs/search/search_bloc.dart';
import 'package:apdq_flutter_app/blocs/search/search_event.dart';
import 'package:apdq_flutter_app/blocs/search/search_state.dart';
import 'package:apdq_flutter_app/screens/vehicle_screen.dart';
import 'package:apdq_flutter_app/widgets/customBottomNav.dart';
import 'package:apdq_flutter_app/widgets/notificationIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    print('SearchScreen initialized');

    // Force a fresh load of data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleSearchBloc>().add(LoadInitialDataEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleSearchBloc, VehicleSearchState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEBF6F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEBF6F1),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const LogoutConfirmationDialog(),
              ),
            ),
          ),
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/Logorbsmall.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: const [
            NotificationSystem(), // Use NotificationSystem instead of NotificationIconWithBadge directly
          ],
        ),
        body: BlocBuilder<VehicleSearchBloc, VehicleSearchState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Recherche par véhicule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Year dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: state.selectedYear,
                      hint: const Text('Année'),
                      isExpanded:
                          true, // Add this to ensure proper dropdown expansion
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: state.availableYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: state.availableYears.isEmpty
                          ? null
                          : (year) {
                              if (year != null) {
                                context
                                    .read<VehicleSearchBloc>()
                                    .add(YearSelectedEvent(year));
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Brand dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: state.selectedBrand,
                      decoration: const InputDecoration(
                        hintText: 'Marque',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: state.availableBrands.map((brand) {
                        return DropdownMenuItem(
                          value: brand,
                          child: Text(brand),
                        );
                      }).toList(),
                      onChanged: state.selectedYear == null
                          ? null
                          : (brand) {
                              if (brand != null) {
                                context
                                    .read<VehicleSearchBloc>()
                                    .add(BrandSelectedEvent(brand));
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Model dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: state.selectedModel,
                      decoration: const InputDecoration(
                        hintText: 'Modèle',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: state.availableModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: state.selectedBrand == null
                          ? null
                          : (model) {
                              if (model != null) {
                                context
                                    .read<VehicleSearchBloc>()
                                    .add(ModelSelectedEvent(model));
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search button
                  if (state.isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF12BCC1), Color(0xFF5CBA47)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: state.selectedModel == null
                              ? null
                              : () async {
                                  // Dispatch the event to search for vehicle details
                                  context.read<VehicleSearchBloc>().add(
                                        SearchVehicleDetailsEvent(
                                          year: state.selectedYear!,
                                          brand: state.selectedBrand!,
                                          model: state.selectedModel!,
                                        ),
                                      );

                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  // Wait for the state to change
                                  await for (final newState in context
                                      .read<VehicleSearchBloc>()
                                      .stream) {
                                    // Remove loading indicator
                                    Navigator.pop(context);

                                    if (newState.selectedVehicle != null) {
                                      // Navigate to vehicle details screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VehicleScreen(
                                            year: newState.selectedVehicle!
                                                .yearFrom, // Use yearFrom as the reference year
                                            brand:
                                                newState.selectedVehicle!.brand,
                                            model:
                                                newState.selectedVehicle!.model,
                                          ),
                                        ),
                                      );
                                      break;
                                    } else if (newState.error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(newState.error!),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      break;
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Rechercher',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (state.vehicles != null && state.vehicles!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Véhicules trouvés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.vehicles!.length,
                        itemBuilder: (context, index) {
                          final vehicle = state.vehicles![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('${vehicle.brand} ${vehicle.model}'),
                              subtitle: Text(
                                  '${vehicle.yearFrom} - ${vehicle.yearTo ?? "Present"}'),
                              onTap: () {
                                // Navigate to vehicle details
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const NavigationBarWithNotifications(
          currentIndex: 0,
        ),
      ),
    );
  }
}

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Déconnexion'),
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () => _handleLogout(context),
          child: const Text(
            'Déconnecter',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final loginBloc = context.read<LoginBloc>();
      await loginBloc.logout(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la déconnexion. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
