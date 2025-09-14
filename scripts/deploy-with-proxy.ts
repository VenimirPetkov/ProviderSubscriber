import { deployContract } from '@nomicfoundation/hardhat-ignition/modules';

const MOCK_TOKEN_NAME = 'TestToken';
const MOCK_TOKEN_SYMBOL = 'TT';
const MOCK_TOKEN_SUPPLY = '1000000000000000000000000';
const MOCK_PRICE_FEED_PRICE = '200000000000';

const mockToken = deployContract('MockERC20', {
  args: [MOCK_TOKEN_NAME, MOCK_TOKEN_SYMBOL, MOCK_TOKEN_SUPPLY],
});

const mockPriceFeed = deployContract('MockPriceFeed', {
  args: [MOCK_PRICE_FEED_PRICE],
});

const implementation = deployContract('ProviderSubscriberSystem', {
  args: [mockToken.address, mockPriceFeed.address],
});

export default deployContract('ProviderSubscriberProxy', {
  args: [implementation.address, '0x'],
});
