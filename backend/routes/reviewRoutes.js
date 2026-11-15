const express = require('express');
const router = express.Router();
const Review = require('../models/Review');

// 🔴 1. Kisi agency ke saare reviews laane ki API
router.get('/:agencyId', async (req, res) => {
  try {
    const reviews = await Review.find({ agencyId: req.params.agencyId }).sort({ createdAt: -1 });
    res.status(200).json(reviews);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

// 🔴 2. Naya review add karne ki API
router.post('/add', async (req, res) => {
  try {
    const { agencyId, agencyName, userName, rating, reviewTitle, reviewText } = req.body;
    
    const newReview = new Review({
      agencyId,
      agencyName,
      userName,
      rating,
      reviewTitle,
      reviewText
    });

    await newReview.save();
    res.status(201).json({ message: 'Review submitted successfully!', review: newReview });
  } catch (error) {
    res.status(500).json({ message: 'Error submitting review' });
  }
});

module.exports = router;