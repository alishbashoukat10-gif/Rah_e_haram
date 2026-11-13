const mongoose = require('mongoose');

const agencySchema = new mongoose.Schema({
  name: { type: String, required: true },
  licenseNumber: { type: String, required: true },
  rating: { type: Number, default: 4.5 },
  isVerified: { type: Boolean, default: true },
  city: { type: String, required: true },
  contactNumber: { type: String, required: true },
  // 🔴 Nayi details
  email: { type: String, default: 'info@agency.com' },
  whatsapp: { type: String, default: '+923001234567' },
  services: { type: [String], default: ['Visa Processing', 'Transport', 'Hotels'] },
  logoUrl: { type: String, default: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' } 
});

module.exports = mongoose.model('Agency', agencySchema);