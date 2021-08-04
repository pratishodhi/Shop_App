import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_providers.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-products';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          //'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('jpg') &&
              !_imageUrlController.text.endsWith('jpeg') &&
              !_imageUrlController.text.endsWith('png'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      await Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit products'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),):Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavourite: _editedProduct.isFavourite,
                        title: value,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return ('Please enter a valid title');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      price: double.parse(value),
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This is blank';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }

                    if (double.parse(value) <= 0) {
                      return 'Amount cannot be 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavourite: _editedProduct.isFavourite,
                        title: _editedProduct.title,
                        description: value,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This is blank';
                    }
                    if (value.length < 10) {
                      return 'Please enter a description longer than 10';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter URL')
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) => {
                          _saveForm(),
                        },
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              imageUrl: value,
                              price: _editedProduct.price);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'This is blank';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Enter a valid url';
                          }
                          if (!value.endsWith('jpg') &&
                              !value.endsWith('jpeg') &&
                              !value.endsWith('png')) {
                            return 'Enter a valid url';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
