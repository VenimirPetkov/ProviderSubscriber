import hre from 'hardhat';
import { CONTRACT_PARAMS } from '../deploy-config.js';

/**
 * Script to initialize a deployed proxy contract
 * Usage: npx hardhat run scripts/initialize-deployed-proxy.ts --network <network>
 *
 * Set these environment variables:
 * - PROXY_ADDRESS: The address of the deployed proxy
 * - MOCK_TOKEN_ADDRESS: The address of the deployed mock token
 * - MOCK_PRICE_FEED_ADDRESS: The address of the deployed mock price feed
 */
async function initializeDeployedProxy() {
  const [deployer] = await hre.ethers.getSigners();

  console.log('Initializing proxy with account:', deployer.address);
  console.log(
    'Account balance:',
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  // Get the deployed proxy contract address
  const proxyAddress = process.env.PROXY_ADDRESS;
  if (!proxyAddress) {
    throw new Error('PROXY_ADDRESS environment variable is required');
  }

  // Get the mock token and price feed addresses
  const mockTokenAddress = process.env.MOCK_TOKEN_ADDRESS;
  const mockPriceFeedAddress = process.env.MOCK_PRICE_FEED_ADDRESS;

  if (!mockTokenAddress || !mockPriceFeedAddress) {
    throw new Error(
      'MOCK_TOKEN_ADDRESS and MOCK_PRICE_FEED_ADDRESS environment variables are required'
    );
  }

  console.log('Initializing proxy with:');
  console.log('- Proxy Address:', proxyAddress);
  console.log('- Payment Token:', mockTokenAddress);
  console.log('- Price Feed:', mockPriceFeedAddress);
  console.log('- Min Fee USD:', CONTRACT_PARAMS.MIN_FEE_USD);
  console.log('- Min Deposit USD:', CONTRACT_PARAMS.MIN_DEPOSIT_USD);
  console.log('- Max Providers:', CONTRACT_PARAMS.MAX_PROVIDERS);
  console.log('- Month Duration Blocks:', CONTRACT_PARAMS.MONTH_DURATION_BLOCKS);

  // Get the contract factory and attach to the proxy
  const ProviderSubscriberSystem = await hre.ethers.getContractFactory(
    'ProviderSubscriberSystem'
  );
  const proxy = ProviderSubscriberSystem.attach(proxyAddress);

  // Check if already initialized
  try {
    const owner = await proxy.owner();
    console.log('Contract is already initialized. Owner:', owner);
    return;
  } catch (error) {
    console.log(
      'Contract not initialized yet, proceeding with initialization...'
    );
  }

  // Initialize the proxy
  const tx = await proxy.initialize(
    mockTokenAddress,
    mockPriceFeedAddress,
    CONTRACT_PARAMS.MIN_FEE_USD,
    CONTRACT_PARAMS.MIN_DEPOSIT_USD,
    CONTRACT_PARAMS.MAX_PROVIDERS,
    CONTRACT_PARAMS.MONTH_DURATION_BLOCKS
  );

  console.log('Initialization transaction sent:', tx.hash);
  const receipt = await tx.wait();
  console.log(
    'Initialization transaction confirmed in block:',
    receipt.blockNumber
  );

  // Verify the initialization
  const owner = await proxy.owner();
  const maxProviders = await proxy.getMaxProviders();
  const minFeeUsd = await proxy.getMinFeeUsd();
  const minDepositUsd = await proxy.getMinDepositUsd();
  const monthDuration = await proxy.getMonthDurationInBlocks();

  console.log('\n✅ Proxy initialized successfully!');
  console.log('Verification:');
  console.log('- Owner:', owner);
  console.log('- Max Providers:', maxProviders.toString());
  console.log('- Min Fee USD:', minFeeUsd.toString());
  console.log('- Min Deposit USD:', minDepositUsd.toString());
  console.log('- Month Duration Blocks:', monthDuration.toString());

  console.log('\n📋 Contract addresses:');
  console.log('- Proxy:', proxyAddress);
  console.log('- Mock Token:', mockTokenAddress);
  console.log('- Mock Price Feed:', mockPriceFeedAddress);
}

// Run the initialization
initializeDeployedProxy()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('❌ Initialization failed:', error);
    process.exit(1);
  });
