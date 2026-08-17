import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/inspection_sync_status.dart';
import '../bloc/inspection_form_bloc.dart';
import '../bloc/inspection_form_event.dart';
import '../bloc/inspection_form_state.dart';
import '../../../work_orders/domain/entities/work_order.dart';

class InspectionFormPage extends StatefulWidget {
  final InspectionFormBloc bloc;
  final WorkOrder workOrder;

  const InspectionFormPage({
    super.key,
    required this.bloc,
    required this.workOrder,
  });

  @override
  State<InspectionFormPage> createState() => _InspectionFormPageState();
}

class _InspectionFormPageState extends State<InspectionFormPage> {
  final ImagePicker _imagePicker = ImagePicker();

  InspectionFormBloc get bloc => widget.bloc;

  // ============================================================
  // FOTO
  // ============================================================

  Future<void> _capturePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );

      if (image == null || !mounted) {
        return;
      }

      bloc.add(InspectionPhotoChanged(image.path));
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError('Não foi possível capturar a foto.');
    }
  }

  // ============================================================
  // LOCALIZAÇÃO
  // ============================================================

  Future<void> _captureLocation() async {
    // Impede múltiplas solicitações simultâneas.
    if (bloc.state.isGettingLocation) {
      return;
    }

    bloc.add(const InspectionLocationLoadingStarted());

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        bloc.add(const InspectionLocationLoadingFinished());

        if (!mounted) {
          return;
        }

        _showError('Ative o serviço de localização do dispositivo.');

        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        bloc.add(const InspectionLocationLoadingFinished());

        if (!mounted) {
          return;
        }

        _showError('Permissão de localização negada.');

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        bloc.add(const InspectionLocationLoadingFinished());

        if (!mounted) {
          return;
        }

        _showError(
          'Permissão de localização bloqueada. '
          'Ative-a nas configurações do dispositivo.',
        );

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Calcula a distância entre o técnico e o local da OS.
      final distance = Geolocator.distanceBetween(
        widget.workOrder.latitude,
        widget.workOrder.longitude,
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      // Salva a localização capturada.
      bloc.add(
        InspectionLocationChanged(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      // Finaliza o loading.
      bloc.add(const InspectionLocationLoadingFinished());

      // Verifica o geofence de 200 metros.
      if (distance > 200) {
        _showWarning(
          'Você está a ${distance.round()} m do local da OS. '
          'A distância recomendada é de até 200 m.',
        );
      } else {
        _showSuccess(
          'Localização capturada. '
          'Você está a ${distance.round()} m do local da OS.',
        );
      }
    } catch (error) {
      bloc.add(const InspectionLocationLoadingFinished());

      if (!mounted) {
        return;
      }

      _showError('Não foi possível obter a localização.');
    }
  }
  // ============================================================
  // MENSAGENS
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showWarning(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
      );
  }

  void _showSuccess(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
  // ============================================================
  // AÇÕES
  // ============================================================

  void _saveDraft() {
    bloc.add(const SaveInspectionDraft());
  }

  void _completeInspection() {
    bloc.add(const CompleteInspection());
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocListener<InspectionFormBloc, InspectionFormState>(
        listener: (context, state) {
          if (state.status == InspectionFormStatus.error) {
            _showError(
              state.errorMessage ?? 'Não foi possível salvar a inspeção.',
            );
          }

          if (state.status == InspectionFormStatus.success) {
            final message = state.syncStatus == InspectionSyncStatus.draft
                ? 'Rascunho salvo localmente.'
                : 'Inspeção concluída e aguardando sincronização.';

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));

            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Nova inspeção')),
          body: BlocBuilder<InspectionFormBloc, InspectionFormState>(
            builder: (context, state) {
              final isSaving = state.status == InspectionFormStatus.saving;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildObservationField(),

                      const SizedBox(height: 24),

                      _buildConditionField(state),

                      const SizedBox(height: 24),

                      _buildPhotoSection(state),

                      const SizedBox(height: 24),

                      _buildLocationSection(state),

                      const SizedBox(height: 32),

                      _buildActions(isSaving),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OBSERVAÇÃO
  // ============================================================

  Widget _buildObservationField() {
    return TextFormField(
      minLines: 5,
      maxLines: 8,
      textInputAction: TextInputAction.newline,
      decoration: const InputDecoration(
        labelText: 'Observação',
        hintText: 'Descreva o que foi observado durante a inspeção.',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        bloc.add(InspectionObservationChanged(value));
      },
    );
  }

  // ============================================================
  // CONDIÇÃO
  // ============================================================

  Widget _buildConditionField(InspectionFormState state) {
    return DropdownButtonFormField<String>(
      initialValue: state.condition,
      decoration: const InputDecoration(
        labelText: 'Condição do ativo',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'bom', child: Text('Bom')),
        DropdownMenuItem(value: 'regular', child: Text('Regular')),
        DropdownMenuItem(value: 'ruim', child: Text('Ruim')),
        DropdownMenuItem(value: 'crítico', child: Text('Crítico')),
      ],
      onChanged: (value) {
        bloc.add(InspectionConditionChanged(value));
      },
    );
  }

  // ============================================================
  // FOTO
  // ============================================================

  Widget _buildPhotoSection(InspectionFormState state) {
    final photoPath = state.photoPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidência fotográfica',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        if (photoPath == null)
          _buildPhotoPlaceholder()
        else
          _buildPhotoPreview(photoPath),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _capturePhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              photoPath == null ? 'Adicionar foto' : 'Tirar outra foto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined, size: 48),
          SizedBox(height: 8),
          Text('Nenhuma foto adicionada'),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(String photoPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(photoPath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Não foi possível visualizar a foto.'),
          );
        },
      ),
    );
  }

  // ============================================================
  // LOCALIZAÇÃO
  // ============================================================

  Widget _buildLocationSection(InspectionFormState state) {
    final hasLocation = state.latitude != null && state.longitude != null;

    final isGettingLocation = state.isGettingLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasLocation
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude: '
                      '${state.latitude!.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longitude: '
                      '${state.longitude!.toStringAsFixed(6)}',
                    ),
                  ],
                )
              : const Text('Localização ainda não capturada.'),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isGettingLocation ? null : _captureLocation,
            icon: isGettingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.location_on_outlined),
            label: Text(
              isGettingLocation
                  ? 'Obtendo localização...'
                  : hasLocation
                  ? 'Atualizar localização'
                  : 'Capturar localização',
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AÇÕES FINAIS
  // ============================================================

  Widget _buildActions(bool isSaving) {
    if (isSaving) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: _saveDraft,
          child: const Text('Salvar rascunho'),
        ),

        const SizedBox(height: 12),

        FilledButton(
          onPressed: _completeInspection,
          child: const Text('Concluir inspeção'),
        ),
      ],
    );
  }
}
