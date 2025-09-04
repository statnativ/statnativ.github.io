---
layout: single
title: "Medium-Style Blog Setup Guide"
author_profile: true
---

# Medium-Style Blog Setup Guide

## Overview
Your blog has been redesigned with a Medium-inspired look and feel. Here's what was changed:

## Files Created/Modified

### 1. Custom Styles
- `assets/css/medium-style.css` - Complete Medium-inspired styling with:
  - Clean typography using Inter and PT Serif fonts
  - Medium-style article cards and layouts  
  - Responsive design for all screen sizes
  - Dark mode support
  - Professional color palette and spacing

### 2. Layout Templates
- `_layouts/home.html` - Homepage with Medium-style article grid
- `_layouts/post.html` - Individual post layout with reading experience
- `_layouts/page.html` - Static page layout
- `_layouts/default.html` - Base layout for other content

## Key Features Added

### Homepage (Medium-style)
- Clean header with navigation
- Hero section with your profile
- Article cards with author info, read time, and tags
- Sidebar with featured posts and categories
- Responsive grid layout

### Post Pages
- Large, readable typography 
- Reading progress indicator
- Social sharing buttons
- Author bio section
- Related posts
- Professional article layout

### Design Elements
- Medium-inspired spacing and typography
- Hover effects and smooth transitions
- Mobile-responsive design
- SEO meta tags and structured data
- Professional color scheme

## Setup Instructions

### Prerequisites
You'll need Ruby and Jekyll installed. On Windows:

1. Install Ruby from https://rubyinstaller.org/
2. Install Jekyll and Bundler:
   ```bash
   gem install jekyll bundler
   ```

### Running the Site
1. Navigate to your blog directory:
   ```bash
   cd statnativ.github.io
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Serve the site locally:
   ```bash
   bundle exec jekyll serve
   ```

4. Open http://localhost:4000 in your browser

### Building for Production
```bash
bundle exec jekyll build
```

## Customization Options

### Colors
Edit the CSS variables in `assets/css/medium-style.css`:
```css
:root {
  --primary-color: #242424;
  --secondary-color: #6b6b6b;
  --accent-color: #1a8917;
  /* ... more variables */
}
```

### Fonts
The design uses:
- **Inter** for headings and UI elements
- **PT Serif** for body text (like Medium)

### Navigation
Update `_config.yml` to add/modify navigation items in the `tabs` section.

## Troubleshooting

### If Jekyll doesn't build:
1. Check Ruby version: `ruby --version`
2. Update gems: `bundle update`
3. Clear cache: `bundle exec jekyll clean`

### If styles don't load:
1. Ensure `assets/css/medium-style.css` exists
2. Check file paths in layout files
3. Verify Jekyll is processing CSS files

## Browser Compatibility
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile responsive (iOS Safari, Chrome Mobile)
- Progressive enhancement for older browsers

## Performance Features
- Optimized CSS with minimal dependencies
- Fast Google Fonts loading
- Efficient responsive images
- Minimal JavaScript for reading progress

Your blog now has a professional, Medium-inspired design that's fast, responsive, and SEO-friendly!