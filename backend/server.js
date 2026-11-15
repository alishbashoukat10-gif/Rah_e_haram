const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const reviewRoutes = require('./routes/reviewRoutes');
// ✅ 1. Yahan Agency routes import karein (Naam bilkul agencyRoutes.js jaisa ho)
const agencyRoutes = require('./routes/agencyRoutes'); 

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);

// ✅ 2. Yahan Agency routes ko use karein
app.use('/api/agencies', agencyRoutes); 
app.use('/api/reviews', reviewRoutes);
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/rah_e_haram')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.log('❌ MongoDB Error:', err));

app.get('/', (req, res) => {
  res.send('Rah e Haram Backend is Running!');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT} and accessible on network`);
});