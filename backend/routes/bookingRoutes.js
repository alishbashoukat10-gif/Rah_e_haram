
const express = require('express');
const router = express.Router();

const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

const Booking = require('../models/Booking');
const Package = require('../models/Package');
const CustomizationRequest = require('../models/CustomizationRequest');

// VERIFY LOGIN
const verifyToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Please login first'
      });
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'secret'
    );

    req.userId = decoded.id;
    next();

  } catch (error) {
    return res.status(401).json({
      message: 'Invalid or expired token'
    });
  }
};

// 1. CREATE STANDARD OR CUSTOMIZED BOOKING
router.post('/', verifyToken, async (req, res) => {
  try {
    const { packageId, customizationRequestId } = req.body;

    // Require exactly one booking method
    if (packageId && customizationRequestId) {
      return res.status(400).json({
        message: 'Provide either packageId or customizationRequestId, not both'
      });
    }

    if (!packageId && !customizationRequestId) {
      return res.status(400).json({
        message: 'A package ID or customization request ID is required'
      });
    }

    // CUSTOMIZED BOOKING
    if (customizationRequestId) {

      if (!mongoose.Types.ObjectId.isValid(customizationRequestId)) {
        return res.status(400).json({
          message: 'Invalid customization request ID'
        });
      }

      const request = await CustomizationRequest.findOne({
        _id: customizationRequestId,
        user: req.userId
      });

      if (!request) {
        return res.status(404).json({
          message: 'Customization request not found'
        });
      }

      if (request.status !== 'Accepted') {
        return res.status(400).json({
          message: 'You must accept the customization offer first'
        });
      }

      if (!request.selectedAgencyResponseId) {
        return res.status(400).json({
          message: 'No agency offer has been selected'
        });
      }

      // Retrieve the exact offer accepted by the pilgrim
      const selectedOffer = request.agencyResponses.id(
        request.selectedAgencyResponseId
      );

      if (!selectedOffer) {
        return res.status(404).json({
          message: 'The selected agency offer could not be found'
        });
      }

      if (selectedOffer.decision !== 'Accepted') {
        return res.status(400).json({
          message: 'The selected agency offer has not been accepted'
        });
      }

      if (
        selectedOffer.availability !== 'Available' ||
        !Number.isFinite(Number(selectedOffer.proposedPrice)) ||
        Number(selectedOffer.proposedPrice) <= 0
      ) {
        return res.status(400).json({
          message: 'The selected agency offer is not valid'
        });
      }

      // Prevent duplicate customized bookings
      const existingBooking = await Booking.findOne({
        customizationRequest: request._id
      });

      if (existingBooking) {
        return res.status(409).json({
          message: 'A booking already exists for this customization request',
          booking: existingBooking
        });
      }

      const selectedPackage = await Package.findOne({
        _id: request.package,
        isActive: true
      });

      if (!selectedPackage) {
        return res.status(404).json({
          message: 'The selected package is no longer available'
        });
      }

      const booking = new Booking({
        user: req.userId,
        package: selectedPackage._id,
        customizationRequest: request._id,
        totalAmount: Number(selectedOffer.proposedPrice),
        bookingType: 'Customized',
        status: 'Pending'
      });

      await booking.save();

      return res.status(201).json({
        message: 'Customized booking created successfully',
        booking
      });
    }

    // STANDARD BOOKING
    if (!mongoose.Types.ObjectId.isValid(packageId)) {
      return res.status(400).json({
        message: 'A valid package ID is required'
      });
    }

    const selectedPackage = await Package.findOne({
      _id: packageId,
      isActive: true
    });

    if (!selectedPackage) {
      return res.status(404).json({
        message: 'Package not found or inactive'
      });
    }

    if (
      !Number.isFinite(Number(selectedPackage.price)) ||
      Number(selectedPackage.price) <= 0
    ) {
      return res.status(400).json({
        message: 'Package price is invalid'
      });
    }

    const booking = new Booking({
      user: req.userId,
      package: selectedPackage._id,
      totalAmount: Number(selectedPackage.price),
      bookingType: 'Standard',
      status: 'Pending'
    });

    await booking.save();

    return res.status(201).json({
      message: 'Booking created successfully',
      booking
    });

  } catch (error) {
    console.error('Booking Error:', error);

    return res.status(500).json({
      message: 'Unable to create booking',
      error: error.message
    });
  }
});

// 2. GET LOGGED-IN USER'S BOOKINGS
router.get('/my-bookings', verifyToken, async (req, res) => {
  try {
    const bookings = await Booking.find({
      user: req.userId
    })
      .populate({
        path: 'package',
        populate: {
          path: 'agency',
          select: 'name city'
        }
      })
      .populate('customizationRequest')
      .sort({ createdAt: -1 });

    return res.status(200).json({
      message: 'Bookings retrieved successfully',
      bookings
    });

  } catch (error) {
    console.error('Fetch Bookings Error:', error);

    return res.status(500).json({
      message: 'Unable to retrieve bookings',
      error: error.message
    });
  }
});

module.exports = router;
