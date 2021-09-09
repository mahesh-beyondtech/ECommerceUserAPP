import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/product_repo.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  ProductProvider({@required this.productRepo});

  // Latest products
  List<Product> _latestProductList = [];
  bool _isLoading = false;
  bool _firstLoading = true;
  int _latestPageSize;
  List<String> _offsetList = [];

  List<Product> get latestProductList => _latestProductList;
  bool get isLoading => _isLoading;
  bool get firstLoading => _firstLoading;
  int get latestPageSize => _latestPageSize;

  Future<void> getLatestProductList(String offset, BuildContext context, String languageCode, {bool reload = false}) async {
    if(reload) {
      _offsetList = [];
      _latestProductList = [];
    }
    if(!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ApiResponse apiResponse = await productRepo.getLatestProductList(offset, languageCode);
      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
        _latestProductList.addAll(ProductModel.fromJson(apiResponse.response.data).products);
        _latestPageSize = ProductModel.fromJson(apiResponse.response.data).totalSize;
        _firstLoading = false;
        _isLoading = false;
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }
      notifyListeners();
    }else {
      if(_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<int> getLatestOffset(String languageCode) async {
    ApiResponse apiResponse = await productRepo.getLatestProductList('1', languageCode);
    return ProductModel.fromJson(apiResponse.response.data).totalSize;
  }

  void showBottomLoader() {
    _isLoading = true;
    notifyListeners();
  }

  void removeFirstLoading() {
    _firstLoading = true;
    notifyListeners();
  }

  // Seller products
  List<Product> _sellerAllProductList = [];
  List<Product> _sellerProductList = [];
  int _sellerPageSize;
  List<Product> get sellerProductList => _sellerProductList;
  int get sellerPageSize => _sellerPageSize;

  void initSellerProductList(String sellerId, String offset, BuildContext context, String languageCode) async {
    ApiResponse apiResponse = await productRepo.getSellerProductList(sellerId, offset, languageCode);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _sellerProductList.addAll(ProductModel.fromJson(apiResponse.response.data).products);
      _sellerAllProductList.addAll(ProductModel.fromJson(apiResponse.response.data).products);
      _sellerPageSize = ProductModel.fromJson(apiResponse.response.data).totalSize;
      _firstLoading = false;
      _isLoading = false;
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }

  void filterData(String newText) {
    _sellerProductList.clear();
    if(newText.isNotEmpty) {
      _sellerAllProductList.forEach((product) {
        if (product.name.toLowerCase().contains(newText.toLowerCase())) {
          _sellerProductList.add(product);
        }
      });
    }else {
      _sellerProductList.clear();
      _sellerProductList.addAll(_sellerAllProductList);
    }
    notifyListeners();
  }

  void clearSellerData() {
    _sellerProductList = [];
    notifyListeners();
  }

  // Brand and category products
  List<Product> _brandOrCategoryProductList = [];
  bool _hasData;

  List<Product> get brandOrCategoryProductList => _brandOrCategoryProductList;
  bool get hasData => _hasData;

  void initBrandOrCategoryProductList(bool isBrand, String id, BuildContext context, String languageCode) async {
    _brandOrCategoryProductList.clear();
    _hasData = true;
    ApiResponse apiResponse = await productRepo.getBrandOrCategoryProductList(isBrand, id, languageCode);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      apiResponse.response.data.forEach((product) => _brandOrCategoryProductList.add(Product.fromJson(product)));
      _hasData = _brandOrCategoryProductList.length > 1;
      List<Product> _products = [];
      _products.addAll(_brandOrCategoryProductList);
      _brandOrCategoryProductList.clear();
      _brandOrCategoryProductList.addAll(_products.reversed);
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }

  // Related products
  List<Product> _relatedProductList;
  List<Product> get relatedProductList => _relatedProductList;

  void initRelatedProductList(String id, BuildContext context, String languageCode) async {
    ApiResponse apiResponse = await productRepo.getRelatedProductList(id, languageCode);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _relatedProductList = [];
      apiResponse.response.data.forEach((product) => _relatedProductList.add(Product.fromJson(product)));
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }

  void removePrevRelatedProduct() {
    _relatedProductList = null;
  }
}
