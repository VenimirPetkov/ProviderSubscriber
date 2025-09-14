# Provider-Subscriber System

A comprehensive smart contract system that models a marketplace where entities (Providers) can offer services for a monthly fee to entities (Subscribers). The system uses ERC20 tokens as the medium of payment and integrates with Chainlink for USD price conversion.

## Features

### Core Functionality
- **Provider Registration**: Providers can register with monthly fees (minimum $50 USD)
- **Subscriber Registration**: Subscribers can register with deposits (minimum $100 USD)
- **Subscription Management**: Subscribers can subscribe to multiple providers
- **Monthly Billing**: Automated monthly billing cycles with earnings calculation
- **Earnings Withdrawal**: Providers can withdraw their earnings
- **Subscription Pausing**: Subscribers can pause subscriptions to avoid charges

### Security Features
- **Access Control**: Role-based access control with OpenZeppelin's Ownable
- **Reentrancy Protection**: ReentrancyGuard for secure operations
- **Input Validation**: Comprehensive input validation and error handling
- **Upgradeability**: UUPS proxy pattern for contract upgrades

### Integration Features
- **Chainlink Integration**: Real-time USD price conversion using Chainlink price feeds
- **ERC20 Support**: Full ERC20 token integration for payments
- **Multi-Network Support**: Deployable on localhost, Hoodi, Mainnet, and Mainnet Fork

## Assignment Requirements

This project fulfills all the requirements from the assignment:

### Functional Requirements
- **Provider Registration**: Providers register with registration key and fee
- **Provider Removal**: Providers can be removed by owners with balance return
- **Subscriber Registration**: Subscribers register with minimum $100 deposit
- **Subscription Management**: Subscribers can subscribe to multiple providers
- **Deposit Management**: Subscribers can increase subscription deposits
- **Earnings Withdrawal**: Providers can withdraw monthly earnings
- **Provider State Management**: Providers can be activated/deactivated by owner
- **Subscription Pausing**: Subscriptions can be paused to avoid charges

### Technical Requirements
- **Minimum Provider Fee**: $50 USD minimum (enforced via Chainlink)
- **Minimum Subscriber Deposit**: $100 USD minimum (enforced via Chainlink)
- **Maximum Providers**: 200 providers limit
- **Monthly Billing**: Automated monthly billing cycles
- **USD Value Calculations**: Real-time USD conversion using Chainlink
- **Upgradeability**: UUPS proxy pattern implementation
- **Authorization**: Comprehensive access control mechanisms

### View Functions
- **Provider State**: Get provider details (subscribers, fee, owner, balance, state)
- **Provider Earnings**: Get provider earnings with USD value
- **Subscriber State**: Get subscriber details (owner, balance, providers)
- **USD Value**: Get subscriber deposit value in USD
- **Subscription Cost**: Estimate subscription costs
- **Billing Status**: Check billing cycle status

## Architecture

### Contract Structure
```
ProviderSubscriber (Abstract)
├── ProviderSubscriberSystem (Implementation)
├── ProviderSubscriberProxy (Proxy)
├── IProviderSubscriber (Interface)
├── ProviderErrors (Error Library)
├── ProviderEvents (Event Library)
└── ChainlinkPriceFeed (Price Feed Library)
```

### Data Structures
- **Provider**: Owner, monthly fee, balance, subscribers, plan, state
- **Subscriber**: Owner, balance, active providers
- **ProviderSubscriber**: Subscription relationship with billing info

### Key Components
- **MockERC20**: Test token for development and testing
- **MockPriceFeed**: Mock Chainlink price feed for testing
- **Chainlink Integration**: Real Chainlink LINK/USD aggregator for mainnet

## Installation & Setup

### Prerequisites
- Node.js (v18+)
- npm or yarn
- Hardhat
- Git

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd ProviderSubscriber

# Install dependencies
npm install

# Compile contracts
npm run compile
```

### Environment Variables
Create a `.env` file with the following variables:
```env
# Network RPC URLs
HOODI_RPC_URL=https://your-hoodi-rpc-url
MAINNET_RPC_URL=https://your-mainnet-rpc-url

# Private Keys (for deployment)
HOODI_PRIVATE_KEY=your-hoodi-private-key
MAINNET_PRIVATE_KEY=your-mainnet-private-key
MAINNET_FORK_PRIVATE_KEY=your-fork-private-key
```

## Deployment

### Quick Deployment
```bash
# Deploy to localhost
npm run deploy:full

# Deploy to Hoodi
npm run deploy:full:hoodi

# Deploy to Mainnet
npm run deploy:full:mainnet

# Deploy to Mainnet Fork
npm run deploy:full:fork
```

### Step-by-Step Deployment
```bash
# 1. Deploy contracts only
npm run deploy:hoodi

# 2. Initialize proxy separately
npm run init:proxy:hoodi
```

### Network Configurations
- **localhost**: Mock tokens and price feeds
- **hoodi**: Mock LINK token, real Chainlink price feed
- **mainnet**: Real LINK token, real Chainlink price feed
- **mainnetFork**: Real LINK token, real Chainlink price feed

## Testing

### Run All Tests
```bash
# Run all tests locally
npm run test

# Run tests with verbose output
npm run test:verbose
```

### Run Tests on Fork
```bash
# Start mainnet fork
npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/demo

# Run tests on fork
npm run test:fork
```

### Test Coverage
The test suite covers:
- Contract compilation and deployment
- All assignment requirements
- Security features
- Upgradeability
- Integration features
- Gas efficiency
- Assignment compliance

## Configuration

### Deployment Parameters
```typescript
// Minimum provider fee: $50 USD
MIN_FEE_USD: '5000000000' // 8 decimals (Chainlink format)

// Minimum subscriber deposit: $100 USD  
MIN_DEPOSIT_USD: '10000000000' // 8 decimals (Chainlink format)

// Maximum providers: 200
MAX_PROVIDERS: 200

// Monthly billing cycle: ~1 month in blocks
MONTH_DURATION_BLOCKS: 216000 // ETH: ~12 seconds per block, 30 days
```

### Chainlink Integration
- **Mainnet LINK/USD Aggregator**: `0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c`
- **Price Feed Decimals**: 8 decimals
- **Update Frequency**: Every 3600 seconds (1 hour)
- **Deviation Threshold**: 0.5%

## Development

### Available Scripts
```bash
# Compilation
npm run compile          # Compile contracts
npm run clean           # Clean artifacts

# Testing
npm run test            # Run all tests
npm run test:verbose    # Run tests with verbose output
npm run test:fork       # Run tests on mainnet fork

# Deployment
npm run deploy          # Deploy to localhost
npm run deploy:hoodi    # Deploy to Hoodi
npm run deploy:mainnet  # Deploy to Mainnet
npm run deploy:fork     # Deploy to Mainnet Fork

# Full deployment (deploy + initialize)
npm run deploy:full     # Deploy and initialize on localhost
npm run deploy:full:hoodi    # Deploy and initialize on Hoodi
npm run deploy:full:mainnet  # Deploy and initialize on Mainnet
npm run deploy:full:fork     # Deploy and initialize on Mainnet Fork

# Proxy initialization only
npm run init:proxy      # Initialize proxy on localhost
npm run init:proxy:hoodi     # Initialize proxy on Hoodi
npm run init:proxy:mainnet   # Initialize proxy on Mainnet
npm run init:proxy:fork      # Initialize proxy on Mainnet Fork

# Utilities
npm run node            # Start local Hardhat node
npm run coverage        # Run test coverage
npm run size            # Check contract sizes
npm run format          # Format code
npm run precommit       # Run pre-commit checks
```

### Project Structure
```
ProviderSubscriber/
├── contracts/                 # Smart contracts
│   ├── interfaces/           # Contract interfaces
│   ├── libraries/           # Utility libraries
│   ├── mocks/              # Mock contracts for testing
│   ├── ProviderSubscriber.sol      # Abstract base contract
│   └── ProviderSubscriberSystem.sol # Implementation contract
├── ignition/modules/        # Hardhat Ignition deployment modules
├── scripts/                 # Deployment and utility scripts
├── test/                   # Test files
├── artifacts/              # Compiled contract artifacts
├── cache/                  # Hardhat cache
├── deploy-config.ts        # Deployment configuration
├── DEPLOYMENT.md          # Detailed deployment guide
├── hardhat.config.ts      # Hardhat configuration
└── package.json           # Project dependencies and scripts
```

## Security

### Security Features
- **Access Control**: Only authorized users can perform specific actions
- **Reentrancy Protection**: All state-changing functions are protected
- **Input Validation**: Comprehensive validation of all inputs
- **Overflow Protection**: Safe math operations with Solidity 0.8.28
- **Upgrade Safety**: UUPS pattern with proper authorization

### Security Considerations
- All external calls are properly handled
- State variables are properly initialized
- Events are emitted for all important state changes
- Error handling is comprehensive and informative

## Gas Optimization

### Optimizations Implemented
- **Efficient Data Structures**: Optimized storage layout
- **Batch Operations**: Reduced gas costs for multiple operations
- **Event Optimization**: Minimal event data for gas efficiency
- **Function Optimization**: Efficient function implementations

### Gas Usage Estimates
- Provider Registration: ~200,000 gas
- Subscriber Registration: ~150,000 gas
- Deposit: ~100,000 gas
- Subscription: ~180,000 gas
- Billing Cycle: ~300,000 gas

## Network Support

### Supported Networks
- **Localhost**: Development and testing
- **Hoodi**: Testnet with mock LINK token
- **Mainnet**: Production with real LINK token
- **Mainnet Fork**: Testing with real mainnet state

### Network-Specific Configurations
Each network has specific token and price feed configurations:
- Mock tokens for development
- Real Chainlink aggregators for production
- Appropriate RPC endpoints and private keys

## Documentation

### Additional Documentation
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Detailed deployment guide
- [Contract Interfaces](./contracts/interfaces/) - API documentation
- [Test Files](./test/) - Comprehensive test coverage

### API Reference
All public functions are documented in the contract interfaces:
- `IProviderSubscriber.sol` - Main interface
- `ProviderErrors.sol` - Error definitions
- `ProviderEvents.sol` - Event definitions

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

### Code Standards
- Follow Solidity style guide
- Add comprehensive tests
- Document all public functions
- Use meaningful variable names
- Add proper error handling

## License

This project is licensed under the BUSL-1.1 License - see the [LICENSE](./LICENSE) file for details.

## Assignment Compliance

This project fully complies with all assignment requirements:

### Functional Requirements Met
- Provider registration with minimum $50 fee
- Subscriber registration with minimum $100 deposit
- Subscription management and pausing
- Monthly billing and earnings withdrawal
- Provider state management
- Comprehensive view functions

### Technical Requirements Met
- Upgradeable contract architecture
- Chainlink integration for USD conversion
- Access control and security measures
- Gas-efficient implementations
- Comprehensive error handling

### Bonus Features Implemented
- Advanced subscription management
- Comprehensive test coverage
- Multi-network deployment support
- Detailed documentation
- Production-ready architecture

## Getting Started

1. **Install Dependencies**: `npm install`
2. **Compile Contracts**: `npm run compile`
3. **Run Tests**: `npm run test`
4. **Deploy Locally**: `npm run deploy:full`
5. **Start Development**: `npm run node`

For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md).

---

**Built with Hardhat, OpenZeppelin, and Chainlink**
