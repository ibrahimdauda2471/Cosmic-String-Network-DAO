import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mint(name: string, description: string, simulationId: number, imageUrl: string, creator: string) {
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    name,
    description,
    creator,
    simulationId,
    imageUrl,
    timestamp: Date.now()
  });
  tokenOwners.set(tokenId, creator);
  return tokenId;
}

function transfer(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Cosmic String NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new cosmic string NFT', () => {
    const tokenId = mint('Cosmic String Loop', 'A unique cosmic string loop configuration', 1, 'https://example.com/cosmic-string-loop.png', 'creator1');
    expect(tokenId).toBe(1);
    expect(tokenOwners.get(tokenId)).toBe('creator1');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.name).toBe('Cosmic String Loop');
    expect(metadata.simulationId).toBe(1);
  });
  
  it('should transfer an NFT', () => {
    const tokenId = mint('String Network Node', 'A significant node in the cosmic string network', 2, 'https://example.com/string-network-node.png', 'creator2');
    expect(transfer(tokenId, 'creator2', 'collector1')).toBe(true);
    expect(tokenOwners.get(tokenId)).toBe('collector1');
  });
  
  it('should not allow unauthorized transfer', () => {
    const tokenId = mint('Cosmic String Intersection', 'A rare intersection of cosmic strings', 3, 'https://example.com/string-intersection.png', 'creator3');
    expect(() => transfer(tokenId, 'unauthorized_user', 'collector2')).toThrow('Not authorized');
  });
  
  it('should store correct metadata', () => {
    const imageUrl = 'https://example.com/string-evolution.png';
    const tokenId = mint('String Evolution Snapshot', 'A snapshot of cosmic string network evolution', 4, imageUrl, 'creator4');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.imageUrl).toBe(imageUrl);
    expect(metadata.creator).toBe('creator4');
    expect(metadata.timestamp).toBeLessThanOrEqual(Date.now());
  });
});

