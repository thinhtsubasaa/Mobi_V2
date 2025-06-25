import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import '../../../services/request_helper_mms.dart';

class CustomBodyMap extends StatelessWidget {
  final String? id;
  CustomBodyMap({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyMapScreen(
      id: id,
    ));
  }
}

class BodyMapScreen extends StatefulWidget {
  final String? id;
  const BodyMapScreen({super.key, required this.id});

  @override
  _BodyMapScreenState createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  MapType _currentMapType = MapType.normal;
  bool _loading = false;
  String? toaDo;

  @override
  void initState() {
    super.initState();
    _init();
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    getAdsun(widget.id ?? "");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAdsun(
    String? id,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_QuanLyPhuongTien/Adsun?Id=$id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          // Gán giá trị tọa độ cho _tinhtrang
          toaDo = "${decodedData}";
          print("toadoPT555:$toaDo");

          setState(() {
            _isLoading = false;
          });
          // Kiểm tra nếu không có tọa độ
          if (toaDo == null || toaDo!.isEmpty) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.info,
              title: '',
              text: 'Phương tiện chưa có vị trí tọa độ trên bản đồ',
              confirmBtnText: 'Đồng ý',
            );
            _moveToPosition(LatLng(0, 0));
          } else {
            _moveToPosition(convertToLatLng(toaDo ?? ""));
          }
        }
      } else {
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
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

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else {
        _currentMapType = MapType.normal;
      }
    });
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
    if (_cameraPosition == null) {
      return Center(child: CircularProgressIndicator()); // Hiển thị loading nếu chưa có vị trí
    }
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 90.w,
                              height: 90.h,
                              child: _buildBody(),
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
      ),
    );
  }
}
