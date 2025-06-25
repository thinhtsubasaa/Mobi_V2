import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/pages/MMS_QuanLyPT_TB/quanlyphuongtien/baoduong.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../../models/mms/adsun.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/custom_card.dart';

class QuanLyPhuongTienPage extends StatefulWidget {
  final String? id;
  const QuanLyPhuongTienPage({super.key, required this.id});

  @override
  State<QuanLyPhuongTienPage> createState() => _QuanLyPhuongTienPage();
}

class _QuanLyPhuongTienPage extends State<QuanLyPhuongTienPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();
  TabController? _tabController;
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
  VehicleInfo? _adsun;
  VehicleInfo? get adsun => _adsun;
  VehicleInfo? _data;
  @override
  void initState() {
    super.initState();
    // _init();
    _tabController = TabController(vsync: this, length: 5);
    _tabController!.addListener(_handleTabChange);
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    _onScan();
  }

  _onScan() {
    setState(() {
      _loading = true;
    });
    getAdsun(widget.id).then((_) {
      setState(() {
        _loading = false;
        if (adsun?.toaDo == null) {
          // QuickAlert.show(
          //   // ignore: use_build_context_synchronously
          //   context: context,
          //   type: QuickAlertType.info,
          //   title: '',
          //   text: 'Không có dữ liệu',
          //   confirmBtnText: 'Đồng ý',
          // );

          _moveToPosition(LatLng(0, 0));
        } else {
          _moveToPosition(convertToLatLng(_adsun?.toaDo ?? ""));
          _data = adsun;
          print("angel:${_data?.angle}");
        }
      });
    });
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
          print("dataAdsun:${decodedData}");
          _adsun = VehicleInfo(
              plate: decodedData['plate'],
              toaDo: decodedData['toaDo'],
              km: decodedData['km'],
              groupName: decodedData['groupName'],
              speed: decodedData['speed'],
              address: decodedData['address'],
              angle: decodedData['angle'],
              loaiPT: decodedData['loaiPT'],
              model: decodedData['model'],
              model_Option: decodedData['model_Option'],
              ngayBaoDuong: decodedData['ngayBaoDuong'],
              soKM_Adsun: decodedData['soKM_Adsun'],
              taiXePhuTrach: decodedData['taiXePhuTrach']);

          setState(() {
            _isLoading = false;
          });
          // Kiểm tra nếu không có tọa độ
          // if (toaDo == null || toaDo!.isEmpty) {
          //   _moveToPosition(LatLng(0, 0));
          // } else {
          //   _moveToPosition(convertToLatLng(toaDo ?? ""));
          // }
        }
      } else {
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

  // _addMarker(LatLng latLng) {
  //   final Marker marker = Marker(
  //     markerId: MarkerId('current_position'),
  //     position: latLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //   );
  //   if (mounted) {
  //     setState(() {
  //       _markers.add(marker);
  //     });
  //   }
  // }
  Future<void> _addMarker(LatLng latLng) async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // Kích thước ảnh
      'assets/images/car4.png', // Đường dẫn ảnh trong assets
    );

    final Marker marker = Marker(
      markerId: const MarkerId('current_position'),
      position: latLng,
      icon: customIcon,
      rotation: double.parse(_data?.angle ?? '0'),
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
        Positioned(
          top: 20, // Khoảng cách từ trên xuống
          left: 10, // Khoảng cách từ trái sang
          child: _data != null
              ? Container(
                  padding: const EdgeInsets.all(10),
                  width: 250, // Độ rộng bảng
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🚗 Biển số: ${_data?.plate ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("📍 LoạiPT: ${_data?.loaiPT ?? 'N/A'}"),
                      Text("📍 Model: ${_data?.model ?? 'N/A'}"),
                      Text("📍 Model_Option: ${_data?.model_Option ?? 'N/A'}"),
                      Text("📍 Tổng số KM: ${_data?.soKM_Adsun ?? 'N/A'}"),
                      Text("📍 Tài xế: ${_data?.taiXePhuTrach ?? 'N/A'}"),
                      Text("📍 Ngày bảo dưỡng gần nhất: ${_data?.ngayBaoDuong ?? 'N/A'}"),
                      Text("📍 Tọa độ: ${_data?.toaDo ?? 'N/A'}"),
                      Text("⛽ Km/ngày: ${_data?.km ?? 'N/A'}"),
                      Text("💨 Tốc độ: ${_data?.speed ?? 'N/A'} km/h"),
                      // Text("🏢 Nhóm: ${_data?.groupName ?? 'N/A'}"),
                      const SizedBox(height: 5),
                      const Text("📍 Địa chỉ:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_data?.address ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              : const SizedBox(), // Nếu không có dữ liệu thì ẩn bảng
        ),
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
        throw const FormatException('Invalid coordinate format');
      }
    } catch (e) {
      throw FormatException('Error parsing coordinates: $e');
    }
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      // Call the action when the tab changes
      // print('Tab changed to: ${_tabController!.index}');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              CustomCard(),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 13.h : 8.h),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      Container(
                        width: 90.w,
                        height: 45.h,
                        child: _buildBody(),
                      ),
                      CustomBodyBaoDuong(id: widget.id),
                      CustomBodyBaoDuong(id: widget.id),
                      CustomBodyBaoDuong(id: widget.id),
                      CustomBodyBaoDuong(id: widget.id),
                      CustomBodyBaoDuong(id: widget.id),
                    ],
                  ),
                ),
              ),
              // BottomContent(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  // const CustomCard(),
                  TabBar(
                    labelStyle: TextStyle(fontSize: 11), // Kích thước chữ khi được chọn
                    unselectedLabelStyle: TextStyle(fontSize: 9),
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.map), text: 'Info'),
                      Tab(icon: Icon(Icons.build), text: 'Bảo dưỡng'),
                      Tab(icon: Icon(Icons.settings), text: 'Sửa chữa'),
                      Tab(icon: Icon(Icons.assignment_turned_in), text: 'Đăng kiểm'),
                      Tab(icon: Icon(Icons.security), text: 'Bảo hiểm'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'LỊCH SỬ XE NHẬP CHUYỂN BÃI',
        ),
      ),
    );
  }
}
