const express = require('express');
const router = express.Router();
const Agency = require('../models/Agency');

// 1. Get all agencies API
router.get('/', async (req, res) => {
  try {
    const agencies = await Agency.find();
    res.status(200).json(agencies);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

// 2. Add agency API (Testing ke liye)
router.post('/add', async (req, res) => {
  try {
    const newAgency = new Agency(req.body);
    await newAgency.save();
    res.status(201).json({ message: 'Agency Added Successfully!' });
  } catch (error) {
    res.status(500).json({ message: 'Error adding agency' });
  }
});

// 3. Purana testing data delete karne ke liye API (Browser se chalane ke liye GET kiya hai)
router.get('/delete-test-data', async (req, res) => {
  try {
    await Agency.deleteMany({ name: "Al-Haram Travels" });
    res.status(200).json({ message: 'Purana data delete ho gaya!' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting data' });
  }
});

module.exports = router;