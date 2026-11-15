const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },

  // 🆕 Role: 'user' ya 'operator'
  role: { type: String, enum: ['user', 'operator'], default: 'user' },

  // 🆕 Operator account status (admin verify karega)
  // user ke liye hamesha 'approved', operator ke liye shuru mein 'pending'
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'approved' },

  // 🆕 Operator ki extra details (sirf operator ke liye bharti hain)
  phone: { type: String },
  cnic: { type: String, unique: true, sparse: true },
  licenseNumber: { type: String, unique: true, sparse: true },
  agencyName: { type: String },

  // 🔴 OTP fields (Ye zaroori hain)
  resetOtp: { type: String, default: null },
  resetOtpExpiry: { type: Date, default: null }
});

module.exports = mongoose.model('User', userSchema);