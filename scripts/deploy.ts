import { deployContract } from '@nomicfoundation/hardhat-ignition/modules';
import { DEPLOYMENT_CONFIG } from './deploy-config';

// Extract addresses from configuration
const PAYMENT_TOKEN_ADDRESS = DEPLOYMENT_CONFIG.NETWORKS.localhost.PAYMENT_TOKEN;
const CHAINLINK_PRICE_FEED_ADDRESS = DEPLOYMENT_CONFIG.NETWORKS.localhost.PRICE_FEED;

export default deployContract('ProviderSubscriberSystem', {
  args: [PAYMENT_TOKEN_ADDRESS, CHAINLINK_PRICE_FEED_ADDRESS],
});
