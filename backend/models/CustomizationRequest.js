
const mongoose = require('mongoose');

const agencyResponseSchema = new mongoose.Schema({
  agency: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agency'
  },

  proposedPrice: {
    type: Number,
    default: null
  },

  message: {
    type: String,
    default: ''
  },

  availability: {
    type: String,
    enum: ['Pending', 'Available', 'Unavailable'],
    default: 'Pending'
  },

  // Pilgrim's decision about this particular offer
  decision: {
    type: String,
    enum: ['Pending', 'Accepted', 'Rejected'],
    default: 'Pending'
  },

  respondedAt: {
    type: Date,
    default: null
  }

});

const customizationRequestSchema = new mongoose.Schema({
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

  originalAgency: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agency'
  },

  packageName: {
    type: String,
    required: true
  },

  packageType: {
    type: String,
    enum: ['Hajj', 'Umrah'],
    required: true
  },

  originalDuration: {
    type: Number,
    required: true
  },

  requestedDuration: {
    type: Number,
    required: true
  },

  originalPrice: {
    type: Number,
    required: true
  },

  estimatedPrice: {
    type: Number,
    required: true
  },

  specialRequirements: {
    type: String,
    default: ''
  },

  status: {
    type: String,
    enum: ['Pending', 'Responded', 'Accepted', 'Rejected'],
    default: 'Pending'
  },

  agencyResponses: [agencyResponseSchema],

  selectedAgencyResponseId: {
    type: mongoose.Schema.Types.ObjectId,
    default: null
  }

}, { timestamps: true });

module.exports = mongoose.model(
  'CustomizationRequest',
  customizationRequestSchema
);
