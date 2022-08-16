const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const addressArray = [
  "0xdDf0970237F4063Eee17aac2b4ED0c66A32c0F81",
  "0x1E694e8fEFD9CfDf50300bA6A9db13a92e3d4AA9",
  "0x46c908f72f2e492Cf9fd054b4C82826AfdE23Ec9",
  "0x30D51930DF7EB0eb4e99C847e0E163451D6fFb1D",
  "0xB8160841b28871eb07C98Ec072Bb19Aa586940Ac",
  "0xf644E9c4C342C200c21eb1A474327d447F284625",
  "0x6Bc3Ce9928A6b3754C4C57e5F831B686089df9D3",
  "0xdf8962bCF5Ff744d15da562630DCBf2305eA12f3",
  "0x44C028313b9F51Fa617205357B3d8715CB4F6FeF",
  "0x089FBB7606b0a720A205FBE2844245ae0ECC447B",
  "0xc133E25C2AB8c48137C2425bda0D25DCe12a49d4",
  "0xD470b76eb23d18D29b3D8CA35172d0687B26c5f2",
  "0xb6aa5fd1b873f053e64009632fb90e5619539442",
  "0xa23C72E858f7cC7aEd380F24E1fAfe2338Ed49dF",
  "0x3C8d0b84dE22f5c87F27d7C5c459295E6E73bcCD",
  "0x693B22b3DD3f09A40627d8Ce2C07a3714f8b6Bf8",
  "0x8a067Ec3Ed65d685038ce11d10c1040a6B161Eb1",
  "0x1Bd3bD690959265e44d5ae261028f2E952983863",
  "0xc14ddf7b433eb432c07b1865eb2c28ace5deb167",
  "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
  "0xBF4979305B43B0eB5Bb6a5C67ffB89408803d3e1",
];

const buf2hex = (x) => "0x" + x.toString("hex");

const leaves = addressArray.map((x) => keccak256(x));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const root = "0x" + tree.getRoot().toString("hex");

const leaf = keccak256(addressArray[20]).toString("hex");
const proof = tree.getProof(leaf).map((x) => buf2hex(x.data));

console.log(`Root - ${root}`);
console.log(`leaf - ${leaf}`);
console.log(`proof - ${proof}`);
