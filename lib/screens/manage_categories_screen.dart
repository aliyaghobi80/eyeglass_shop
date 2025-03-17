import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _editNameController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();
  final bool _isLoading = false;

  Future<void> _showEditDialog(Map<String, dynamic> category) async {
    final categoryId = category['id'];
    if (categoryId == null) {
      Get.snackbar(
        'خطا',
        'شناسه دسته‌بندی نامعتبر است',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _editNameController.text = category['name']?.toString() ?? '';

    await showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
                    title: const Text('ویرایش دسته‌بندی'),
                    content: TextFormField(
            controller: _editNameController,
            decoration: const InputDecoration(
              labelText: 'نام دسته‌بندی',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفا نام دسته‌بندی را وارد کنید';
              }
              return null;
            },
                    ),
                    actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editNameController.text.isNotEmpty) {
                  await _editCategory(category);
                }
              },
              child: const Text('ذخیره'),
            ),
                    ],
                  ),
          ),
    );
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> category) async {
    final categoryId = category['id'];
    if (categoryId == null) {
      Get.snackbar(
        'خطا',
        'شناسه دسته‌بندی نامعتبر است',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
                    title: const Text('حذف دسته‌بندی'),
                    content: Text(
            'آیا از حذف دسته‌بندی "${category['name']}" اطمینان دارید؟',
                    ),
                    actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _deleteCategory(category);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
                    ],
                  ),
          ),
    );
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    try {
      final categoryId = int.tryParse(category['id'].toString());
      if (categoryId == null) {
        throw Exception('شناسه دسته‌بندی نامعتبر است');
      }

      await _productController.apiService.editCategory(
        categoryId,
        _editNameController.text,
      );

      Get.back();
      Get.snackbar(
        'موفقیت',
        'دسته‌بندی با موفقیت ویرایش شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _productController.fetchCategories();
    } catch (e) {
      Get.snackbar(
        'خطا',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    try {
      final categoryId = int.tryParse(category['id'].toString());
      if (categoryId == null) {
        throw Exception('شناسه دسته‌بندی نامعتبر است');
      }

      await _productController.apiService.deleteCategory(categoryId);

      Get.back();
      Get.snackbar(
        'موفقیت',
        'دسته‌بندی با موفقیت حذف شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _productController.fetchCategories();
    } catch (e) {
      Get.snackbar(
        'خطا',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت دسته‌بندی‌ها')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'نام دسته‌بندی',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا نام دسته‌بندی را وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addCategory,
                      child:
                      _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text('افزودن'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_productController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_productController.categories.isEmpty) {
                  return const Center(child: Text('هیچ دسته‌بندی وجود ندارد'));
                }

                return ListView.builder(
                  itemCount: _productController.categories.length,
                  itemBuilder: (context, index) {
                    final category = _productController.categories[index];
                    return ListTile(
                      title: Text(category['name']?.toString() ?? ''),
                      leading: Text(category['id'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(category),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'خطا',
        'لطفاً نام دسته‌بندی را وارد کنید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _productController.apiService.addCategory(_nameController.text);

      _nameController.clear();
      Get.snackbar(
        'موفقیت',
        'دسته‌بندی با موفقیت اضافه شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _productController.fetchCategories();
    } catch (e) {
      Get.snackbar(
        'خطا',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _editNameController.dispose();
    super.dispose();
  }
}
