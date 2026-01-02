import { BlogHeader } from "@/components/blog-header"
import { BlogFooter } from "@/components/blog-footer"
import { AffiliateProductReviewTemplate } from "@/components/blog-templates/affiliate-product-review-template"
import type { Metadata } from "next"
import { post } from "@/lib/blog-data/glow-on-unveiling-the-magic-of-cc-cream-illumination.data"

const imageUrl = post.typeSpecificData?.affiliate?.images?.[0] || post.image

export const metadata: Metadata = {
  "title": post.title,
  "description": post.excerpt,
  "openGraph": {
    "title": post.title,
    "images": imageUrl,
    "description": post.excerpt,
    "type": "article",
    "publishedTime": "2025-12-26T00:00:00.000Z",
    "authors": [
      post.author.name
    ]
  },
  "twitter": {
    "card": "summary_large_image",
    "title": post.title,
    "images": imageUrl,
    "description": post.excerpt
  }
}

export default function BlogPost() {
  return (
    <div className="min-h-screen">
      <BlogHeader />
      <AffiliateProductReviewTemplate post={post} />
      <BlogFooter />
    </div>
  )
}
