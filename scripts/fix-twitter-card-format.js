const fs = require('fs');
const path = require('path');

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Check if it already has summary card
  if (content.includes('"card": "summary"') && !content.includes('"card": "summary_large_image"')) {
    console.log(`✓ Already has summary card: ${filePath}`);
    return false;
  }
  
  // Replace summary_large_image with summary
  const newContent = content.replace(
    /"card": "summary_large_image"/g,
    '"card": "summary"'
  );
  
  if (content !== newContent) {
    fs.writeFileSync(filePath, newContent, 'utf8');
    console.log(`✓ Fixed: ${filePath}`);
    return true;
  }
  
  return false;
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
    const wasFixed = processFile(file);
    if (wasFixed) {
      fixed++;
    } else {
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
console.log(`\n✨ Twitter cards will now show: Image on LEFT + Title/Description on RIGHT`);
