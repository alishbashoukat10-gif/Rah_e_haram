const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const User = require('../models/User');
const router = express.Router(); 

// --- SIGNUP ROUTE (USER) ---
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ message: 'User already exists' });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    // 🆕 Role hamesha 'user' set hota hai (app se role nahi liya jata)
    const newUser = new User({ name, email, password: hashedPassword, role: 'user', status: 'approved' });
    await newUser.save();

    const token = jwt.sign({ id: newUser._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
    res.status(201).json({ message: 'User registered successfully', token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// --- 🆕 SIGNUP ROUTE (OPERATOR) ---
router.post('/register-operator', async (req, res) => {
  try {
    const { name, email, password, phone, cnic, licenseNumber, agencyName } = req.body;

    // Required fields check
    if (!name || !email || !password || !phone || !cnic || !licenseNumber || !agencyName) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    // Format validation (server par bhi zaroori hai)
    if (!/^03\d{9}$/.test(phone)) {
      return res.status(400).json({ message: 'Invalid phone number' });
    }
    if (!/^\d{13}$/.test(cnic)) {
      return res.status(400).json({ message: 'CNIC must be 13 digits' });
    }

    // Duplicate checks
    if (await User.findOne({ email })) {
      return res.status(400).json({ message: 'Email already exists' });
    }
    if (await User.findOne({ cnic })) {
      return res.status(400).json({ message: 'CNIC already registered' });
    }
    if (await User.findOne({ licenseNumber })) {
      return res.status(400).json({ message: 'License number already registered' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newOperator = new User({
      name,
      email,
      password: hashedPassword,
      role: 'operator',
      status: 'pending', // admin verify karne ke baad 'approved' hoga
      phone,
      cnic,
      licenseNumber,
      agencyName
    });
    await newOperator.save();

    // Token nahi bhejte, kyunke account abhi verify nahi hua
    res.status(201).json({ message: 'Operator registered. Account is pending verification.' });
  } catch (error) {
    // MongoDB unique index error
    if (error.code === 11000) {
      return res.status(400).json({ message: 'Email, CNIC or license number already exists' });
    }
    res.status(500).json({ message: error.message });
  }
});

// --- LOGIN ROUTE ---
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
    res.status(200).json({ 
      message: 'Login successful', 
      token,
      // 🆕 role aur status bhi bheje ja rahe hain taake app sahi screen khole
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// --- 1. SEND OTP ROUTE ---
router.post('/send-otp', async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'No account found with this email' });

    const otp = Math.floor(1000 + Math.random() * 9000).toString(); 
    
    // 🔴 PEHLE DATABASE MEIN SAVE KAREIN
    user.resetOtp = otp;
    user.resetOtpExpiry = Date.now() + 10 * 60 * 1000; 
    await user.save();

    // 🔴 Terminal mein OTP print karein
    console.log(`\n========================================`);
    console.log(`📧 OTP for ${email} is: ${otp}`);
    console.log(`========================================\n`);

    // PHIR EMAIL BHEJEIN
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    await transporter.sendMail({
      from: `"Rah e Haram" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Password Reset OTP',
      text: `Your password reset code is: ${otp}. This code is valid for 10 minutes.`
    });

    res.status(200).json({ message: 'OTP has been sent to your email!' });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Error sending email. Please check terminal.' });
  }
});

// --- 2. VERIFY OTP ROUTE ---
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;
    const user = await User.findOne({ email });

    if (!user || !user.resetOtp || !user.resetOtpExpiry) {
      return res.status(400).json({ message: 'Please request OTP first' });
    }

    if (Date.now() > user.resetOtpExpiry) {
      return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
    }

    if (user.resetOtp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    const resetToken = jwt.sign({ email }, process.env.JWT_SECRET || 'secret', { expiresIn: '10m' });
    
    user.resetOtp = null;
    user.resetOtpExpiry = null;
    await user.save();

    res.status(200).json({ message: 'OTP Verified!', resetToken });
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

// --- 3. RESET PASSWORD ROUTE ---
router.post('/reset-password', async (req, res) => {
  try {
    const { resetToken, newPassword } = req.body;
    const decoded = jwt.verify(resetToken, process.env.JWT_SECRET || 'secret');
    const user = await User.findOne({ email: decoded.email });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    res.status(200).json({ message: 'Password changed successfully!' });
  } catch (error) {
    res.status(400).json({ message: 'Token expired or invalid.' });
  }
});

module.exports = router;