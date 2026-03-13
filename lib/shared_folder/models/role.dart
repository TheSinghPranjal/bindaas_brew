enum Role {
  superAdmin,
  admin,
  manager,
  headChef,
  chef,
  kitchen,
  seniorWaiter,
  waiter,
  serviceDesk,
  cleaning,
  inventory,
  customer,
}

Role? roleFromString(String? s) {
  if (s == null) return null;
  final key = s.toLowerCase().trim();
  switch (key) {
    case 'super admin':
    case 'super_admin':
    case 'superadmin':
      return Role.superAdmin;
    case 'admin':
      return Role.admin;
    case 'manager':
      return Role.manager;
    case 'head chef':
    case 'head_chef':
    case 'headchef':
      return Role.headChef;
    case 'chef':
      return Role.chef;
    case 'kitchen staff':
    case 'kitchen':
    case 'kitchen_staff':
      return Role.kitchen;
    case 'senior waiter':
    case 'senior_waiter':
      return Role.seniorWaiter;
    case 'waiter':
      return Role.waiter;
    case 'service desk':
    case 'service_desk':
      return Role.serviceDesk;
    case 'cleaning staff':
    case 'cleaning':
      return Role.cleaning;
    case 'inventory manager':
    case 'inventory':
      return Role.inventory;
    case 'customer':
      return Role.customer;
    default:
      return null;
  }
}
