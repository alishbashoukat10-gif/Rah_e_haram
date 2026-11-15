
const express = require('express');
const router = express.Router();

const Package = require('../models/Package');

// ==========================================
// 1. GET ALL ACTIVE PACKAGES
// ==========================================
router.get('/', async (req, res) => {
  try {
    const packages = await Package.find({
      isActive: true
    })
      .populate('agency', 'name city rating')
      .sort({ createdAt: -1 });

    return res.status(200).json(packages);

  } catch (error) {
    console.error('Fetch Packages Error:', error);

    return res.status(500).json({
      message: 'Unable to retrieve packages'
    });
  }
});


// ==========================================
// 2. ADD A PACKAGE
// ==========================================
router.post('/', async (req, res) => {
  try {
    const newPackage = new Package(req.body);

    await newPackage.save();

    const savedPackage = await Package.findById(newPackage._id)
      .populate('agency', 'name city rating');

    return res.status(201).json({
      message: 'Package added successfully',
      package: savedPackage
    });

  } catch (error) {
    console.error('Add Package Error:', error);

    return res.status(400).json({
      message: error.message
    });
  }
});


// ==========================================
// 3. TOPSIS PACKAGE RECOMMENDATION
// ==========================================
router.post('/recommend', async (req, res) => {
  try {
    const {
      maxBudget,
      durationDays,
      weights = {},
      packageType
    } = req.body;


    // --------------------------------------
    // STEP 1: VALIDATE USER REQUIREMENTS
    // --------------------------------------

    const budget = Number(maxBudget);
    const duration = Number(durationDays);

    if (
      !Number.isFinite(budget) ||
      budget <= 0
    ) {
      return res.status(400).json({
        message: 'Please provide a valid maximum budget'
      });
    }

    if (
      !Number.isInteger(duration) ||
      duration <= 0
    ) {
      return res.status(400).json({
        message: 'Please provide a valid trip duration'
      });
    }

    if (!['Hajj', 'Umrah'].includes(packageType)) {
      return res.status(400).json({
        message: 'Package type must be Hajj or Umrah'
      });
    }


    // --------------------------------------
    // STEP 2: VALIDATE PRIORITY WEIGHTS
    // --------------------------------------

    if (
      typeof weights !== 'object' ||
      weights === null ||
      Array.isArray(weights)
    ) {
      return res.status(400).json({
        message: 'Invalid priority weights'
      });
    }

    let weightValues = [
      Number(weights.price ?? 50),
      Number(weights.hotel ?? 50),
      Number(weights.transport ?? 50),
      Number(weights.duration ?? 50)
    ];

    if (
      weightValues.some(value =>
        !Number.isFinite(value) ||
        value < 0 ||
        value > 100
      )
    ) {
      return res.status(400).json({
        message: 'Priority weights must be between 0 and 100'
      });
    }

    const totalWeight = weightValues.reduce(
      (sum, value) => sum + value,
      0
    );

    if (totalWeight <= 0) {
      return res.status(400).json({
        message: 'At least one priority must be positive'
      });
    }

    // Normalize weights so their sum equals 1
    const normalizedWeights = weightValues.map(
      value => value / totalWeight
    );


    // --------------------------------------
    // STEP 3: FILTER ELIGIBLE PACKAGES
    // --------------------------------------

    // Budget and journey type are hard requirements.
    // Packages outside these requirements are excluded
    // before TOPSIS ranking.

    const packages = await Package.find({
      isActive: true,
      price: { $lte: budget },
      packageType: packageType
    }).populate('agency', 'name city rating');

    if (packages.length === 0) {
      return res.status(200).json({
        message: 'No packages found within your requirements',
        packageType,
        results: []
      });
    }


    // --------------------------------------
    // STEP 4: CREATE DECISION MATRIX
    // --------------------------------------

    // Criteria:
    // 1. Price
    // 2. Hotel Quality
    // 3. Transport Quality
    // 4. Duration Similarity

    // Price: Cost criterion (lower is better)
    // Hotel: Benefit criterion (higher is better)
    // Transport: Benefit criterion (higher is better)
    // Duration: Benefit criterion (closer to requested duration is better)

    const matrix = packages.map(pkg => {
      const durationSimilarity =
        1 / (1 + Math.abs(pkg.durationDays - duration));

      return [
        pkg.price,
        pkg.hotelQuality,
        pkg.transportQuality,
        durationSimilarity
      ];
    });


    // --------------------------------------
    // STEP 5: VECTOR NORMALIZATION
    // --------------------------------------

    const denominators = [0, 0, 0, 0];

    for (let j = 0; j < 4; j++) {
      denominators[j] = Math.sqrt(
        matrix.reduce(
          (sum, row) => sum + row[j] ** 2,
          0
        )
      );
    }

    const normalizedMatrix = matrix.map(row =>
      row.map((value, j) => {
        if (denominators[j] === 0) {
          return 0;
        }

        return value / denominators[j];
      })
    );


    // --------------------------------------
    // STEP 6: APPLY NORMALIZED WEIGHTS
    // --------------------------------------

    const weightedMatrix = normalizedMatrix.map(row =>
      row.map(
        (value, j) => value * normalizedWeights[j]
      )
    );


    // --------------------------------------
    // STEP 7: FIND IDEAL BEST AND WORST
    // --------------------------------------

    const idealBest = [];
    const idealWorst = [];

    for (let j = 0; j < 4; j++) {
      const columnValues = weightedMatrix.map(
        row => row[j]
      );

      if (j === 0) {
        // Price: lower value is better
        idealBest[j] = Math.min(...columnValues);
        idealWorst[j] = Math.max(...columnValues);

      } else {
        // Hotel, transport and duration:
        // higher value is better
        idealBest[j] = Math.max(...columnValues);
        idealWorst[j] = Math.min(...columnValues);
      }
    }


    // --------------------------------------
    // STEP 8: CALCULATE TOPSIS SCORES
    // --------------------------------------

    const results = packages.map((pkg, index) => {

      // Distance from ideal best
      const distanceBest = Math.sqrt(
        weightedMatrix[index].reduce(
          (sum, value, j) =>
            sum + (value - idealBest[j]) ** 2,
          0
        )
      );

      // Distance from ideal worst
      const distanceWorst = Math.sqrt(
        weightedMatrix[index].reduce(
          (sum, value, j) =>
            sum + (value - idealWorst[j]) ** 2,
          0
        )
      );

      const denominator = distanceBest + distanceWorst;

      // TOPSIS relative closeness coefficient
      const score = denominator === 0
        ? 0.5
        : distanceWorst / denominator;

      return {
        ...pkg.toObject(),

        topsisScore: Number(score.toFixed(4))
      };
    });


    // --------------------------------------
    // STEP 9: RANK PACKAGES
    // --------------------------------------

    // Higher TOPSIS score means a better match.
    // Price is used only as a tie-breaker when
    // two packages have exactly the same score.

    results.sort((a, b) => {
      const scoreDifference =
        b.topsisScore - a.topsisScore;

      if (scoreDifference !== 0) {
        return scoreDifference;
      }

      return a.price - b.price;
    });

    const rankedResults = results.map(
      (pkg, index) => ({
        ...pkg,
        rank: index + 1,
        isBestMatch: index === 0
      })
    );


    // --------------------------------------
    // STEP 10: RETURN RESULTS TO FLUTTER
    // --------------------------------------

    return res.status(200).json({
      message: 'Packages ranked successfully',
      packageType,
      totalPackages: rankedResults.length,
      results: rankedResults
    });

  } catch (error) {
    console.error('TOPSIS Recommendation Error:', error);

    return res.status(500).json({
      message: 'Unable to generate package recommendations'
    });
  }
});

module.exports = router;
