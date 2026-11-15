
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const agencyRoutes = require('./routes/agencyRoutes');
const packageRoutes = require('./routes/packageRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const customizationRoutes = require('./routes/customizationRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/agencies', agencyRoutes);
app.use('/api/packages', packageRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/customizations', customizationRoutes);

// MongoDB connection
mongoose.connect(
  process.env.MONGO_URI || 'mongodb://localhost:27017/rah_e_haram'
)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.log('❌ MongoDB Error:', err));

// Home route
app.get('/', (req, res) => {
  res.send('Rah e Haram Backend is Running!');
});

// Start server
const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT} and accessible on network`);
});
