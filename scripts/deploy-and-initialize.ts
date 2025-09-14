import hre from 'hardhat';
import { CONTRACT_PARAMS, MOCK_CONTRACTS } from '../deploy-config.js';

/**
 * Complete Deployment and Initialization Script
 *
 * This script deploys the Provider-Subscriber system and automatically
 * initializes the proxy contract in one go.
 *
 * Usage: npx hardhat run scripts/deploy-and-initialize.ts --network <network>
 */
async function deployAndInitialize() {
  const [deployer] = await hre.ethers.getSigners();

  console.log('Starting Provider-Subscriber System Deployment');
  console.log('Deployer:', deployer.address);
  console.log('Network:', hre.network.name);
  console.log(
    'Account balance:',
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  // Deploy mock ERC20 token
  console.log('\nDeploying MockERC20...');
  const MockERC20 = await hre.ethers.getContractFactory('MockERC20');
  const mockToken = await MockERC20.deploy(
    MOCK_CONTRACTS.TOKEN.NAME,
    MOCK_CONTRACTS.TOKEN.SYMBOL,
    MOCK_CONTRACTS.TOKEN.SUPPLY
  );
  await mockToken.waitForDeployment();
  const mockTokenAddress = await mockToken.getAddress();
  console.log('MockERC20 deployed at:', mockTokenAddress);

  // Deploy mock LINK token
  console.log('\nDeploying Mock LINK Token...');
  const mockLinkToken = await MockERC20.deploy(
    MOCK_CONTRACTS.LINK_TOKEN.NAME,
    MOCK_CONTRACTS.LINK_TOKEN.SYMBOL,
    MOCK_CONTRACTS.LINK_TOKEN.SUPPLY
  );
  await mockLinkToken.waitForDeployment();
  const mockLinkTokenAddress = await mockLinkToken.getAddress();
  console.log('Mock LINK Token deployed at:', mockLinkTokenAddress);

  // Deploy mock price feed
  console.log('\nDeploying MockPriceFeed...');
  const MockPriceFeed = await hre.ethers.getContractFactory('MockPriceFeed');
  const mockPriceFeed = await MockPriceFeed.deploy(
    MOCK_CONTRACTS.PRICE_FEED.PRICE
  );
  await mockPriceFeed.waitForDeployment();
  const mockPriceFeedAddress = await mockPriceFeed.getAddress();
  console.log('MockPriceFeed deployed at:', mockPriceFeedAddress);

  // Deploy implementation contract
  console.log('\nDeploying ProviderSubscriberSystem...');
  const ProviderSubscriberSystem = await hre.ethers.getContractFactory(
    'ProviderSubscriberSystem'
  );
  const implementation = await ProviderSubscriberSystem.deploy();
  await implementation.waitForDeployment();
  const implementationAddress = await implementation.getAddress();
  console.log('ProviderSubscriberSystem deployed at:', implementationAddress);

  // Deploy proxy contract
  console.log('\nDeploying ProviderSubscriberProxy...');
  const ProviderSubscriberProxy = await hre.ethers.getContractFactory(
    'ProviderSubscriberProxy'
  );
  const proxy = await ProviderSubscriberProxy.deploy(
    implementationAddress,
    '0x'
  );
  await proxy.waitForDeployment();
  const proxyAddress = await proxy.getAddress();
  console.log('ProviderSubscriberProxy deployed at:', proxyAddress);

  // Initialize the proxy
  console.log('\nInitializing proxy contract...');
  const proxyContract = ProviderSubscriberSystem.attach(proxyAddress);

  const initTx = await proxyContract.initialize(
    mockTokenAddress,
    mockPriceFeedAddress,
    CONTRACT_PARAMS.MIN_FEE_USD,
    CONTRACT_PARAMS.MIN_DEPOSIT_USD,
    CONTRACT_PARAMS.MAX_PROVIDERS,
    CONTRACT_PARAMS.MONTH_DURATION_BLOCKS
  );

  console.log('Initialization transaction sent:', initTx.hash);
  await initTx.wait();
  console.log('Proxy initialized successfully!');

  // Verify the deployment
  console.log('\nVerifying deployment...');
  const owner = await proxyContract.owner();
  const maxProviders = await proxyContract.getMaxProviders();
  const minFeeUsd = await proxyContract.getMinFeeUsd();
  const minDepositUsd = await proxyContract.getMinDepositUsd();
  const monthDuration = await proxyContract.getMonthDurationInBlocks();

  console.log('\nDeployment completed successfully!');
  console.log('\nContract Addresses:');
  console.log('- MockERC20:', mockTokenAddress);
  console.log('- Mock LINK Token:', mockLinkTokenAddress);
  console.log('- MockPriceFeed:', mockPriceFeedAddress);
  console.log('- ProviderSubscriberSystem:', implementationAddress);
  console.log('- ProviderSubscriberProxy:', proxyAddress);

  console.log('\nConfiguration:');
  console.log('- Owner:', owner);
  console.log('- Max Providers:', maxProviders.toString());
  console.log('- Min Fee USD:', minFeeUsd.toString());
  console.log('- Min Deposit USD:', minDepositUsd.toString());
  console.log('- Month Duration Blocks:', monthDuration.toString());

  console.log('\nNext Steps:');
  console.log('1. Use the proxy address for all contract interactions');
  console.log('2. Verify contracts on block explorer if needed');
  console.log('3. Test the contract functionality');
}

// Run the deployment
deployAndInitialize()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('Deployment failed:', error);
    process.exit(1);
  });
