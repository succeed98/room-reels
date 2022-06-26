// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_is_empty, sized_box_for_whitespace, override_on_non_overriding_member, use_build_context_synchronously

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../core/models/property_model.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/providers/location_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../utils/constants.dart';
import '../../utils/dialog.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_radio_grouped_button.dart';
import '../components/h_button.dart';
import '../components/h_text_area.dart';
import '../components/h_text_form_field.dart';

// add property providers
final titleProvider = StateProvider<String>((ref) => '');
final priceProvider = StateProvider<String>((ref) => '');
final locationProvider = StateProvider<TextEditingController>((ref) {
  final locationAddress = ref.watch(locationAddressProvider);

  return locationAddress.maybeWhen(
    data: (place) => place == null
        ? TextEditingController(text: '')
        : TextEditingController(text: place),
    error: (error, stack) {
      print(error);
      print(error);
      return TextEditingController(text: '');
    },
    orElse: () => TextEditingController(text: ''),
  );
});
final descriptionProvider = StateProvider<String>((ref) => '');
final kitchensProvider = StateProvider<TextEditingController>(
    (ref) => TextEditingController(text: '0'));
final bathroomsProvider = StateProvider<TextEditingController>(
    (ref) => TextEditingController(text: '0'));
final bedroomsProvider = StateProvider<TextEditingController>(
    (ref) => TextEditingController(text: '0'));
final statusProvider = StateProvider<String>((ref) => 'Buy');
final typeProvider = StateProvider<String>((ref) => 'Apartment');

class AddPropertyScreenNotifier extends ChangeNotifier {
  bool _isHideAddDetails = false;
  bool _isHideUploadPics = true;
  bool _isHideComplete = true;

  bool get isHideAddDetailsScreen => _isHideAddDetails;
  bool get isHideUploadPicsScreen => _isHideUploadPics;
  bool get isHideCompleteScreen => _isHideComplete;

  void showAddDetailsScreen() {
    _isHideAddDetails = false;
    _isHideUploadPics = true;
    _isHideComplete = true;
    notifyListeners();
  }

  void showUploadPicsScreen() {
    _isHideAddDetails = true;
    _isHideUploadPics = false;
    _isHideComplete = true;
    notifyListeners();
  }

  void showCompleteScreen() {
    _isHideAddDetails = true;
    _isHideUploadPics = true;
    _isHideComplete = false;
    notifyListeners();
  }
}

final addPropertyScreenNotifierProvider =
    ChangeNotifierProvider.autoDispose((ref) => AddPropertyScreenNotifier());

class AddPropertyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final addPropertyScreenNofitier = watch(addPropertyScreenNotifierProvider);
    final propertyType = watch(typeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text('Add Property', style: F_24_MEDIUM),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // add property details
            Offstage(
              offstage: addPropertyScreenNofitier.isHideAddDetailsScreen,
              child: _propertyDetailsForm(context, propertyType),
            ),
            // uploading pics
            Offstage(
              offstage: addPropertyScreenNofitier.isHideUploadPicsScreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        addPropertyScreenNofitier.showAddDetailsScreen(),
                    child: Icon(Icons.arrow_back,
                        color: Theme.of(context).primaryColor, size: 30),
                  ),
                  PropertyPicPicker(),
                ],
              ),
            )
            // complete process
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownList(List pItems) {
    List<DropdownMenuItem<String>> items = [];

    for (String item in pItems) {
      items.add(DropdownMenuItem(value: item, child: Text(item)));
    }

    return items;
  }

  _propertyDetailsForm(BuildContext context, StateController propertyType) {
    final addPropertyScreenNofitier =
        context.read(addPropertyScreenNotifierProvider);
    final title = context.read(titleProvider);
    final price = context.read(priceProvider);
    final location = context.read(locationProvider);
    final description = context.read(descriptionProvider);

    final kitchens = context.read(kitchensProvider);
    final bathrooms = context.read(bathroomsProvider);
    final bedrooms = context.read(bedroomsProvider);

    List<String> propertyTypes = ['Apartment', 'House'];
    List<DropdownMenuItem<String>> propertyTypesDropdownList =
        _buildDropdownList(propertyTypes);

    return Form(
      child: Column(
        children: [
          HTextFormField(
            onChanged: (value) => title.state = value,
            iconData: Icons.title,
            hintText: 'title',
          ),
          SizedBox(height: 20),
          HTextFormField(
            onChanged: (value) => price.state = value,
            iconData: Icons.money,
            hintText: 'price(GHc)/month',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: location.state,
            iconData: Icons.location_on,
            hintText: 'location',
          ),
          SizedBox(height: 20),
          HTextArea(
            onChanged: (value) => description.state = value,
            text: 'description',
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: kitchens.state,
            iconData: Icons.kitchen,
            hintText: 'kitchens',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: bathrooms.state,
            iconData: Icons.bathroom,
            hintText: 'bathrooms',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: bedrooms.state,
            iconData: Icons.bedroom_parent,
            hintText: 'bedrooms',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          Row(children: [Text('Status')]),
          SizedBox(height: 5),
          Consumer(builder: (context, watch, child) {
            final status = watch(statusProvider);

            return CustomRadioGroupedButton(
              value: status.state,
              options: ["Buy", "Rent"],
              onChanged: (String value) {
                status.state = value;
              },
            );
          }),
          SizedBox(height: 20),
          Row(children: [Text('Property type')]),
          SizedBox(height: 5),
          CustomDropdown(
            dropdownMenuItemList: propertyTypesDropdownList,
            onChanged: (value) {
              updateProviderState(
                context,
                value: value.toString(),
                provider: typeProvider,
              );
            },
            value: propertyType.state.toString(),
          ),
          SizedBox(height: 30),
          HButton(
            width: 150,
            text: 'Proceed',
            onPressed: () {
              // validate user input
              if (title.state.isEmpty ||
                  price.state.isEmpty ||
                  location.state.text.isEmpty ||
                  description.state.isEmpty) {
                showToast(context,
                    message: 'Kindly input details before you proceed.');
                return;
              }
              addPropertyScreenNofitier.showUploadPicsScreen();
            },
          ),
        ],
      ),
    );
  }
}

enum PropertyStatus { BUY, RENT }

class AssetsPickerTextDelegateImpl implements AssetPickerTextDelegate {
  factory AssetsPickerTextDelegateImpl() => _instance;

  AssetsPickerTextDelegateImpl._internal();

  static final AssetsPickerTextDelegateImpl _instance =
      AssetsPickerTextDelegateImpl._internal();

  AssetPickerTextDelegate assetPickerTextDelegate = AssetPickerTextDelegate();
  @override
  String confirm = 'Confirm';

  @override
  String cancel = 'Cancel';

  @override
  String edit = 'Edit';

  @override
  String gifIndicator = 'GIF';

  @override
  String heicNotSupported = 'HEIC Not supported';

  @override
  String loadFailed = 'Load failed';

  @override
  String original = 'Original';

  @override
  String preview = 'Preview';

  @override
  String select = 'Select';

  @override
  String unSupportedAssetType = 'Unsupported asset type';
  
  @override
  String get accessAllTip => 'You have set the app to only access some resources on the device';
  
  @override
  String get accessLimitedAssets => 'Continue to access some resources';
  
  @override
  String get accessiblePathName => 'accessible resources';
  
  @override
  String get changeAccessibleLimitedAssets => 'click to set accessible resources';
  
  
  
  @override
  String get emptyList => 'list is empty';
  
  @override
  String get goToSystemSettings => 'go to system settings';
  
  @override
  String get languageCode => 'en';
  
  @override
  String get sActionPlayHint => 'play';
  
  @override
  String get sActionPreviewHint => 'preview';
  
  @override
  String get sActionSelectHint => "checked";
  
  @override
  String get sActionSwitchPathLabel => 'switch path';
  
  @override
  String get sActionUseCameraHint => 'use the camera';
  
  @override
  String get sNameDurationLabel => 'duration';
  
  @override
  String get sTypeAudioLabel => 'audio';
  
  @override
  String get sTypeImageLabel => "picture";
  
  @override
  String get sTypeOtherLabel => 'other resources';
  
  @override
  String get sTypeVideoLabel => 'video';
  
  @override
  String get sUnitAssetCountLabel => 'quantity';
  
  @override
  String semanticTypeLabel(AssetType type) {
    return assetPickerTextDelegate.semanticTypeLabel(type);
  }
  
  @override
  AssetPickerTextDelegate get semanticsTextDelegate => this;
  
  @override
  String get unableToAccessAll => 'Unable to access all assets in album';
  
  @override
  String get viewingLimitedAssetsTip => 'App can only access some resources and albums';
  
  @override
  String durationIndicatorBuilder(Duration duration) {
    return assetPickerTextDelegate.durationIndicatorBuilder(duration);
  }

}

class CameraPickerTextDelegateImpl implements CameraPickerTextDelegate {
  factory CameraPickerTextDelegateImpl() => _instance;

  CameraPickerTextDelegateImpl._internal();

  static final CameraPickerTextDelegateImpl _instance =
      CameraPickerTextDelegateImpl._internal();

  @override
  String confirm = 'Confirm';

  @override
  String shootingTips = 'Shooting tips';

  @override
  String loadFailed = 'Load failed';
  
  @override
  String get languageCode => 'en';
  
  @override
  String get sActionManuallyFocusHint => 'Manual focus';
  
  @override
  String get sActionPreviewHint => 'preview';
  
  @override
  String get sActionRecordHint => 'video';
  
  @override
  String get sActionShootHint => 'photograph';
  
  @override
  String get sActionShootingButtonTooltip => 'photo button';
  
  @override
  String get sActionStopRecordingHint => 'stop recording';
  
  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    return _instance.sCameraLensDirectionLabel(value);
  }
  
  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    return _instance.sCameraPreviewLabel(value);
  }
  
  @override
  String sFlashModeLabel(FlashMode mode) {
    return _instance.sFlashModeLabel(mode);
  }
  
  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    return _instance.sSwitchCameraLensDirectionLabel(value);
  }
  
  @override
  String get shootingOnlyRecordingTips => 'long press camera';
  
  @override
  String get shootingTapRecordingTips => 'tap camera';
  
  @override
  String get shootingWithRecordingTips => 'tap to take photo, long press to record';
}

class PropertyPicPicker extends ConsumerWidget {
  const PropertyPicPicker({Key? key}) : super(key: key);

  Future<List<AssetEntity>> selectAssetsFromCamera(BuildContext context,
      {required List<AssetEntity> assets, required int maxAssetsCount}) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxAssetsCount,
      selectedAssets: assets,
      requestType: RequestType.common,
      textDelegate: AssetsPickerTextDelegateImpl(),
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (BuildContext context, entity, f) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final AssetEntity? result = await CameraPicker.pickFromCamera(
              context,
              pickerConfig: CameraPickerConfig(
                textDelegate: CameraPickerTextDelegateImpl()
              ),
            );
            if (result != null) {
              assets.add(result);
            }
          },
          child: const Center(
            child: Icon(Icons.camera_enhance, size: 42.0),
          ),
        );
      },
      )
    );

    if (result != null) {
      assets = List<AssetEntity>.from(result);
    }

    return assets;
  }

  Future<List<AssetEntity>> selectAssetsFromGallery(BuildContext context,
      {required List<AssetEntity> assets, required int maxAssetsCount}) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxAssetsCount,
        selectedAssets: assets,
        requestType: RequestType.image,
        textDelegate: AssetsPickerTextDelegateImpl()
        ));

    if (result != null) {
      assets = List<AssetEntity>.from(result);
    }

    return assets;
  }

  _buildSelectedAssetsListView(List<AssetEntity> assets) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: assets.length,
      itemBuilder: (BuildContext _, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _selectedAssetWidget(assets[index])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _selectedAssetWidget(AssetEntity asset) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image(
          image: AssetEntityImageProvider(asset, isOriginal: false),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final propertyDp = watch(propertyDpProvider);
    final propertyPics = watch(propertyPicsProvider);
    final storage = watch(storageProvider);
    final firebaseAuth = watch(firebaseAuthProvider);
    final title = context.read(titleProvider);
    final price = context.read(priceProvider);
    final location = context.read(locationProvider);
    final description = context.read(descriptionProvider);
    final type = context.read(typeProvider);
    final status = context.read(statusProvider);
    final kitchens = context.read(kitchensProvider);
    final bathrooms = context.read(bathroomsProvider);
    final bedrooms = context.read(bedroomsProvider);
    final propertyDataSource = context.read(propertyDataSourceProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upload display picture'),
            IconButton(
              onPressed: () async {
                showCustomDialog(
                  context,
                  titleBuilder: (context, controller, setState) => SizedBox(),
                  messageBuilder: (context, controller, setState) => Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          controller.dismiss();
                          propertyDp.state = await selectAssetsFromCamera(
                            context,
                            assets: propertyDp.state,
                            maxAssetsCount: 1,
                          );
                        },
                        child: Text('Camera', style: F_18_PRIMARY_COLOR),
                      ),
                      TextButton(
                        onPressed: () async {
                          controller.dismiss();
                          propertyDp.state = await selectAssetsFromGallery(
                            context,
                            assets: propertyDp.state,
                            maxAssetsCount: 1,
                          );
                        },
                        child: Text('Gallery', style: F_18_PRIMARY_COLOR),
                      )
                    ],
                  ),
                  negativeAction: (context, controller, setState) => SizedBox(),
                  positiveAction: (context, controller, setState) => SizedBox(),
                );
              },
              icon: Icon(
                propertyDp.state.length == 0 ? Icons.add : Icons.edit,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          ],
        ),
        propertyDp.state.length == 0
            ? buildEmptyImageContainer()
            : Container(
                height: 100,
                child: _buildSelectedAssetsListView(propertyDp.state),
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upload featured pictures'),
            IconButton(
              onPressed: () async {
                showCustomDialog(
                  context,
                  titleBuilder: (context, controller, setState) => SizedBox(),
                  messageBuilder: (context, controller, setState) => Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          controller.dismiss();
                          propertyPics.state = await selectAssetsFromCamera(
                            context,
                            assets: propertyPics.state,
                            maxAssetsCount: 5,
                          );
                        },
                        child: Text('Camera', style: F_18_PRIMARY_COLOR),
                      ),
                      TextButton(
                        onPressed: () async {
                          controller.dismiss();
                          propertyPics.state = await selectAssetsFromGallery(
                            context,
                            assets: propertyPics.state,
                            maxAssetsCount: 5,
                          );
                        },
                        child: Text('Gallery', style: F_18_PRIMARY_COLOR),
                      )
                    ],
                  ),
                  negativeAction: (context, controller, setState) => SizedBox(),
                  positiveAction: (context, controller, setState) => SizedBox(),
                );
              },
              icon: Icon(
                propertyPics.state.length == 0 ? Icons.add : Icons.edit,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          ],
        ),
        propertyPics.state.length == 0
            ? buildEmptyImageContainer()
            : Container(
                height: 100,
                child: _buildSelectedAssetsListView(propertyPics.state),
              ),
        SizedBox(height: 30),
        HButton(
          width: 150,
          text: 'Submit',
          onPressed: () async {
            final completer = Completer();
            // show loading
            showBlockDialog(
              context,
              dismissCompleter: completer,
            );
            // check if property display picture is available
            if (propertyDp.state.length == 0) {
              showToast(context,
                  message: 'Kindly select property display image');
              // dismiss loading
              completer.complete();
              return;
            }
            // check if property pics are selected
            if (propertyPics.state.length == 0) {
              showToast(context, message: 'Kindly select at least one image');
              // dismiss loading
              completer.complete();
              return;
            }
            // get display pic path
            String displayPicPath =
                await getAssetAbsolutePath(propertyDp.state.first);
            // get featured pics path
            List<String> featuredPics = [];
            for (var entity in propertyPics.state) {
              var entityPath = await getAssetAbsolutePath(entity);
              featuredPics.add(entityPath);
            }

            // get firebase storage paths
            displayPicPath = await storage.uploadFile(
                bucket: 'properties/${firebaseAuth.currentUser!.uid}',
                filePath: displayPicPath);
            // featured pics path
            List<String> featuredPicsPath = [];
            for (var picPath in featuredPics) {
              var uploadPath = await storage.uploadFile(
                  bucket: 'properties/${firebaseAuth.currentUser!.uid}',
                  filePath: picPath);

              featuredPicsPath.add(uploadPath);
            }

            final userDeviceToken = await FirebaseMessaging.instance.getToken();

            final priceAsDouble = double.tryParse(price.state);
            if (priceAsDouble == null) {
              showToast(context, message: 'Price must be a number');
              return;
            }

            PropertyModel propertyModel = PropertyModel(
              uid: firebaseAuth.currentUser!.uid,
              title: title.state,
              price: priceAsDouble,
              location: location.state.text,
              description: description.state,
              status: status.state,
              type: type.state,
              displayPic: displayPicPath,
              featuredPics: featuredPicsPath,
              bathrooms: bathrooms.state.text,
              bedrooms: bedrooms.state.text,
              kitchens: kitchens.state.text,
              userDeviceToken: userDeviceToken,
            );

            await propertyDataSource.addProperty(propertyModel).then((value) {
              completer.complete();
              showCustomDialog(context,
                  messageBuilder: (context, controller, setState) =>
                      Text('Property added.'),
                  negativeAction: (context, controller, setState) => SizedBox(),
                  positiveAction: (context, controller, setState) => TextButton(
                        child: Text('OKAY'),
                        onPressed: () {
                          controller.dismiss();
                        },
                      ),
                  titleBuilder: (context, controller, setState) =>
                      Text('Success'));
            });

            //  reset providers
            context.refresh(propertyDpProvider);
            context.refresh(propertyPicsProvider);
            context.refresh(titleProvider);
            context.refresh(priceProvider);
            context.refresh(locationProvider);
            context.refresh(descriptionProvider);
            context.refresh(typeProvider);
            context.refresh(statusProvider);
          },
        ),
      ],
    );
  }

  Future<String> getAssetAbsolutePath(AssetEntity entity) async {
    final file = await entity.originFile;
    return file!.absolute.path;
  }

  Container buildEmptyImageContainer() {
    return Container(
      height: 100,
      width: 100,
      color: Color(0xFFEAF0EF),
    );
  }
}
