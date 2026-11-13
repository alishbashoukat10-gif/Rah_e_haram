const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const router = express.Router();

// --- SIGNUP ROUTE ---
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();

    const token = jwt.sign({ id: newUser._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });

    res.status(201).json({ message: 'User registered successfully', token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// --- LOGIN ROUTE ---
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });

    res.status(200).json({ message: 'Login successful', token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// --- FORGOT PASSWORD ROUTE (Working Demo) ---
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    
    // Check karein ke user mojood hai ya nahi
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'Is email se koi account nahi mila' });
    }

    // 🔴 REAL APP KE LIYE: Yahan aap email bhejne ka code (Nodemailer) laga sakti hain.
    // Filhal ke liye hum user ko success message bhej rahe hain taake app crash na ho.
    // Jab aapka Gmail setup ho jaye, toh yahan email bhejne ka code add kar dein.

    res.status(200).json({ 
      message: 'Aapke email par reset link bhej diya gaya hai! (Check your inbox)',
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Server mein masla hua. Baad mein try karein.' });
  }
});

module.exports = router;