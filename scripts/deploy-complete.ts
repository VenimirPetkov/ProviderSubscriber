import { deployContract } from '@nomicfoundation/hardhat-ignition/modules';
import { DEPLOYMENT_CONFIG } from './deploy-config';

const mockToken = deployContract('MockERC20', {
  args: [
    DEPLOYMENT_CONFIG.MOCK_TOKEN.NAME,
    DEPLOYMENT_CONFIG.MOCK_TOKEN.SYMBOL,
    DEPLOYMENT_CONFIG.MOCK_TOKEN.SUPPLY,
  ],
});

const mockPriceFeed = deployContract('MockPriceFeed', {
  args: [DEPLOYMENT_CONFIG.MOCK_PRICE_FEED.PRICE],
});

export default deployContract('ProviderSubscriberSystem', {
  args: [mockToken.address, mockPriceFeed.address],
});
