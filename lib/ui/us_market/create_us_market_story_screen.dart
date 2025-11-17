// US Market Story Entry Screen for Recommenders
// Modern redesign with rich text editor support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../framework/repository/stock/model/stock_model.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';

class StoryCard {
  String title;
  String description;
  List<File> images; // Support for multiple images

  StoryCard({this.title = '', this.description = '', List<File>? images})
      : images = images ?? [];
}

class CreateUSMarketStoryScreen extends ConsumerStatefulWidget {
  final StockModel selectedStock;

  const CreateUSMarketStoryScreen({
    Key? key,
    required this.selectedStock,
  }) : super(key: key);

  @override
  ConsumerState<CreateUSMarketStoryScreen> createState() =>
      _CreateUSMarketStoryScreenState();
}

class _CreateUSMarketStoryScreenState
    extends ConsumerState<CreateUSMarketStoryScreen>
    with SingleTickerProviderStateMixin {
  final List<StoryCard> _storyCards = [StoryCard()];
  final List<TextEditingController> _titleControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _descriptionControllers = [
    TextEditingController()
  ];
  final List<FocusNode> _titleFocusNodes = [FocusNode()];
  final List<FocusNode> _descriptionFocusNodes = [FocusNode()];
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _titleControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var node in _titleFocusNodes) {
      node.dispose();
    }
    for (var node in _descriptionFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addNewCard() {
    setState(() {
      _storyCards.add(StoryCard());
      _titleControllers.add(TextEditingController());
      _descriptionControllers.add(TextEditingController());
      _titleFocusNodes.add(FocusNode());
      _descriptionFocusNodes.add(FocusNode());
    });
  }

  void _removeCard(int index) {
    if (_storyCards.length > 1) {
      setState(() {
        _titleControllers[index].dispose();
        _descriptionControllers[index].dispose();
        _titleFocusNodes[index].dispose();
        _descriptionFocusNodes[index].dispose();

        _storyCards.removeAt(index);
        _titleControllers.removeAt(index);
        _descriptionControllers.removeAt(index);
        _titleFocusNodes.removeAt(index);
        _descriptionFocusNodes.removeAt(index);
      });
    }
  }

  Future<void> _pickImage(int cardIndex) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _storyCards[cardIndex].images.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalValue('Key_ErrorPickingImage')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int cardIndex, int imageIndex) {
    setState(() {
      _storyCards[cardIndex].images.removeAt(imageIndex);
    });
  }

  void _submitStory() {
    // TODO: Validate and submit to backend
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getLocalValue('Key_FeatureComingSoon')),
        backgroundColor: Constant.clrPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        backgroundColor: Constant.clrScaffoldBGByTheme(context),
        title: getLocalValue('Key_CreateUSMarketStory'),
        appBar: AppBar(),
        isTitleCenter: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Modern Stock Header Card
            _buildModernStockHeader(),

            // Story cards list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                itemCount: _storyCards.length,
                itemBuilder: (context, index) {
                  return _buildModernStoryCardForm(index);
                },
              ),
            ),

            // Modern Bottom Action Bar
            _buildModernActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStockHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Constant.clrPrimary.withValues(alpha: 0.15),
            Constant.clrPrimary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Constant.clrPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Constant.clrPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Modern Stock Icon
          Container(
            width: 60.h,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constant.clrPrimary,
                  Constant.clrPrimary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Constant.clrPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.selectedStock.ticker.length >= 2
                    ? widget.selectedStock.ticker.substring(0, 2)
                    : widget.selectedStock.ticker,
                style: TextStyles.txtBold18(context).copyWith(
                  color: Constant.clrWhite,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedStock.ticker,
                  style: TextStyles.txtBold18(context).copyWith(
                    color: Constant.clrPrimary,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.selectedStock.companyName,
                  style: TextStyles.txtMedium14(context).copyWith(
                    color: Constant.clrSigDetByTheme(context),
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.selectedStock.price,
                style: TextStyles.txtBold18(context).copyWith(
                  color: Constant.clrSigDetByTheme(context),
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.selectedStock.isPositiveChange
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.selectedStock.changePercent,
                  style: TextStyles.txtMedium12(context).copyWith(
                    color: widget.selectedStock.isPositiveChange
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStoryCardForm(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Card Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constant.clrPrimary.withValues(alpha: 0.1),
                  Constant.clrPrimary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Constant.clrPrimary,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Constant.clrPrimary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Constant.clrWhite,
                        size: 18.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${getLocalValue('Key_Card')} ${index + 1}',
                        style: TextStyles.txtSemiBold14(context).copyWith(
                          color: Constant.clrWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_storyCards.length > 1)
                  InkWell(
                    onTap: () => _removeCard(index),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 22.h,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Row(
                  children: [
                    Icon(
                      Icons.title_rounded,
                      color: Constant.clrPrimary,
                      size: 20.h,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      getLocalValue('Key_Title'),
                      style: TextStyles.txtSemiBold16(context).copyWith(
                        color: Constant.clrTitlePageByTheme(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  context: context,
                  myController: _titleControllers[index],
                  myFocus: _titleFocusNodes[index],
                  hintText: getLocalValue('Key_EnterTitle'),
                  textInputType: TextInputType.text,
                  onChanged: (value) {
                    _storyCards[index].title = value;
                  },
                ),
                SizedBox(height: 24.h),

                // Description Section with Rich Text Editor
                Row(
                  children: [
                    Icon(
                      Icons.text_fields_rounded,
                      color: Constant.clrPrimary,
                      size: 20.h,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      getLocalValue('Key_Description'),
                      style: TextStyles.txtSemiBold16(context).copyWith(
                        color: Constant.clrTitlePageByTheme(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Rich Text Editor Container
                // TODO: Replace with flutter_quill or html_editor_enhanced
                Container(
                  decoration: BoxDecoration(
                    color: Constant.clrScaffoldBGByTheme(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Constant.clrPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Toolbar for rich text formatting
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Constant.clrPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildToolbarButton(Icons.format_bold, () {}),
                            _buildToolbarButton(Icons.format_italic, () {}),
                            _buildToolbarButton(Icons.format_underlined, () {}),
                            _buildToolbarButton(Icons.format_list_bulleted, () {}),
                            _buildToolbarButton(
                                Icons.image_outlined, () => _pickImage(index)),
                            const Spacer(),
                            Text(
                              'Rich Text Editor',
                              style: TextStyles.txtMedium12(context).copyWith(
                                color: Constant.clrPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Text Editor Area
                      CustomTextField(
                        context: context,
                        myController: _descriptionControllers[index],
                        myFocus: _descriptionFocusNodes[index],
                        hintText: getLocalValue('Key_EnterDescription'),
                        textInputType: TextInputType.multiline,
                        maxLine: 8,
                        onChanged: (value) {
                          _storyCards[index].description = value;
                        },
                      ),
                    ],
                  ),
                ),

                // Images Preview
                if (_storyCards[index].images.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        color: Constant.clrPrimary,
                        size: 20.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        getLocalValue('Key_AttachedImages'),
                        style: TextStyles.txtSemiBold16(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 100.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _storyCards[index].images.length,
                      itemBuilder: (context, imageIndex) {
                        return Container(
                          margin: EdgeInsets.only(right: 12.w),
                          width: 100.h,
                          height: 100.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  _storyCards[index].images[imageIndex],
                                  width: 100.h,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index, imageIndex),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Constant.clrWhite,
                                      size: 16.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        margin: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: Constant.clrHomeCardByTheme(context),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: Constant.clrPrimary,
          size: 20.h,
        ),
      ),
    );
  }

  Widget _buildModernActionBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Add Card Button
            Expanded(
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Constant.clrPrimary.withValues(alpha: 0.1),
                      Constant.clrPrimary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Constant.clrPrimary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addNewCard,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Constant.clrPrimary,
                          size: 24.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          getLocalValue('Key_AddCard'),
                          style: TextStyles.txtSemiBold16(context).copyWith(
                            color: Constant.clrPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Publish Button
            Expanded(
              flex: 2,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Constant.clrPrimary,
                      Constant.clrPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Constant.clrPrimary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitStory,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.publish_rounded,
                          color: Constant.clrWhite,
                          size: 24.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          getLocalValue('Key_Publish'),
                          style: TextStyles.txtBold18(context).copyWith(
                            color: Constant.clrWhite,
                          ),
                        ),
                      ],
                    ),
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
