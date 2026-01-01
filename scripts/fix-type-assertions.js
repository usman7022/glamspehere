const fs = require('fs');
const path = require('path');

function processFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Check if it already has the import
  if (content.includes('import type { BlogPost }')) {
    console.log(`✓ Already has type import: ${filePath}`);
    return;
  }
  
  // Add the import after the metadata import
  const importRegex = /import type \{ Metadata \} from "next"/;
  if (!importRegex.test(content)) {
    console.log(`⚠️  No Metadata import found in ${filePath}`);
    return;
  }
  
  const newContent = content.replace(
    importRegex,
    `import type { Metadata } from "next"\nimport type { BlogPost } from "@/lib/blog-data.schema"`
  );
  
  // Also change the post declaration to include type assertion
  const finalContent = newContent.replace(
    /const post = \{/,
    'const post: BlogPost = {'
  );
  
  fs.writeFileSync(filePath, finalContent, 'utf8');
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
    } else if (afterContent.includes('import type { BlogPost }')) {
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
