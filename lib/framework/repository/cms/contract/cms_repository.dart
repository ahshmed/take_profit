

import 'package:flutter/material.dart';

abstract class CmsRepository{

  ///CMS PAGE Api
  Future cmsPageAPI(BuildContext context, Map<String, dynamic> request);
}