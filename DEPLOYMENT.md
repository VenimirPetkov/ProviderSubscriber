# Provider-Subscriber System Deployment Guide

This document explains how to deploy the Provider-Subscriber system contracts according to the assignment requirements.

## Assignment Requirements Summary

The system implements a marketplace where:
- **Providers** offer services for a monthly fee (minimum $50)
- **Subscribers** consume services and must deposit at least $100
- Maximum 200 providers can be registered
- Uses ERC20 tokens for payments with Chainlink price feeds for USD conversion
- Supports upgradeable contracts with proxy pattern

## Deployment Parameters

Based on the assignment requirements, the following parameters are configured:

- **Minimum Provider Fee**: $50 USD (5000000000 with 8 decimals)
- **Minimum Subscriber Deposit**: $100 USD (10000000000 with 8 decimals)
- **Maximum Providers**: 200
- **Month Duration**: 216,000 blocks (~1 month on Ethereum)

## Deployment Options

### Option 1: Full Deployment with Auto-Initialization (Recommended)

Deploy and initialize everything in one command:

```bash
npm run deploy:full
```

This will:
- Deploy MockERC20 token
- Deploy Mock LINK Token
- Deploy MockPriceFeed
- Deploy ProviderSubscriberSystem (implementation)
- Deploy ProviderSubscriberProxy
- Automatically initialize the proxy

### Option 2: Ignition Deployment (Manual Initialization)

Deploy using Hardhat Ignition (requires manual initialization):

```bash
npm run deploy
```

This will deploy:
- MockERC20 token
- Mock LINK Token
- MockPriceFeed
- ProviderSubscriberSystem (implementation)
- ProviderSubscriberProxy

Then initialize manually:
```bash
npm run init:proxy
```

### Option 3: Manual Initialization (if you have existing deployments)

If you already have deployed contracts, you can initialize them manually:

1. Set environment variables:
```bash
export PROXY_ADDRESS="0x..." # Address from deployment output
export MOCK_TOKEN_ADDRESS="0x..." # Address from deployment output
export MOCK_PRICE_FEED_ADDRESS="0x..." # Address from deployment output
```

2. Run initialization:
```bash
npm run init:proxy
```

## Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# Hoodi Network Configuration
HOODI_RPC_URL=https://rpc.hoodi.network
HOODI_PRIVATE_KEY=0x...

# Mainnet Configuration
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
MAINNET_PRIVATE_KEY=0x...

# Mainnet Fork Configuration
MAINNET_FORK_PRIVATE_KEY=0x...

# Contract Addresses (for initialization script)
PROXY_ADDRESS=0x...
MOCK_TOKEN_ADDRESS=0x...
MOCK_PRICE_FEED_ADDRESS=0x...
```

## Network Configuration

### Local Development
```bash
# Start local node
npm run node

# Deploy to local network (full deployment with auto-initialization)
npm run deploy:full

# Or deploy with Ignition (manual initialization)
npm run deploy
```

### Testnet (Hoodi)
```bash
# Set environment variables
export HOODI_RPC_URL="https://rpc.hoodi.network"
export HOODI_PRIVATE_KEY="0x..."

# Deploy to Hoodi (full deployment with auto-initialization)
npm run deploy:full:hoodi

# Or deploy with Ignition (manual initialization)
npm run deploy:hoodi
```

### Mainnet
```bash
# Set environment variables
export MAINNET_RPC_URL="https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
export MAINNET_PRIVATE_KEY="0x..."

# Deploy to Mainnet (full deployment with auto-initialization)
npm run deploy:full:mainnet

# Or deploy with Ignition (manual initialization)
npm run deploy:mainnet
```

### Mainnet Fork
```bash
# Start mainnet fork
npx hardhat node --fork https://mainnet.infura.io/v3/YOUR_PROJECT_ID

# Set environment variables
export MAINNET_FORK_PRIVATE_KEY="0x..."

# Deploy to Mainnet Fork (full deployment with auto-initialization)
npm run deploy:full:fork

# Or deploy with Ignition (manual initialization)
npm run deploy:fork
```

**Note**: The mainnet fork configuration uses the actual Chainlink LINK/USD aggregator (`0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c`) for real price data.

## Chainlink Price Feed Information

For mainnet and mainnet fork deployments, the system uses the official Chainlink LINK/USD price aggregator:

- **Address**: `0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c`
- **Pair**: LINK/USD
- **Decimals**: 8
- **Update Frequency**: Every 3600 seconds (1 hour)
- **Deviation Threshold**: 0.5%
- **Heartbeat**: 3600 seconds

This ensures accurate USD price conversion for the Provider-Subscriber system on mainnet environments.

## Contract Addresses

After successful deployment, you'll get addresses for:
- MockERC20: Test token
- Mock LINK Token: Mock Chainlink token for testing
- MockPriceFeed: Price oracle
- ProviderSubscriberSystem: Implementation contract
- ProviderSubscriberProxy: Main contract (use this address)

## Verification

After deployment and initialization, verify the contract is properly configured:

```javascript
const contract = await ethers.getContractAt('ProviderSubscriberSystem', proxyAddress);

// Check configuration
console.log('Owner:', await contract.owner());
console.log('Max Providers:', await contract.getMaxProviders());
console.log('Min Fee USD:', await contract.getMinFeeUsd());
console.log('Min Deposit USD:', await contract.getMinDepositUsd());
console.log('Month Duration:', await contract.getMonthDurationInBlocks());
```

## Key Features Implemented

✅ **Provider Registration**: Providers can register with minimum $50 fee
✅ **Subscriber Registration**: Subscribers must deposit minimum $100
✅ **Upgradeable Contracts**: Uses OpenZeppelin's UUPS proxy pattern
✅ **Access Control**: Owner-based access control for admin functions
✅ **Price Integration**: Chainlink price feeds for USD conversion
✅ **Maximum Providers**: Limited to 200 providers as per assignment
✅ **Monthly Billing**: Block-based monthly billing cycles
✅ **Subscription Management**: Pause/resume subscriptions
✅ **Earnings Withdrawal**: Providers can withdraw accumulated earnings

## Security Considerations

- Contract uses OpenZeppelin's battle-tested upgradeable contracts
- Reentrancy protection on all state-changing functions
- Proper access control with owner-only functions
- Input validation on all user inputs
- Safe math operations throughout

## Troubleshooting

### Common Issues

1. **"Contract not initialized"**: Run the initialization script after deployment
2. **"Insufficient funds"**: Ensure deployer account has enough ETH for gas
3. **"Invalid network"**: Check network configuration in hardhat.config.ts

### Getting Help

- Check contract compilation: `npm run compile`
- Run tests: `npm test`
- Verify deployment: Check the deployment output addresses
