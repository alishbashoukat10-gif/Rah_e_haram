
const express = require('express');
const router = express.Router();

const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

const CustomizationRequest = require('../models/CustomizationRequest');
const Package = require('../models/Package');

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

// 1. CREATE CUSTOMIZATION REQUEST
router.post('/', verifyToken, async (req, res) => {
  try {
    const {
      packageId,
      requestedDuration,
      specialRequirements
    } = req.body;

    if (!packageId || !mongoose.Types.ObjectId.isValid(packageId)) {
      return res.status(400).json({
        message: 'A valid package ID is required'
      });
    }

    const duration = Number(requestedDuration);

    if (!Number.isInteger(duration) || duration <= 0) {
      return res.status(400).json({
        message: 'Please provide a valid requested duration'
      });
    }

    const selectedPackage = await Package.findById(packageId)
      .populate('agency');

    if (!selectedPackage || !selectedPackage.isActive) {
      return res.status(404).json({
        message: 'Package not found or unavailable'
      });
    }

    if (!selectedPackage.agency) {
      return res.status(400).json({
        message: 'The package does not have an associated agency'
      });
    }

    if (
      !selectedPackage.durationDays ||
      selectedPackage.durationDays <= 0
    ) {
      return res.status(400).json({
        message: 'Package duration is invalid'
      });
    }

    const estimatedPrice = Math.round(
      (selectedPackage.price / selectedPackage.durationDays) * duration
    );

    const customizationRequest = new CustomizationRequest({
      user: req.userId,
      package: selectedPackage._id,
      originalAgency: selectedPackage.agency._id,
      packageName: selectedPackage.packageName,
      packageType: selectedPackage.packageType,
      originalDuration: selectedPackage.durationDays,
      requestedDuration: duration,
      originalPrice: selectedPackage.price,
      estimatedPrice,
      specialRequirements: specialRequirements || '',
      status: 'Pending'
    });

    await customizationRequest.save();

    res.status(201).json({
      message: 'Customization request submitted successfully',
      request: customizationRequest
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
});

// 2. GET MY CUSTOMIZATION REQUESTS
router.get('/my-requests', verifyToken, async (req, res) => {
  try {
    const requests = await CustomizationRequest.find({
      user: req.userId
    })
      .populate('package')
      .populate('originalAgency', 'name city contactNumber')
      .sort({ createdAt: -1 });

    res.status(200).json({
      message: 'Customization requests retrieved successfully',
      requests
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
});

// 3. ACCEPT AN AGENCY OFFER
router.post('/:requestId/accept', verifyToken, async (req, res) => {
  try {
    const { requestId } = req.params;
    const { responseId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(requestId)) {
      return res.status(400).json({
        message: 'Invalid customization request ID'
      });
    }

    if (!responseId || !mongoose.Types.ObjectId.isValid(responseId)) {
      return res.status(400).json({
        message: 'A valid agency response ID is required'
      });
    }

    const request = await CustomizationRequest.findOne({
      _id: requestId,
      user: req.userId
    });

    if (!request) {
      return res.status(404).json({
        message: 'Customization request not found'
      });
    }

    if (['Accepted', 'Rejected'].includes(request.status)) {
      return res.status(400).json({
        message: 'This customization request is already closed'
      });
    }

    const selectedResponse = request.agencyResponses.id(responseId);

    if (!selectedResponse) {
      return res.status(404).json({
        message: 'Agency offer not found'
      });
    }

    if (selectedResponse.decision === 'Rejected') {
      return res.status(400).json({
        message: 'You have already rejected this offer'
      });
    }

    if (selectedResponse.availability !== 'Available') {
      return res.status(400).json({
        message: 'This agency offer is not available'
      });
    }

    if (
      !Number.isFinite(Number(selectedResponse.proposedPrice)) ||
      Number(selectedResponse.proposedPrice) <= 0
    ) {
      return res.status(400).json({
        message: 'The agency offer does not have a valid price'
      });
    }

    selectedResponse.decision = 'Accepted';

    request.selectedAgencyResponseId = selectedResponse._id;
    request.status = 'Accepted';

    await request.save();

    res.status(200).json({
      message: 'Agency offer accepted successfully',
      request
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
});

// 4. REJECT ONE AGENCY OFFER
router.post('/:requestId/reject', verifyToken, async (req, res) => {
  try {
    const { requestId } = req.params;
    const { responseId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(requestId)) {
      return res.status(400).json({
        message: 'Invalid customization request ID'
      });
    }

    if (!responseId || !mongoose.Types.ObjectId.isValid(responseId)) {
      return res.status(400).json({
        message: 'A valid agency response ID is required'
      });
    }

    const request = await CustomizationRequest.findOne({
      _id: requestId,
      user: req.userId
    });

    if (!request) {
      return res.status(404).json({
        message: 'Customization request not found'
      });
    }

    if (['Accepted', 'Rejected'].includes(request.status)) {
      return res.status(400).json({
        message: 'This customization request is already closed'
      });
    }

    const selectedResponse = request.agencyResponses.id(responseId);

    if (!selectedResponse) {
      return res.status(404).json({
        message: 'Agency offer not found'
      });
    }

    if (selectedResponse.decision !== 'Pending') {
      return res.status(400).json({
        message: 'This offer has already been processed'
      });
    }

    selectedResponse.decision = 'Rejected';

    await request.save();

    res.status(200).json({
      message: 'Agency offer rejected successfully',
      request
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
});

module.exports = router;
