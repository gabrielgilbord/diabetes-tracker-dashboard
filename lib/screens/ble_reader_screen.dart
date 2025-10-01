import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../background_service.dart';
import '../battery_optimization_service.dart';

class BLEReaderScreen extends StatefulWidget {
  const BLEReaderScreen({Key? key}) : super(key: key);

  @override
  State<BLEReaderScreen> createState() => _BLEReaderScreenState();
}

class _BLEReaderScreenState extends State<BLEReaderScreen> {
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> devices = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  BluetoothCharacteristic? muscleCharacteristic;
  BluetoothCharacteristic? polarCharacteristic;
  String log = '';
  bool scanning = false;
  bool isMeasuring = false;
  bool isAutoCollecting = false; // Nueva variable para recogida automática
  int? lastHeartRate;
  bool logExpanded = false;
  String status = 'Desconectado';
  List<int> rriList = [];
  List<String> backgroundLogs = []; // Logs del background service

  // UUIDs
  final String muscleServiceUuid = "d5ad63b5-579c-4da7-ac2c-597ecfaef76e";
  final String muscleCharUuid = "eba11dc1-6fab-479b-a742-1a2dfad8f122";
  final String polarServiceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"; // Nordic UART (Polar H10)
  final String polarCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"; // RX characteristic
  final String hrServiceUuid = "0000180d-0000-1000-8000-00805f9b34fb";
  final String hrCharUuid = "00002a37-0000-1000-8000-00805f9b34fb";

  @override
  void initState() {
    super.initState();
    // Mantener pantalla encendida (modo inmersivo)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Inicializar el servicio de background de manera segura
    try {
      BackgroundService.initializeService();
    } catch (e) {
      print("Error inicializando servicio de fondo: $e");
      // Continuar sin servicio de fondo
    }
    
    // Verificar estado de recogida automática
    _checkAutoCollectionStatus();
    
    // Mostrar diálogo de optimización de batería después de un breve delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        BatteryOptimizationService.showBatteryOptimizationDialog(context);
      });
    });
  }

  @override
  void dispose() {
    // Restaurar modo normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _checkAutoCollectionStatus() async {
    final isCollecting = await BackgroundService.isCollectingData();
    setState(() {
      isAutoCollecting = isCollecting;
    });
  }

  Future<void> _loadBackgroundLogs() async {
    final logs = await BackgroundService.getLogs();
    setState(() {
      backgroundLogs = logs;
    });
  }

  Future<void> solicitarPermisosBluetooth() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Solicitar activar Bluetooth si está apagado
    if (!(await FlutterBluePlus.isOn)) {
      await FlutterBluePlus.turnOn();
    }
  }

  void scanForDevices() async {
    await solicitarPermisosBluetooth();
    setState(() {
      devices.clear();
      scanning = true;
      log = '';
      status = 'Escaneando...';
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        final isMuscle = result.advertisementData.serviceUuids.contains(muscleServiceUuid);
        final isPolar = result.device.name.toLowerCase().contains('polar') ||
            result.advertisementData.serviceUuids.contains(polarServiceUuid);
        if (isMuscle || isPolar) {
          if (!devices.any((d) => d.device.id == result.device.id)) {
            setState(() {
              devices.add(result);
            });
          }
        }
      }
    });
    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() {
      scanning = false;
      status = 'Escaneo finalizado';
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() {
      log = 'Conectando a ${device.name} (ID: ${device.id})...';
      status = 'Conectando...';
      devices.clear();
    });
    await device.connect(autoConnect: false);
    setState(() {
      connectedDevice = device;
      status = 'Conectado';
      log += '\nConectado a ${device.name} (ID: ${device.id})';
    });
    services = await device.discoverServices();
    bool foundPolarChar = false;
    polarCharacteristic = null;
    muscleCharacteristic = null;
    for (var service in services) {
      log += '\nServicio: ${service.uuid}';
      for (var c in service.characteristics) {
        log += '\n  Característica: ${c.uuid}';
        final charUuid = c.uuid.toString().toLowerCase();
        // Característica de músculo
        if (service.uuid.toString() == muscleServiceUuid && charUuid == muscleCharUuid) {
          muscleCharacteristic = c;
          log += '  <- Característica de músculo';
        }
        // Característica de frecuencia cardíaca (UUID largo o corto)
        if (charUuid == hrCharUuid || charUuid.endsWith('2a37')) {
          polarCharacteristic = c;
          foundPolarChar = true;
          log += '  <- Característica de frecuencia cardíaca';
        }
      }
    }
    setState(() {});
    if (!foundPolarChar) {
      setState(() {
        log += '\nNo se encontró característica de medición de frecuencia cardíaca.';
      });
    }
  }

  Future<void> startOnlineMeasurement() async {
    if (muscleCharacteristic != null) {
      await muscleCharacteristic!.write([0x23, 0x23, 0x31, 0x0D]);
      setState(() {
        isMeasuring = true;
        log += '\nMedición muscular iniciada.';
        status = 'Midiendo (músculo)';
      });
      muscleCharacteristic!.setNotifyValue(true);
      muscleCharacteristic!.value.listen((data) {
        setState(() {
          log += '\nDatos musculares: $data';
        });
      });
    } else if (polarCharacteristic != null) {
      setState(() {
        isMeasuring = true;
        log += '\nIniciando medición de frecuencia cardíaca de Polar H10...';
        status = 'Midiendo (Polar H10)';
        rriList.clear();
      });
      await polarCharacteristic!.setNotifyValue(true);
      polarCharacteristic!.value.listen((data) {
        if (data.isNotEmpty) {
          int flags = data[0];
          int offset = 1;
          int hr;
          if ((flags & 0x01) == 0) {
            hr = data[offset];
            offset += 1;
          } else {
            hr = (data[offset + 1] << 8) | data[offset];
            offset += 2;
          }
          List<int> newRri = [];
          while (offset + 1 < data.length) {
            int rri = (data[offset] | (data[offset + 1] << 8));
            newRri.add(rri);
            offset += 2;
          }
          setState(() {
            lastHeartRate = hr;
            log += '\nFrecuencia cardíaca: $hr bpm (Polar H10)';
            if (newRri.isNotEmpty) {
              rriList.addAll(newRri);
              log += '\nRRi: ${newRri.join(', ')}';
            }
          });
        } else {
          setState(() {
            log += '\nDatos Polar H10: $data';
          });
        }
      });
      setState(() {
        log += '\nLeyendo frecuencia cardíaca de Polar H10.';
      });
    } else {
      setState(() {
        log += '\nNo se encontró característica de medición.';
        status = 'Error: sin característica de medición';
      });
    }
  }

  Future<void> stopOnlineMeasurement() async {
    if (muscleCharacteristic != null) {
      await muscleCharacteristic!.write([0x23, 0x23, 0x30, 0x0D]);
      setState(() {
        isMeasuring = false;
        log += '\nMedición muscular detenida.';
        status = 'Conectado';
      });
    } else if (polarCharacteristic != null) {
      await polarCharacteristic!.setNotifyValue(false);
      setState(() {
        isMeasuring = false;
        log += '\nLectura de Polar H10 detenida.';
        status = 'Conectado';
      });
    }
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        log += '\nDesconectado de ${connectedDevice!.name} (ID: ${connectedDevice!.id})';
        connectedDevice = null;
        muscleCharacteristic = null;
        polarCharacteristic = null;
        isMeasuring = false;
        lastHeartRate = null;
        status = 'Desconectado';
      });
    }
  }

  // Métodos para recogida automática de datos
  Future<void> startAutoDataCollection() async {
    if (connectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero conecta un dispositivo Polar H10')),
      );
      return;
    }

    // Verificar que sea un dispositivo Polar H10
    if (!connectedDevice!.name.toLowerCase().contains('polar') && 
        !connectedDevice!.name.toLowerCase().contains('h10')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se admite recogida automática con dispositivos Polar H10')),
      );
      return;
    }

    try {
      await BackgroundService.startDataCollection();
      setState(() {
        isAutoCollecting = true;
        log += '\nRecogida automática de datos del Polar H10 iniciada';
        status = 'Recogiendo datos del Polar H10 automáticamente';
      });
      
      // Cargar logs del background service
      await _loadBackgroundLogs();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recogida automática iniciada. Los datos del Polar H10 se subirán a la nube cada 30 segundos.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error iniciando recogida automática: $e')),
      );
    }
  }

  Future<void> stopAutoDataCollection() async {
    try {
      await BackgroundService.stopDataCollection();
      setState(() {
        isAutoCollecting = false;
        log += '\nRecogida automática de datos del Polar H10 detenida';
        status = connectedDevice != null ? 'Conectado' : 'Desconectado';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recogida automática del Polar H10 detenida'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deteniendo recogida automática: $e')),
      );
    }
  }

  Future<void> syncPendingData() async {
    try {
      setState(() {
        log += '\nSincronizando datos pendientes del Polar H10...';
      });
      
      await BackgroundService.syncPendingData();
      
      setState(() {
        log += '\nSincronización completada';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos pendientes del Polar H10 sincronizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sincronizando datos: $e')),
      );
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'Escaneando...':
        return Colors.orange;
      case 'Conectando...':
        return Colors.blueGrey;
      case 'Conectado':
        return Colors.green;
      case 'Midiendo (músculo)':
      case 'Midiendo (Polar H10)':
        return Colors.redAccent;
      case 'Recogiendo datos del Polar H10 automáticamente':
        return Colors.purple;
      case 'Error: sin característica de medición':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectura BLE'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // margen inferior para la barra de acciones
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado visual
                Row(
                  children: [
                    Icon(Icons.circle, color: getStatusColor(), size: 16),
                    const SizedBox(width: 8),
                    Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: getStatusColor())),
                  ],
                ),
                const SizedBox(height: 8),
                // Encabezado de dispositivo conectado
                if (connectedDevice != null)
                  Card(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth_connected, color: Color(0xFF0039AE), size: 36),
                      title: Text(connectedDevice!.name.isNotEmpty ? connectedDevice!.name : connectedDevice!.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${connectedDevice!.id}'),
                      trailing: isMeasuring
                          ? const Icon(Icons.favorite, color: Colors.red, size: 32)
                          : const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    ),
                  ),
                if (lastHeartRate != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 48),
                          Text(
                            '$lastHeartRate bpm',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Lista de dispositivos encontrados
                if (devices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text('Dispositivos encontrados:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                if (devices.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = devices[i];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.bluetooth, color: Color(0xFF0039AE), size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.device.name.isNotEmpty ? d.device.name : d.device.id.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      d.device.id.toString(),
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                child: const Text('Conectar'),
                                onPressed: connectedDevice == null ? () => connectToDevice(d.device) : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                // Panel colapsable para el log
                Card(
                  elevation: 1,
                  child: ExpansionPanelList(
                    elevation: 0,
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        logExpanded = !logExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        isExpanded: logExpanded,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) => ListTile(
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.list_alt, color: Color(0xFF0039AE)),
                          ),
                          title: const Text('Log de conexión y servicios'),
                          trailing: IconButton(
                            icon: Icon(Icons.refresh, color: Color(0xFF0039AE)),
                            onPressed: _loadBackgroundLogs,
                            tooltip: 'Refrescar logs del background service',
                          ),
                        ),
                        body: Container(
                          color: theme.colorScheme.background.withOpacity(0.95),
                          height: 200,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (log.isNotEmpty) ...[
                                    Text(
                                      '📱 Log de conexión:',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0039AE),
                                      ),
                                    ),
                                    Text(log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                    SizedBox(height: 8),
                                  ],
                                  if (backgroundLogs.isNotEmpty) ...[
                                    Text(
                                      '🔄 Log del Background Service:',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    ...backgroundLogs.map((logEntry) => Text(
                                      logEntry,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                    )).toList(),
                                  ] else ...[
                                    Text(
                                      'No hay logs del background service aún. Pulsa "Comenzar Auto" para iniciar.',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Barra de acciones fija abajo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              bottom: true,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bluetooth_searching),
                            label: Text(scanning ? 'Escaneando...' : 'Escanear'),
                            onPressed: scanning ? null : scanForDevices,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0039AE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (connectedDevice != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(isMeasuring ? Icons.stop : Icons.play_arrow),
                              label: Text(isMeasuring ? 'Detener' : 'Medir'),
                              onPressed: isMeasuring ? stopOnlineMeasurement : startOnlineMeasurement,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMeasuring ? Colors.red : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (connectedDevice != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.link_off),
                          label: const Text('Desconectar'),
                          onPressed: disconnectFromDevice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                    // Controles de recogida automática
                    if (connectedDevice != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(isAutoCollecting ? Icons.stop : Icons.cloud_upload),
                              label: Text(isAutoCollecting ? 'Parar Auto' : 'Comenzar Auto'),
                              onPressed: isAutoCollecting ? stopAutoDataCollection : startAutoDataCollection,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAutoCollecting ? Colors.red : Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.sync),
                              label: const Text('Sincronizar'),
                              onPressed: syncPendingData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Ayuda: Optimización de Batería'),
                          onPressed: () => BatteryOptimizationService.showOptimizationReminder(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 