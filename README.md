# Urbane Stablecoin

Urbane Stablecoin is a fiat-pegged cryptocurrency built on the Ethereum blockchain using Solidity. It utilizes a dual-collateral system with USDT (Tether) as the stable collateral and ETH (Ethereum) as the unstable collateral.

## Features

- Fiat-pegged: Maintains a stable value relative to a specified fiat currency
- Dual-collateral system: Uses both USDT and ETH as collateral
- Built on Ethereum: Leverages the security and ecosystem of the Ethereum blockchain
- Smart contract-based: Implements core functionality through Solidity smart contracts

## Prerequisites

- Node.js (v14.0.0 or later)
- npm (v6.0.0 or later)
- Hardhat
- MetaMask or another Ethereum wallet
- Access to an Ethereum node (local or via a service like Infura)

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/adityar2705/urbane-stablecoin.git
   cd urbane-stablecoin
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Compile the smart contracts:
   ```
   npx hardhat compile
   ```

4. Run tests:
   ```
   npx hardhat test
   ```

5. Deploy the contracts to your chosen network:
   ```
   npx hardhat run scripts/deploy.js --network <network_name>
   ```

## Configuration

Create a `.env` file in the root directory with the following content:

```
INFURA_PROJECT_ID=your_infura_project_id
PRIVATE_KEY=your_wallet_private_key
```

Make sure to replace `your_infura_project_id` and `your_wallet_private_key` with your actual Infura project ID and wallet private key.

## Usage

(Add specific instructions on how to interact with your stablecoin, such as minting, redeeming, or transferring tokens)

## Development

To run a local Hardhat network:

```
npx hardhat node
```

To deploy to the local network:

```
npx hardhat run scripts/deploy.js --network localhost
```

## Testing

Run the test suite:

```
npx hardhat test
```

For test coverage:

```
npx hardhat coverage
```

## Security

This project is experimental and has not been audited. Use at your own risk.

## Contributing

We welcome contributions to the Urbane Stablecoin project. Please read our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- OpenZeppelin for their secure smart contract libraries
- The Ethereum and Hardhat communities for their invaluable resources and documentation
