import { buildModule } from '@nomicfoundation/ignition-core';
import { MOCK_CONTRACTS, CONTRACT_PARAMS } from '../../deploy-config.js';

/**
 * Provider-Subscriber System Deployment Module
 *
 * This module deploys the complete Provider-Subscriber system including:
 * - Mock ERC20 token for testing
 * - Mock Chainlink price feed for testing
 * - ProviderSubscriberSystem implementation contract
 * - ProviderSubscriberProxy for upgradeability
 *
 * The proxy is deployed with empty initialization data and must be
 * initialized separately using the initialization script.
 */
export default buildModule('ProviderSubscriber', m => {
  // Deploy mock ERC20 token for testing
  const mockToken = m.contract(
    'MockERC20',
    [
      MOCK_CONTRACTS.TOKEN.NAME,
      MOCK_CONTRACTS.TOKEN.SYMBOL,
      MOCK_CONTRACTS.TOKEN.SUPPLY,
    ],
    { id: 'MockERC20' }
  );

  // Deploy mock LINK token for testing
  const mockLinkToken = m.contract(
    'MockERC20',
    [
      MOCK_CONTRACTS.LINK_TOKEN.NAME,
      MOCK_CONTRACTS.LINK_TOKEN.SYMBOL,
      MOCK_CONTRACTS.LINK_TOKEN.SUPPLY,
    ],
    { id: 'MockLinkToken' }
  );

  // Deploy mock Chainlink price feed for testing
  const mockPriceFeed = m.contract(
    'MockPriceFeed',
    [MOCK_CONTRACTS.PRICE_FEED.PRICE],
    { id: 'MockPriceFeed' }
  );

  // Deploy the implementation contract (no constructor parameters for upgradeable contracts)
  const implementation = m.contract('ProviderSubscriberSystem', [], {
    id: 'ProviderSubscriberSystem',
  });

  // Deploy the proxy with empty initialization data
  // The proxy will need to be initialized separately after deployment
  const proxy = m.contract('ProviderSubscriberProxy', [implementation, '0x'], {
    id: 'ProviderSubscriberProxy',
  });

  return {
    mockToken,
    mockLinkToken,
    mockPriceFeed,
    implementation,
    proxy,
  };
});
