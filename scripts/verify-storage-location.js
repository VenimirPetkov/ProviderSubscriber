const { ethers } = require('ethers');

function verifyStorageLocation() {
  const namespace = 'provider-subscriber-system.storage';

  const hash1 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(namespace));
  console.log('Step 1 - Namespace hash:', hash1);

  const hash1BigInt = BigInt(hash1);
  const subtracted = hash1BigInt - 1n;
  console.log('Step 2 - Subtracted value:', subtracted.toString());

  const encoded = ethers.utils.defaultAbiCoder.encode(['uint256'], [subtracted.toString()]);
  console.log('Step 3 - Encoded value:', encoded);

  const hash2 = ethers.utils.keccak256(encoded);
  console.log('Step 4 - Final hash:', hash2);

  const hash2BigInt = BigInt(hash2);
  const cleared = hash2BigInt & ~0xffn;
  const finalLocation = '0x' + cleared.toString(16).padStart(64, '0');
  console.log('Step 5 - Final storage location:', finalLocation);

  const providedLocation = '0x6ebb7e5c7906aae7c8d14cd68b97a9303a15fbe348f662c6d553b0e85a973200';
  console.log('Provided constant:', providedLocation);
  console.log('Match:', finalLocation.toLowerCase() === providedLocation.toLowerCase());

  return finalLocation;
}

console.log('=== EIP-7201 Storage Location Verification ===');
verifyStorageLocation();
