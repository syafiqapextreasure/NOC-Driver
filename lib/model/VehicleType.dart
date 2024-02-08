class VehicleType {
  String? shortDescription;
  String? vehicleIcon;
  String? name;
  String? description;
  String? id;
  bool? isActive;
  String? capacity;
  String? supportedVehicle;
  String? delivery_charges_per_km;
  String? minimum_delivery_charges;
  String? minimum_delivery_charges_within_km;

  VehicleType(
      {this.shortDescription,
      this.vehicleIcon,
      this.name,
      this.description,
      this.id,
      this.isActive,
      this.capacity,
      this.delivery_charges_per_km,
      this.minimum_delivery_charges,
      this.minimum_delivery_charges_within_km,
      this.supportedVehicle});

  VehicleType.fromJson(Map<String, dynamic> json) {
    shortDescription = json['short_description'];
    vehicleIcon = json['vehicle_icon'];
    name = json['name'];
    description = json['description'];
    id = json['id'];
    isActive = json['isActive'];
    capacity = json['capacity'];
    delivery_charges_per_km = json['delivery_charges_per_km'] ?? "0.0";
    minimum_delivery_charges = json['minimum_delivery_charges'] ?? "0.0";
    minimum_delivery_charges_within_km =
        json['minimum_delivery_charges_within_km'] ?? "0.0";
    supportedVehicle = json['supported_vehicle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['short_description'] = shortDescription;
    data['vehicle_icon'] = vehicleIcon;
    data['name'] = name;
    data['description'] = description;
    data['id'] = id;
    data['isActive'] = isActive;
    data['capacity'] = capacity;
    data['supported_vehicle'] = supportedVehicle;
    data['delivery_charges_per_km'] = delivery_charges_per_km;
    data['minimum_delivery_charges'] = minimum_delivery_charges;
    data['minimum_delivery_charges_within_km'] =
        minimum_delivery_charges_within_km;
    return data;
  }
}
