import type { HardhatUserConfig } from 'hardhat/config';

import hardhatToolboxViemPlugin from '@nomicfoundation/hardhat-toolbox-viem';
import { configVariable } from 'hardhat/config';

const config: HardhatUserConfig = {
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    profiles: {
      default: {
        version: '0.8.28',
      },
      production: {
        version: '0.8.28',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: 'edr-simulated',
      chainType: 'l1',
    },
    hardhatOp: {
      type: 'edr-simulated',
      chainType: 'op',
    },
    hoodi: {
      type: 'http',
      chainType: 'l1',
      url: configVariable('HOODI_RPC_URL'),
      accounts: [configVariable('HOODI_PRIVATE_KEY')],
    },
    mainnet: {
      type: 'http',
      chainType: 'l1',
      url: configVariable('MAINNET_RPC_URL'),
      accounts: [configVariable('MAINNET_PRIVATE_KEY')],
    },
    mainnetFork: {
      type: 'http',
      chainType: 'l1',
      url: 'http://127.0.0.1:8545',
      accounts: [configVariable('MAINNET_FORK_PRIVATE_KEY')],
    },
  },
};

export default config;
