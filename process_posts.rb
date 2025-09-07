#!/usr/bin/env ruby

require 'date'
require 'yaml'
require 'fileutils'

# Configuration
TOBEPROCESSED_DIR = 'Tobeprocessed'
POSTS_DIR = '_posts'

# Ensure posts directory exists
FileUtils.mkdir_p(POSTS_DIR)

def process_markdown_files
  unless Dir.exist?(TOBEPROCESSED_DIR)
    puts "#{TOBEPROCESSED_DIR} directory not found!"
    return
  end

  markdown_files = Dir.glob("#{TOBEPROCESSED_DIR}/*.md")
  
  if markdown_files.empty?
    puts "No markdown files found in #{TOBEPROCESSED_DIR}"
    return
  end

  markdown_files.each do |file_path|
    process_single_file(file_path)
  end

  puts "Processing complete! #{markdown_files.length} file(s) processed."
end

def process_single_file(file_path)
  filename = File.basename(file_path, '.md')
  content = File.read(file_path)
  
  # Check if file already has frontmatter
  if content.start_with?('---')
    frontmatter, body = parse_existing_frontmatter(content)
  else
    frontmatter = create_default_frontmatter(filename, content)
    body = content
  end
  
  # Generate Jekyll post filename with date
  date = frontmatter['date'] || Date.today.strftime('%Y-%m-%d %H:%M:%S')
  date_str = Date.parse(date.to_s).strftime('%Y-%m-%d')
  
  # Create slug from title or filename
  slug = create_slug(frontmatter['title'] || filename)
  jekyll_filename = "#{date_str}-#{slug}.md"
  jekyll_path = File.join(POSTS_DIR, jekyll_filename)
  
  # Write the processed file
  File.open(jekyll_path, 'w') do |f|
    f.write("---\n")
    f.write(frontmatter.to_yaml.gsub(/^---\n/, ''))
    f.write("---\n\n")
    f.write(body)
  end
  
  puts "✓ Processed: #{filename} -> #{jekyll_filename}"
  
  # Move original file to processed folder or delete it
  processed_dir = File.join(TOBEPROCESSED_DIR, 'processed')
  FileUtils.mkdir_p(processed_dir)
  FileUtils.mv(file_path, File.join(processed_dir, File.basename(file_path)))
end

def parse_existing_frontmatter(content)
  parts = content.split(/^---\s*$/, 3)
  if parts.length >= 3
    begin
      frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
    rescue => e
      puts "Warning: Could not parse frontmatter, using defaults. Error: #{e.message}"
      frontmatter = {}
    end
    body = parts[2].strip
  else
    frontmatter = {}
    body = content
  end
  [frontmatter, body]
end

def create_default_frontmatter(filename, content)
  # Extract title from content (first heading) or use filename
  title = extract_title_from_content(content) || filename.gsub(/[-_]/, ' ').split.map(&:capitalize).join(' ')
  
  # Extract categories and tags from content or use defaults
  categories = extract_categories_from_content(content) || ['Blog']
  tags = extract_tags_from_content(content) || []
  
  {
    'title' => title,
    'date' => Date.today.strftime('%Y-%m-%d %H:%M:%S'),
    'categories' => categories,
    'tags' => tags,
    'author' => 'StatNativ Team'
  }
end

def extract_title_from_content(content)
  # Look for first H1 heading
  match = content.match(/^#\s+(.+)$/m)
  match ? match[1].strip : nil
end

def extract_categories_from_content(content)
  # Look for common tech/AI keywords to categorize
  keywords = {
    'AI' => ['artificial intelligence', 'machine learning', 'deep learning', 'neural network', 'transformer'],
    'Data Science' => ['data science', 'analytics', 'statistics', 'visualization'],
    'Programming' => ['python', 'javascript', 'coding', 'development'],
    'Systems' => ['system design', 'architecture', 'scalability', 'performance']
  }
  
  content_lower = content.downcase
  categories = []
  
  keywords.each do |category, terms|
    if terms.any? { |term| content_lower.include?(term) }
      categories << category
    end
  end
  
  categories.empty? ? ['Blog'] : categories
end

def extract_tags_from_content(content)
  # Extract tags from common tech terms
  tech_terms = ['python', 'javascript', 'react', 'node', 'tensorflow', 'pytorch', 'sql', 'aws', 'docker', 'kubernetes', 'ml', 'ai', 'api', 'frontend', 'backend']
  
  content_lower = content.downcase
  tags = tech_terms.select { |term| content_lower.include?(term) }
  
  # Limit to 5 tags
  tags.first(5)
end

def create_slug(title)
  title.downcase
       .gsub(/[^\w\s-]/, '') # Remove special characters
       .gsub(/\s+/, '-')     # Replace spaces with hyphens
       .gsub(/-+/, '-')      # Replace multiple hyphens with single
       .gsub(/^-|-$/, '')    # Remove leading/trailing hyphens
end

# Run the script
if __FILE__ == $0
  puts "Jekyll Post Processor for StatNativ Blog"
  puts "========================================="
  puts
  
  process_markdown_files
end