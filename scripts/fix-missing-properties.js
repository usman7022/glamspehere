const fs = require('fs');
const path = require('path');

// Category name to slug mapping
const categoryMapping = {
  'Nail Art & Care': 'nail-art--care',
  'Acrylic Nails': 'acrylic-nails',
  'Gel Nails': 'gel-nails',
  'Holiday Nail Ideas': 'holiday-nail-ideas',
  'Nail Trends': 'nail-trends',
  'Nail Tutorials': 'nail-tutorials',
  'Makeup & Skincare': 'makeup--skincare',
  'Makeup Tutorials': 'makeup-tutorials',
  'Skincare Reviews': 'skincare-reviews',
  'Holiday Glam': 'holiday-glam',
  'Face Makeup': 'face-makeup',
  'Eye Makeup': 'eye-makeup',
  'Hair Care & Styling': 'hair-care--styling',
  'Shampoos & Conditioners': 'shampoos--conditioners',
  'Hair Styling Tools': 'hair-styling-tools',
  'Hair Trends': 'hair-trends',
  'Braid Ideas': 'braid-ideas',
  'Hair Care Tips': 'hair-care-tips',
  'Fashion & Style': 'fashion--style',
  'Style Guides': 'style-guides',
  'Celebrity Fashion': 'celebrity-fashion',
  'Holiday Fashion': 'holiday-fashion',
  'Fashion Trends': 'fashion-trends',
  'Accessories': 'accessories'
};

function processFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Find the post object
  const postMatch = content.match(/const post = \{[\s\S]*?\n  \}/m);
  if (!postMatch) {
    console.log(`⚠️  No post object found in ${filePath}`);
    return;
  }
  
  const postObject = postMatch[0];
  
  // Check if content and categorySlug already exist
  if (postObject.includes('"content":') && postObject.includes('"categorySlug":')) {
    console.log(`✓ Already fixed: ${filePath}`);
    return;
  }
  
  // Extract category name
  const categoryMatch = postObject.match(/"category":\s*"([^"]+)"/);
  if (!categoryMatch) {
    console.log(`⚠️  No category found in ${filePath}`);
    return;
  }
  
  const categoryName = categoryMatch[1];
  const categorySlug = categoryMapping[categoryName];
  
  if (!categorySlug) {
    console.log(`⚠️  No slug mapping for category "${categoryName}" in ${filePath}`);
    return;
  }
  
  // Find the position to insert the new properties (after excerpt)
  const excerptMatch = postObject.match(/"excerpt":\s*"[^"]*",/);
  if (!excerptMatch) {
    console.log(`⚠️  No excerpt found in ${filePath}`);
    return;
  }
  
  // Build the replacement - add content and categorySlug after excerpt
  const newPostObject = postObject.replace(
    /"excerpt":\s*"([^"]*)",/,
    `"excerpt": "$1",\n  "content": "",\n  "categorySlug": "${categorySlug}",`
  );
  
  // Replace in the full content
  const newContent = content.replace(postObject, newPostObject);
  
  // Write back to file
  fs.writeFileSync(filePath, newContent, 'utf8');
  console.log(`✓ Fixed: ${filePath}`);
}

function findAllBlogFiles(dir) {
  const blogDir = path.join(dir, 'app', 'blog');
  const entries = fs.readdirSync(blogDir, { withFileTypes: true });
  const files = [];
  
  for (const entry of entries) {
    if (entry.isDirectory() && entry.name !== '[slug]') {
      const pagePath = path.join(blogDir, entry.name, 'page.tsx');
      if (fs.existsSync(pagePath)) {
        files.push(pagePath);
      }
    }
  }
  
  return files;
}

// Main execution
const projectRoot = path.resolve(__dirname, '..');
console.log(`🔍 Searching for blog files in: ${projectRoot}`);

const blogFiles = findAllBlogFiles(projectRoot);
console.log(`📝 Found ${blogFiles.length} blog files\n`);

let fixed = 0;
let alreadyFixed = 0;
let errors = 0;

blogFiles.forEach((file) => {
  try {
    const beforeContent = fs.readFileSync(file, 'utf8');
    processFile(file);
    const afterContent = fs.readFileSync(file, 'utf8');
    
    if (beforeContent !== afterContent) {
      fixed++;
    } else if (afterContent.includes('"content":') && afterContent.includes('"categorySlug":')) {
      alreadyFixed++;
    }
  } catch (error) {
    console.error(`❌ Error processing ${file}: ${error.message}`);
    errors++;
  }
});

console.log(`\n📊 Summary:`);
console.log(`   ✓ Fixed: ${fixed}`);
console.log(`   ✓ Already fixed: ${alreadyFixed}`);
console.log(`   ❌ Errors: ${errors}`);
console.log(`   📝 Total: ${blogFiles.length}`);
