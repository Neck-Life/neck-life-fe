import 'package:flutter_airpods/models/device_motion_data.dart';

import 'Filter.dart';

class Filters extends Filter {

  List<Filter> filters = [];


  @override
  DeviceMotionData? operation(DeviceMotionData data) {
    for (Filter filter in filters) {
      data = filter.operation(data)!;
    }
    return data;
  }

  void addFilter(Filter filter) {
    filters.add(filter);
  }


}