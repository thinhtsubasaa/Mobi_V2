import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/services/request_helper.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../../models/mms/adsun.dart';
import '../../../services/request_helper_mms.dart';
import '../PageNew/pagenew.dart';
import '../mms_yeucaunhapkm/custom_body_nhapkm.dart';
import '../quanlyphuongtien/baoduong.dart';
import '../quanlyphuongtien/ganmooc_thietbi.dart';
import '../quanlyphuongtien/suachua.dart';

class QuanLyPhuongTienCaNhanNewPage extends StatefulWidget {
  final String? id;
  final int tabIndex;
  const QuanLyPhuongTienCaNhanNewPage({super.key, required this.id, this.tabIndex = 0});

  @override
  State<QuanLyPhuongTienCaNhanNewPage> createState() => _QuanLyPhuongTienCaNhanNewPage();
}

class _QuanLyPhuongTienCaNhanNewPage extends State<QuanLyPhuongTienCaNhanNewPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();
  static RequestHelper requestHelper_old = RequestHelper();
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
  late bool hasAdminRole = false;
  @override
  void initState() {
    super.initState();
    // getDataRole(context);
    // _init();
    _tabController = TabController(vsync: this, length: 7, initialIndex: widget.tabIndex);
    _tabController!.addListener(_handleTabChange);
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    _onScan();
  }

  _onScan() async {
    setState(() {
      _loading = true;
    });
    await getAdsun(widget.id).then((_) {
      setState(() {
        if (adsun?.toaDo == null) {
          // QuickAlert.show(
          //   // ignore: use_build_context_synchronously
          //   context: context,
          //   type: QuickAlertType.info,
          //   title: '',
          //   text: 'Không có dữ liệu',
          //   confirmBtnText: 'Đồng ý',
          // );
          _loading = false;
          _moveToPosition(LatLng(0, 0));
        } else {
          _loading = false;
          _moveToPosition(convertToLatLng(_adsun?.toaDo ?? ""));
          _data = adsun;
          print("angel:${_data?.angle}");
          print("Danh sách ảnh: ${_data?.hinhAnh_TaiXe}");
        }
      });
    });
  }

  Future<void> getDataRole(BuildContext context) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper_old.getData('Role/RoleById');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("Role:${decodedData}");

        if (decodedData is List) {
          // Kiểm tra xem danh sách có phải List<String> không
          bool isStringList = decodedData.every((item) => item is String);

          if (isStringList) {
            List<String> roleList = List<String>.from(decodedData);
            hasAdminRole = roleList.contains("ADMINISTRATOR_MMS");
            if (hasAdminRole) {
              print("Người dùng có quyền Administrator");
            } else {
              print("Người dùng không có quyền Administrator");
            }
          } else {
            throw Exception("Dữ liệu API không đúng định dạng List<String>");
          }
        } else {
          throw Exception("Dữ liệu API không phải là List");
        }

        notifyListeners();
      } else {
        _isLoading = false;
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getAdsun(
    String? id,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_QuanLyPhuongTien/Adsun?Id=$id');
      ;
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
            taiXePhuTrach: decodedData['taiXePhuTrach'],
            hinhAnh_TaiXe: decodedData['hinhAnh_TaiXe'],
            maNhanVien: decodedData['maNhanVien'],
            soKM: decodedData['soKM'],
            soKMTuNgayBaoDuong: decodedData['soKMTuNgayBaoDuong'],
            soKM_NgayBaoDuong: decodedData['soKM_NgayBaoDuong'],
          );

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
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        // openSnackBar(context, errorMessage);
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
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

  Future<void> _addMarker(LatLng latLng) async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // Kích thước ảnh
      'assets/images/BaiXe_Truck_new.png', // Đường dẫn ảnh trong assets
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

  void _showFullImageDialog(List<String> imageUrls, List<String> employeeCodes) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          child: Container(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.3,
            child: Column(
              children: [
                const Text("Danh sách ảnh", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: GridView.builder(
                    itemCount: imageUrls.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Hiển thị 2 ảnh trên mỗi hàng
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1, // Cân bằng giữa ảnh và mã nhân viên
                    ),
                    itemBuilder: (context, index) {
                      String imageUrl = imageUrls[index];
                      String employeeCode = (index < employeeCodes.length) ? employeeCodes[index] : "N/A";

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showSingleImageDialog(imageUrl);
                            },
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 128, // Giới hạn chiều cao ảnh
                            ),
                          ),
                          Text(
                            "MSNV: $employeeCode",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSingleImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(imageUrl, fit: BoxFit.contain),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Đóng"),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  width: 307, // Độ rộng bảng
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
                      Text(
                        "🚗 Biển số: ${_data?.plate ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("📍 LoạiPT: ${_data?.loaiPT ?? ''}", style: TextStyle(fontSize: 13)),
                      Text("📍 Model: ${_data?.model ?? ''}", style: TextStyle(fontSize: 13)),
                      Text("📍 Option: ${_data?.model_Option ?? ''}", style: TextStyle(fontSize: 13)),
                      // Text("📍 Chỉ số Km:  ${_data?.soKM_Adsun ?? 'N/A'} / ${_data?.soKM_Adsun ?? 'N/A'}", style: TextStyle(fontSize: 13)),
                      Row(
                        children: [
                          Text(
                            "📍 Chỉ số Km: ${_data?.soKM_NgayBaoDuong ?? ''} / ${_data?.soKM_Adsun ?? ''}",
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(width: 5), // Khoảng cách giữa text và icon
                          Icon(Icons.car_rental, size: 16, color: Colors.blue), // Icon nhỏ
                        ],
                      ),
                      Text("📍 Số Km hiện tại so với ngày bảo dưỡng: ${_data?.soKMTuNgayBaoDuong ?? ''}", style: TextStyle(fontSize: 12)),

                      GestureDetector(
                        onTap: () {
                          if (_data?.hinhAnh_TaiXe != null && _data!.hinhAnh_TaiXe!.isNotEmpty && _data?.maNhanVien != null) {
                            List<String> imageUrls = _data!.hinhAnh_TaiXe!.split(',');
                            List<String> manhanvien = _data!.maNhanVien!.split(',');
                            _showFullImageDialog(imageUrls, manhanvien);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📍 Phụ trách:",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...(_data?.taiXePhuTrach ?? '')
                                .split(',')
                                .map((name) => Text(
                                      name.trim(), // Loại bỏ khoảng trắng dư thừa nếu có
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(), // Nếu không có dữ liệu thì ẩn bảng
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child: _data != null
              ? Container(
                  padding: const EdgeInsets.all(10),
                  width: 250,
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
                      Text("⛽ Km/ngày: ${_data?.km ?? ''}"),
                      Text("💨 Tốc độ: ${_data?.speed ?? ''} km/h"),
                      const SizedBox(height: 5),
                      const Text("📍 Địa chỉ:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_data?.address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              : const SizedBox(),
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
              // CustomCard(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 13.h : 8.h),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      CustomBodyNhapKM(id: widget.id),
                      Container(
                        width: 90.w,
                        height: 45.h,
                        child: _buildBody(),
                      ),
                      CustomBodyGanMoocTB(id: widget.id),
                      CustomBodyBaoDuong(id: widget.id),
                      CustomBodySuaChua(id: widget.id),
                      PageNew(),
                      PageNew(),
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
                    unselectedLabelStyle: TextStyle(fontSize: 8),
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.build), text: 'Yêu cầu hằng ngày'),
                      Tab(icon: Icon(Icons.map), text: 'Info'),
                      Tab(icon: Icon(Icons.link), text: 'Ghép nối'),
                      Tab(icon: Icon(Icons.build), text: 'Bảo dưỡng'),
                      Tab(icon: Icon(Icons.construction), text: 'Sửa chữa'),
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
