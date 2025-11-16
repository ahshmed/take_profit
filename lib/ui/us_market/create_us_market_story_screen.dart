// US Market Story Entry Screen for Recommenders
// Simplified version with only title + description (no entry price, stop loss, etc.)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';

class StoryCard {
  String title;
  String description;

  StoryCard({this.title = '', this.description = ''});
}

class CreateUSMarketStoryScreen extends ConsumerStatefulWidget {
  const CreateUSMarketStoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateUSMarketStoryScreen> createState() => _CreateUSMarketStoryScreenState();
}

class _CreateUSMarketStoryScreenState extends ConsumerState<CreateUSMarketStoryScreen> {
  final List<StoryCard> _storyCards = [StoryCard()]; // Start with one card
  final List<TextEditingController> _titleControllers = [TextEditingController()];
  final List<TextEditingController> _descriptionControllers = [TextEditingController()];
  final List<FocusNode> _titleFocusNodes = [FocusNode()];
  final List<FocusNode> _descriptionFocusNodes = [FocusNode()];

  @override
  void dispose() {
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
      body: Column(
        children: [
          // Story cards list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _storyCards.length,
              itemBuilder: (context, index) {
                return _buildStoryCardForm(index);
              },
            ),
          ),

          // Bottom action buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Constant.clrScaffoldBGByTheme(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Add Card Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addNewCard,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Constant.clrPrimary,
                    ),
                    label: Text(
                      getLocalValue('Key_AddCard'),
                      style: TextStyles.txtMedium14(context).copyWith(
                        color: Constant.clrPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: Constant.clrPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Publish Button
                Expanded(
                  flex: 2,
                  child: CommonButton(
                    label: getLocalValue('Key_Publish'),
                    onTap: _submitStory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCardForm(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Constant.clrPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${getLocalValue('Key_Card')} ${index + 1}',
                  style: TextStyles.txtMedium14(context).copyWith(
                    color: Constant.clrPrimary,
                  ),
                ),
              ),
              const Spacer(),
              if (_storyCards.length > 1)
                IconButton(
                  onPressed: () => _removeCard(index),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20.h,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Title field
          Text(
            getLocalValue('Key_Title'),
            style: TextStyles.txtMedium14(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _titleControllers[index],
            focusNode: _titleFocusNodes[index],
            hintText: getLocalValue('Key_EnterTitle'),
            textInputType: TextInputType.text,
            onChanged: (value) {
              _storyCards[index].title = value;
            },
          ),
          SizedBox(height: 16.h),

          // Description field
          Text(
            getLocalValue('Key_Description'),
            style: TextStyles.txtMedium14(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _descriptionControllers[index],
            focusNode: _descriptionFocusNodes[index],
            hintText: getLocalValue('Key_EnterDescription'),
            textInputType: TextInputType.multiline,
            maxLines: 5,
            onChanged: (value) {
              _storyCards[index].description = value;
            },
          ),
        ],
      ),
    );
  }
}
