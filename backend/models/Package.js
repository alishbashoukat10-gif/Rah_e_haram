
const mongoose = require('mongoose');

const packageSchema = new mongoose.Schema({
  packageName: {
    type: String,
    required: true
  },

  packageType: {
    type: String,
    enum: ['Hajj', 'Umrah'],
    required: true
  },

  agency: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agency',
    required: true
  },

  price: {
    type: Number,
    required: true,
    min: 1
  },

  durationDays: {
    type: Number,
    required: true,
    min: 1
  },

  hotelQuality: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },

  transportQuality: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },

  description: {
    type: String,
    default: ''
  },

  isActive: {
    type: Boolean,
    default: true
  }

}, { timestamps: true });

module.exports = mongoose.model('Package', packageSchema);
