/**
 * Deployment Configuration for Provider-Subscriber System
 *
 * This configuration defines all the parameters needed for deploying
 * the Provider-Subscriber system according to the assignment requirements.
 */

// Mock contracts configuration for testing
export const MOCK_CONTRACTS = {
  TOKEN: {
    NAME: 'TestToken',
    SYMBOL: 'TT',
    SUPPLY: '1000000000000000000000000', // 1M tokens with 18 decimals
  },
  LINK_TOKEN: {
    NAME: 'Mock ChainLink Token',
    SYMBOL: 'LINK',
    SUPPLY: '1000000000000000000000000', // 1M LINK tokens with 18 decimals
  },
  PRICE_FEED: {
    PRICE: '200000000000', // $2000 with 8 decimals (Chainlink format)
  },
} as const;

// Contract initialization parameters based on assignment requirements
export const CONTRACT_PARAMS = {
  MIN_FEE_USD: '5000000000', // $50 with 8 decimals (Chainlink format)
  MIN_DEPOSIT_USD: '10000000000', // $100 with 8 decimals (Chainlink format)
  MAX_PROVIDERS: 200, // Maximum number of providers as per assignment
  MONTH_DURATION_BLOCKS: 216000, // ~1 month in blocks (ETH: ~12 seconds per block, 30 days)
} as const;

// Network-specific configurations
export const NETWORK_CONFIG = {
  localhost: {
    PAYMENT_TOKEN: '0x1234567890123456789012345678901234567890', // Will be replaced with deployed mock LINK token
    PRICE_FEED: '0x1234567890123456789012345678901234567890', // Will be replaced with deployed mock price feed
  },
  hoodi: {
    PAYMENT_TOKEN: '0x1234567890123456789012345678901234567890', // Will be replaced with deployed mock LINK token
    PRICE_FEED: '0x1234567890123456789012345678901234567890', // Will be replaced with deployed mock price feed
  },
  mainnet: {
    PAYMENT_TOKEN: '0x1234567890123456789012345678901234567890', // Replace with actual mainnet token address
    PRICE_FEED: '0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c', // Chainlink LINK/USD aggregator on mainnet
  },
  mainnetFork: {
    PAYMENT_TOKEN: '0x1234567890123456789012345678901234567890', // Replace with actual mainnet token address
    PRICE_FEED: '0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c', // Chainlink LINK/USD aggregator on mainnet
  },
} as const;

// Legacy export for backward compatibility
export const DEPLOYMENT_CONFIG = {
  MOCK_TOKEN: MOCK_CONTRACTS.TOKEN,
  MOCK_LINK_TOKEN: MOCK_CONTRACTS.LINK_TOKEN,
  MOCK_PRICE_FEED: MOCK_CONTRACTS.PRICE_FEED,
  CONTRACT_PARAMS,
  NETWORKS: NETWORK_CONFIG,
  DEPLOYMENT_ORDER: [
    'MockERC20',
    'MockLinkToken',
    'MockPriceFeed',
    'ProviderSubscriberSystem',
    'ProviderSubscriberProxy',
  ],
} as const;
