class orderItem {
  String net_total, status_title, address, created_on, rand_id;
  int id, shipping_charges, discount, total, status;

  orderItem(
      {this.id,
      this.rand_id,
      this.address,
      this.net_total,
      this.shipping_charges,
      this.status,
      this.discount,
      this.status_title,
      this.total,
      this.created_on});
}
