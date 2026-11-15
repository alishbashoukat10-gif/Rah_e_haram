
const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  package: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Package',
    required: true
  },

  // Link to an accepted customization request, if applicable.
  customizationRequest: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CustomizationRequest',
    default: null
  },

  totalAmount: {
    type: Number,
    required: true,
    min: 1
  },

  bookingType: {
    type: String,
    enum: ['Standard', 'Customized'],
    default: 'Standard'
  },

  status: {
    type: String,
    enum: ['Pending', 'Confirmed', 'Cancelled'],
    default: 'Pending'
  }

}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
