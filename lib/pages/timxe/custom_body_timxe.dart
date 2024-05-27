import 'dart:async';
import 'package:Thilogi/blocs/timxe.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/timxe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';

class CustomBodyTimXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyTimXeScreen());
  }
}

class BodyTimXeScreen extends StatefulWidget {
  const BodyTimXeScreen({Key? key}) : super(key: key);

  @override
  _BodyTimXeScreenState createState() => _BodyTimXeScreenState();
}

class _BodyTimXeScreenState extends State<BodyTimXeScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  TimXeModel? _data;
  late TimXeBloc _bl;
  String barcodeScanResult = '';

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _init();
    _bl = Provider.of<TimXeBloc>(context, listen: false);
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult);
    });
  }

  @override
  void dispose() {
    scanSubscription.cancel();
    _qrDataController.dispose();
    super.dispose();
  }

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  _init() async {
    _loading = true;
    _location = Location();
    _currentLocation = await _location?.getLocation();
    LatLng initialPosition;
    if (_currentLocation != null) {
      initialPosition = LatLng(
        _currentLocation?.latitude ?? 0,
        _currentLocation?.longitude ?? 0,
      );

      _cameraPosition = CameraPosition(
        target: initialPosition,
        zoom: 15,
      );
      _loading = false;
      _moveToPosition(_cameraPosition!.target);
      _addMarker(_cameraPosition!.target);
    }
    // _initLocation();
    // Thêm marker cho vị trí ban đầu
  }

  _moveToPosition(LatLng latLng) async {
    _cameraPosition = CameraPosition(
      target: latLng,
      zoom: 15,
    );
    _updateMarkerPosition(latLng);
  }

  _addMarker(LatLng latLng) {
    final Marker marker = Marker(
      markerId: MarkerId('current_position'),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }
  }

  _updateMarkerPosition(LatLng latLng) {
    if (mounted) {
      setState(() {
        _markers.clear();
        _addMarker(latLng);
      });
    }
  }

  Widget _buildMapToggle() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: _toggleMapType,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.red,
          child: const Icon(Icons.map),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          },
          markers: _markers,
        ),
        _buildMapToggle(),
      ],
    );
  }

  LatLng convertToLatLng(String coordinates) {
    try {
      final parts = coordinates.split(',');
      if (parts.length == 2) {
        final latitude = double.parse(parts[0]);
        final longitude = double.parse(parts[1]);
        print(LatLng(latitude, longitude));
        return LatLng(latitude, longitude);
      } else {
        throw FormatException('Invalid coordinate format');
      }
    } catch (e) {
      throw FormatException('Error parsing coordinates: $e');
    }
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 11.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 11.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
              child: Text(
                'Số khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
                _qrDataController.text = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print("abc: ${barcodeScanResult}");
    setState(() {
      _qrData = '';
      _qrDataController.text = '';
      _data = null;
      Future.delayed(const Duration(seconds: 0), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.timxe == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.timxe;
        if (_data?.toaDo == null) {
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.info,
            title: '',
            text: 'Xe chưa có vị trí tọa độ trên bản đồ',
            confirmBtnText: 'Đồng ý',
          );
          _moveToPosition(LatLng(0, 0));
        }
        _moveToPosition(convertToLatLng(_data?.toaDo ?? ""));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CardVin(),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _loading
                        ? LoadingWidget(context)
                        : Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thông Tin Tìm Kiếm',
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFA71C20)),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Item(
                                        title: 'Kho Xe:',
                                        value: _data?.tenKho,
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Bãi Xe:',
                                        value: _data?.tenBaiXe,
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Vị Trí xe:',
                                        value: _data?.tenViTri,
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Tọa độ:',
                                        value: _data?.toaDo,
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Container(
                                        width: 90.w,
                                        height: 45.h,
                                        child: _buildBody(),
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                    ],
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
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Text(
              value ?? "",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
