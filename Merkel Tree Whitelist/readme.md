![Cover](https://res.cloudinary.com/practicaldev/image/fetch/s--XbHknY5M--/c_imagga_scale,f_auto,fl_progressive,h_420,q_auto,w_1000/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6151ls8g0r8p42vp5p0a.png)

## What is a Merkle Tree?

A "hash tree" or "Merkle tree" is a type of tree used in cryptography and computer science where each "leaf" (node) is labelled with the cryptographic hash of a data block and every other node (referred to as a "_branch_," "_inner node_," or "_inode_") is labelled with the cryptographic hash of the labels of its child nodes. A hash tree makes it possible to quickly and securely check the contents of a big data structure.

If this is too much, don't worry. With the aid of visuals and benefits, we shall demystify Merkle trees in this post.

1.  A Merkle tree is a **collision-resistant hash function**, denoted by MHT, that takes n inputs (x<sub>1</sub>,…,x<sub>n</sub>) and outputs a *Merkle root hash* h=MHT(x<sub>1</sub>,…,x<sub>n</sub>).
2.  A verifier who only has the root hash h can be given an x<sub>i</sub> and an associated **Merkle proof** which convinces them that x<sub>i</sub> was the i<sup>th</sup> input used to compute h.
3.  1.  If a Merkle proof says that x<sub>i</sub> was the i<sup>th</sup> input used to computed h, no attacker can come up with another Merkle proof that says a different x<sup>'</sup><sub>i</sub> ≠x<sub>i</sub> was the i<sup>th</sup> input.

---

## How Merkle Tree Works

Assume you have n=8 files, represented by (f<sub>1</sub>, f<sub>2</sub>,..., f<sub>8</sub>), and that your hash function (H) is collision-resistant let's say `keccak256`.

You start by hashing each file as h<sub>i</sub>=H(f<sub>i</sub>):

![Stage 1](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/c8594zylwi8iaffkgpnw.png)

You could continue to hash every two adjacent hashes:

![Stage 2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0q6movs0rm0oqwxrekji.png)

You could even continue on these newly obtained hashes:

![Stage 3](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hbejawgezte3ri6tf1n7.png)

In the end you hash these last two hashes as h<sub>1,8</sub>=H(h<sub>1,4</sub>,h<sub>4,8</sub>) :

![Stage 4](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qgr0xy8xcrauwcfrvhwg.png)

**Congratulations!** What you have done is computed a Merkle tree on n=8n=8 **leaves**, as depicted in the picture above.

Note that every **node** in the tree stores a hash:

- The i<sup>th</sup> **leaf** of the tree stores the hash h<sub>i</sub> of the file f<sub>i</sub>.
- Each **internal node** of the tree stores the hash of its two children.
- The h<sub>1,8</sub> hash stored in the **root node** is called the **Merkle root hash**.

---

## What is a Merkle proof !

The **key idea** is that, after you download f<sub>i</sub>, you ask for a small part of the Merkle tree called a **Merkle proof**. This proof enables you to verify that the downloaded f<sub>i</sub> was not accidentally or maliciously modified.

![Proof](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/d38em0h1nidpx0vyp5nu.png)

Well, observe that the Merkle proof for f<sub>i</sub> is exactly the subset of hashes in the Merkle tree that, together with f<sub>i</sub>, allow you to recompute the root hash of the Merkle tree and check it matches the real hash h<sub>1,8</sub>, **without knowing any of the other hashed files**.

So, to verify the proof, you simply “fill in the blanks” in the picture above by computing the missing hashes depicted with dotted boxes.

Lastly, you check that the Merkle root  you computed above is equal to the Merkle root  you kept locally! If that’s the case, then you can be sure you downloaded the correct f<sub>i</sub>.

---

## How to Implement a Basic Merkle Tree Whitelist in NFT Contract.

It is rather difficult to produce a merkle tree on your own, but don't worry; we'll utilise a javascript package called `merkletreejs` to build a merkle tree as well as generate and check proofs.
Our collision-resistant hash function is the keccak256 hashing method.

Install both requirements with the following command.

```bash
npm i merkletreejs
npm i keccak256
```

Add the dependencies to a new file called `MerkelTree.js`.

```js
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
```

Let's say you have a list of addresses you wish to whitelist in your NFT project. Let's put those addresses in a variable called `addressArray`, an array.

```js
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
```

Let's now create the function buf2hex, which changes the buffer to Hexadecimal.

```js
const buf2hex = (x) => "0x" + x.toString("hex");
```

We must first obtain our leaves in order to create a tree, which we can do by mapping through our Array hashing our address with the keccak256 method.

```js
const leaves = addressArray.map((x) => keccak256(x));
```

Now, in order to create a tree, we use the code below, which first sorts our array before creating a Merkel Tree.

```js
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
```

then after that, using the following command, we can find the tree's root.

```js
const root = "0x" + tree.getRoot().toString("hex");
```

Let's say I want to obtain the last address and the proof associated with it.

```js
const leaf = keccak256(addressArray[20]).toString("hex");
const proof = tree.getProof(leaf).map((x) => buf2hex(x.data));
```

Now we log all the details

```js
console.log(`Root - ${root}`);
console.log(`leaf - ${leaf}`);
console.log(`proof - ${proof}`);
```

The output should look something like this when you run the file using `node MerkelTree.js`

```bash
Root - 0x5980c4cba5c7b181167b84183d5b89fd64f1ed01b12ddf12084f2a77d9913c8e
leaf - bae7d1c1447829a0dc7a735041e74fdf7082a238aa8b45b06e550dfce99f5715
proof - 0xd6385235429df428dad417201312f0724220673f2a6956be471426bb77a2c87e,0x363e3bb0c286106f6a19aea117f3dbedb3c3a376b4fd8c31254f9ba86b842366
```

---

## Implementing Merkel Tree in our Smart Contract

First, use the [Openzeppelin Contract Wizard](https://docs.openzeppelin.com/contracts/4.x/wizard) to create a Basic ERC-721 Smart contract.

The Merkel Tree file from Openzeppelin must first be imported. Add the following line beneath your imports to accomplish this.

```solidity
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
```

Additionally, we must introduce some state variables and modify our constructor to include some arguments, such as the Merkel Tree's "root" and the "baseURI" for the contract. The code below will enable us to achieve that.

```solidity
uint public maxSupply = 10000;
    string internal uri;
    bytes32 public root;

    constructor(string memory baseURI, bytes32 _root) ERC721("Merkeltree", "MKT") {
        root = _root;
        _tokenIdCounter.increment();
        uri = baseURI;
    }
```

We must now write a function named "isWhitelisted" that accepts two arguments in order to determine whether the user is whitelisted or not.

1. The `leaf`
2. `proof` associated with that leaf

A boolean value, either true or false, is returned by the function.

```solidity
function isWhitelisted(bytes32[] memory proof, bytes32 leaf) public view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
```

Last but not least, we just need to change our mint function so that it accepts the proof of the "leaf" associated to "msg.sender" to implement whitelist.

```solidity
function mint(bytes32[] memory proof) public {
        require(isWhitelisted(proof, keccak256(abi.encodePacked(msg.sender))), "Not a part of Whitelist");
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= maxSupply,"All NFTs have been Minted");
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }
```

And that is how you add a whitelist to your smart contract. If you wish to add or remove people, you can also add a function to alter the Merkel Tree's root.

---
