# Testing Setup Guide

## Adding the Test Target to Xcode

The test files have been created in `/OktanTests/`. To run them, you need to add a Unit Testing Bundle target in Xcode:

### Step 1: Add Test Target
1. Open `oktan.xcodeproj` in Xcode
2. Go to **File → New → Target...**
3. Select **iOS → Unit Testing Bundle**
4. Name it `OktanTests`
5. Ensure it's targeting the `oktan` app
6. Click Finish

### Step 2: Add Test Files to Target
1. In the Project Navigator, right-click on the `OktanTests` folder
2. Select **Add Files to "oktan"...**
3. Select all the `.swift` files in the `OktanTests` directory:
   - `FuelEntryTests.swift`
   - `FuelRepositoryTests.swift`
   - `AppSettingsTests.swift`
   - `CarRepositoryTests.swift`
   - `CalculationAccuracyTests.swift`
4. Make sure "Add to targets: OktanTests" is checked
5. Click Add

### Step 3: Configure Host Application
1. Select the `oktan` project in the Project Navigator
2. Select the `OktanTests` target
3. Go to the **General** tab
4. Under **Host Application**, select `oktan`

### Step 4: Run Tests
- Press `⌘U` to run all tests
- Or use **Product → Test**
- Or click the diamond icon next to any test function

## Test Coverage

### FuelEntryTests (27 tests)
- Distance calculations (valid, nil, invalid values)
- Total cost calculations
- L/100km efficiency calculations
- Cost per km calculations
- Drive mode enum
- Updating odometer values
- Equatable conformance
- Codable encoding/decoding

### FuelRepositoryTests (30+ tests)
- Add entry validation
- Update entry
- Delete entry
- Summary calculations (totals, averages)
- Drive mode breakdown
- CSV export
- Real-world data accuracy verification

### AppSettingsTests (25+ tests)
- Distance formatting (km/miles)
- Volume formatting (liters/gallons)
- Efficiency formatting (L/100km, km/L, MPG)
- Cost formatting with currencies
- Unit conversion accuracy
- Edge cases

### CarRepositoryTests (20+ tests)
- Save/update/delete car
- Car model properties (displayName)
- CarDatabase validation
- Tank capacity lookups
- Electric vehicle handling

### CalculationAccuracyTests (25+ tests)
- Formula verification for all calculations
- Known value verification for conversions
- Real-world seed data verification
- Floating point precision
- Edge cases (small/large values)

## Running Specific Tests

To run only specific test classes:
```
⌘-click on the test class name → Run "ClassName"
```

To run a single test:
```
Click the diamond icon next to the test function
```

## Continuous Integration

For CI/CD, tests can be run from command line:
```bash
xcodebuild test \
  -project oktan.xcodeproj \
  -scheme oktan \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```
