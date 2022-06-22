class cartItem {
  String code, title, image, variation_1, variation_2;
  int id, qty, dprice, price, amount, product_variation_type;

  cartItem({
    this.id,
    this.code,
    this.title,
    this.image,
    this.qty,
    this.dprice,
    this.price,
    this.amount,
    this.product_variation_type,
    this.variation_1,
    this.variation_2,
  });

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['id'] = id;
    m['code'] = code;
    m['title'] = title;
    m['image'] = image;
    m['qty'] = qty;
    m['dprice'] = dprice;
    m['price'] = price;
    m['amount'] = amount;
    m['variation_1'] = variation_1;
    m['variation_2'] = variation_2;
    m['product_variation_type'] = product_variation_type;
    return m;
  }
}
