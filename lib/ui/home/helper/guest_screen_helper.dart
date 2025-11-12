import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../framework/data_provider/drawer/drawer_provider.dart';
import '../../../utils/const.dart';


class GuestHelperScreen extends ConsumerStatefulWidget {
  Function(bool val)? callBack;

  GuestHelperScreen({Key? key,  this.callBack}) : super(key: key);

  @override
  ConsumerState<GuestHelperScreen> createState() => _GuestHelperScreenState();
}

class _GuestHelperScreenState extends ConsumerState<GuestHelperScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getStartedDialog(context,callBack: widget.callBack);
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawerWatch = ref.watch(drawerProvider);
    return Container();
  }

}
