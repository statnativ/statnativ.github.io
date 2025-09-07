#!/usr/bin/env ruby

require 'date'
require 'yaml'
require 'fileutils'

# Configuration
TOBEPROCESSED_DIR = 'Tobeprocessed'
POSTS_DIR = '_posts'
PAGES_DIR = '_pages'

# Ensure directories exist
FileUtils.mkdir_p(POSTS_DIR)
FileUtils.mkdir_p(PAGES_DIR)

def process_markdown_files(interactive = false, push_to_github = false)
  unless Dir.exist?(TOBEPROCESSED_DIR)
    puts "#{TOBEPROCESSED_DIR} directory not found!"
    return
  end

  markdown_files = Dir.glob("#{TOBEPROCESSED_DIR}/*.md")
  
  if markdown_files.empty?
    puts "No markdown files found in #{TOBEPROCESSED_DIR}"
    return
  end

  processed_files = []
  markdown_files.each do |file_path|
    result = process_single_file(file_path, interactive)
    processed_files << result if result
  end

  puts "Processing complete! #{markdown_files.length} file(s) processed."
  puts "Updating tag and category pages..."
  update_tag_and_category_pages
  
  if push_to_github && !processed_files.empty?
    puts "\n🚀 Pushing to GitHub..."
    push_to_github_repo(processed_files)
  end
end

def process_single_file(file_path, interactive = false)
  filename = File.basename(file_path, '.md')
  content = File.read(file_path)
  
  # Extract metadata from the file or ask user
  if interactive
    metadata = get_interactive_metadata(filename, content)
  else
    metadata = extract_metadata_from_file(content, filename)
  end
  
  # Validate required fields
  unless validate_metadata(metadata)
    puts "⚠️  Skipping #{filename} - missing required metadata"
    return
  end
  
  # Clean the content (remove metadata block if it exists in content)
  clean_content = clean_markdown_content(content)
  
  # Generate Jekyll post filename with date
  date_str = Date.parse(metadata['date'].to_s).strftime('%Y-%m-%d')
  slug = create_slug(metadata['title'])
  jekyll_filename = "#{date_str}-#{slug}.md"
  jekyll_path = File.join(POSTS_DIR, jekyll_filename)
  
  # Write the processed file with proper frontmatter
  write_jekyll_post(jekyll_path, metadata, clean_content)
  
  puts "✅ Processed: #{filename} -> #{jekyll_filename}"
  puts "   📂 Categories: #{metadata['categories'].join(', ')}"
  puts "   🏷️  Tags: #{metadata['tags'].join(', ')}"
  puts "   🔗 GitHub: #{metadata['github_repo']}" if metadata['github_repo']
  
  # Move original file to processed folder
  move_to_processed(file_path)
  
  # Return processed file info for GitHub commit
  {
    original_filename: filename,
    jekyll_filename: jekyll_filename,
    jekyll_path: jekyll_path,
    metadata: metadata
  }
end

def extract_metadata_from_file(content, filename)
  metadata = {}
  
  # Check if file has metadata block after first heading (# Title\n---\nmetadata\n---\n)
  metadata_match = content.match(/^#\s+(.+?)\n---\n(.*?)\n---\n/m)
  
  if metadata_match
    title_from_heading = metadata_match[1].strip
    metadata_text = metadata_match[2]
    
    # Parse the metadata block
    metadata_text.each_line do |line|
      line = line.strip
      next if line.empty?
      
      if line.match(/^([^:]+):\s*(.+)$/)
        key = $1.downcase.strip
        value = $2.strip
        
        case key
        when 'title'
          metadata['title'] = value.gsub(/^["']|["']$/, '')
        when 'date'
          metadata['date'] = value
        when 'categories'
          metadata['categories'] = parse_array_field(value)
        when 'tags'  
          metadata['tags'] = parse_array_field(value)
        when 'github_repo', 'github repo'
          metadata['github_repo'] = value.gsub(/^["']|["']$/, '')
        when 'layout'
          metadata['layout'] = 'single'  # Force single layout for minimal-mistakes theme
        end
      end
    end
    
    # Use title from heading if not set in metadata
    metadata['title'] ||= title_from_heading
    
  elsif content.start_with?('---')
    # Try to extract from frontmatter if it exists at the beginning
    parts = content.split(/^---\s*$/, 3)
    if parts.length >= 3
      begin
        frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
        metadata = frontmatter.transform_keys(&:downcase)
      rescue => e
        puts "Warning: Could not parse frontmatter for #{filename}: #{e.message}"
        metadata = {}
      end
    end
  end
  
  # Fill in defaults for missing fields
  metadata['title'] ||= extract_title_from_content(content) || filename.gsub(/[-_]/, ' ').split.map(&:capitalize).join(' ')
  metadata['date'] ||= Date.today.strftime('%Y-%m-%d')
  metadata['categories'] ||= ['uncategorized']
  metadata['tags'] ||= []
  metadata['layout'] ||= 'single'
  metadata['author'] ||= 'StatNativ Team'
  
  metadata
end

def get_interactive_metadata(filename, content)
  puts "\n📝 Processing: #{filename}"
  puts "=" * 50
  
  # Extract suggested values
  suggested_title = extract_title_from_content(content) || filename.gsub(/[-_]/, ' ').split.map(&:capitalize).join(' ')
  
  # Get user input
  print "Title [#{suggested_title}]: "
  title = gets.strip
  title = suggested_title if title.empty?
  
  print "Date (YYYY-MM-DD) [#{Date.today.strftime('%Y-%m-%d')}]: "
  date = gets.strip
  date = Date.today.strftime('%Y-%m-%d') if date.empty?
  
  print "Categories (comma-separated): "
  categories_input = gets.strip
  categories = categories_input.empty? ? ['uncategorized'] : categories_input.split(',').map(&:strip)
  
  print "Tags (comma-separated): "
  tags_input = gets.strip
  tags = tags_input.empty? ? [] : tags_input.split(',').map(&:strip)
  
  print "GitHub Repository URL (optional): "
  github_repo = gets.strip
  github_repo = nil if github_repo.empty?
  
  {
    'title' => title,
    'date' => date,
    'categories' => categories,
    'tags' => tags,
    'github_repo' => github_repo,
    'layout' => 'single',
    'author' => 'StatNativ Team'
  }
end

def parse_array_field(value)
  # Handle both [item1, item2] and item1,item2 formats
  value = value.gsub(/^\[|\]$/, '').strip
  value.split(',').map(&:strip).reject(&:empty?)
end

def validate_metadata(metadata)
  required_fields = ['title', 'date']
  required_fields.all? { |field| metadata[field] && !metadata[field].empty? }
end

def clean_markdown_content(content)
  # Remove metadata block if it exists after first heading (specific format: # Title\n---\nmetadata\n---\n)
  metadata_match = content.match(/^#\s+(.+?)\n---\n.*?\n---\n/m)
  if metadata_match
    # Keep content after the metadata block
    content = content[metadata_match.end(0)..-1].strip
  elsif content.start_with?('---')
    # Remove frontmatter if it exists at the beginning
    parts = content.split(/^---\s*$/, 3)
    if parts.length >= 3
      content = parts[2].strip
    end
  end
  
  # Clean up any leading/trailing whitespace and empty lines
  content.strip
end

def write_jekyll_post(filepath, metadata, content)
  File.open(filepath, 'w') do |f|
    f.write("---\n")
    f.write("layout: #{metadata['layout'] || 'single'}\n")
    f.write("title: \"#{metadata['title']}\"\n")
    f.write("date: #{metadata['date']}\n")
    
    if metadata['categories'] && !metadata['categories'].empty?
      f.write("categories:\n")
      metadata['categories'].each { |cat| f.write("  - #{cat}\n") }
    end
    
    if metadata['tags'] && !metadata['tags'].empty?
      f.write("tags:\n")
      metadata['tags'].each { |tag| f.write("  - #{tag}\n") }
    end
    
    f.write("author: \"#{metadata['author']}\"\n") if metadata['author']
    f.write("github_repo: \"#{metadata['github_repo']}\"\n") if metadata['github_repo']
    f.write("toc: true\n")
    f.write("toc_sticky: true\n")
    f.write("---\n\n")
    f.write(content)
  end
end

def extract_title_from_content(content)
  # Look for first H1 heading
  match = content.match(/^#\s+(.+)$/m)
  match ? match[1].strip : nil
end

def create_slug(title)
  title.downcase
       .gsub(/[^\w\s-]/, '') # Remove special characters
       .gsub(/\s+/, '-')     # Replace spaces with hyphens
       .gsub(/-+/, '-')      # Replace multiple hyphens with single
       .gsub(/^-|-$/, '')    # Remove leading/trailing hyphens
end

def move_to_processed(file_path)
  processed_dir = File.join(TOBEPROCESSED_DIR, 'processed')
  FileUtils.mkdir_p(processed_dir)
  FileUtils.mv(file_path, File.join(processed_dir, File.basename(file_path)))
end

def update_tag_and_category_pages
  # Get all posts to extract tags and categories
  posts = Dir.glob("#{POSTS_DIR}/*.md")
  all_tags = Set.new
  all_categories = Set.new
  
  posts.each do |post_path|
    content = File.read(post_path)
    if content.start_with?('---')
      parts = content.split(/^---\s*$/, 3)
      if parts.length >= 3
        begin
          frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
          
          if frontmatter['tags'].is_a?(Array)
            all_tags.merge(frontmatter['tags'])
          end
          
          if frontmatter['categories'].is_a?(Array)
            all_categories.merge(frontmatter['categories'])
          end
        rescue => e
          puts "Warning: Could not parse frontmatter for #{post_path}"
        end
      end
    end
  end
  
  # Update tags page if needed
  update_tags_page(all_tags.to_a)
  
  puts "📊 Found #{all_tags.size} unique tags: #{all_tags.to_a.sort.join(', ')}"
  puts "📂 Found #{all_categories.size} unique categories: #{all_categories.to_a.sort.join(', ')}"
end

def update_tags_page(tags)
  tags_page_path = File.join(PAGES_DIR, 'tags.md')
  
  # Keep existing tags page structure, just ensure it exists
  unless File.exist?(tags_page_path)
    File.open(tags_page_path, 'w') do |f|
      f.write("---\n")
      f.write("title: \"Posts by Tag\"\n")
      f.write("layout: tags\n")
      f.write("permalink: /tags/\n")
      f.write("author_profile: true\n")
      f.write("---\n")
    end
    puts "✅ Created tags page at #{tags_page_path}"
  end
end

def push_to_github_repo(processed_files)
  # Check if we're in a git repository
  unless Dir.exist?('.git')
    puts "❌ Not a git repository. Please initialize git first."
    return false
  end
  
  begin
    # Check git status
    puts "📊 Checking git status..."
    git_status = `git status --porcelain`.strip
    
    if git_status.empty?
      puts "📭 No changes to commit."
      return true
    end
    
    # Show what will be committed
    puts "📋 Files to be committed:"
    puts git_status
    
    # Add all changes
    puts "➕ Adding files to git..."
    system('git add .')
    
    # Create commit message
    commit_message = generate_commit_message(processed_files)
    puts "💬 Commit message: #{commit_message}"
    
    # Commit changes with proper escaping for Windows
    puts "💾 Committing changes..."
    commit_cmd = "git commit -m \"#{commit_message.gsub('"', '\"')}\""
    commit_result = system(commit_cmd)
    
    unless commit_result
      puts "❌ Failed to commit changes"
      return false
    end
    
    # Push to remote
    puts "🚀 Pushing to remote repository..."
    push_result = system('git push origin main')
    
    if push_result
      puts "✅ Successfully pushed to GitHub!"
      puts "🌐 Your blog post(s) should be live shortly at your GitHub Pages URL"
      return true
    else
      puts "❌ Failed to push to remote repository"
      puts "💡 You may need to push manually with: git push origin main"
      return false
    end
    
  rescue => e
    puts "❌ Error during git operations: #{e.message}"
    return false
  end
end

def generate_commit_message(processed_files)
  if processed_files.length == 1
    file_info = processed_files.first
    title = file_info[:metadata]['title'] || file_info[:original_filename]
    "Add new blog post: #{title}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
  else
    titles = processed_files.map { |f| f[:metadata]['title'] || f[:original_filename] }
    "Add #{processed_files.length} new blog posts

Posts added:
#{titles.map { |t| "- #{t}" }.join("\n")}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
  end
end

def check_git_setup
  # Check if git is available (Windows compatible)
  git_version = `git --version 2>NUL`.strip
  if git_version.empty?
    puts "❌ Git is not installed or not in PATH"
    puts "💡 Install Git from: https://git-scm.com/downloads"
    return false
  end
  
  puts "✅ Git found: #{git_version}"
  
  # Check if we have a remote origin
  origin_url = `git remote get-url origin 2>NUL`.strip
  if origin_url.empty?
    puts "⚠️  No git remote 'origin' configured"
    puts "💡 Add your GitHub repository with: git remote add origin <your-repo-url>"
    return false
  end
  
  puts "✅ Git remote origin: #{origin_url}"
  
  # Check if we can access the remote
  puts "🔍 Checking remote access..."
  if system('git ls-remote origin HEAD >NUL 2>&1')
    puts "✅ Can access remote repository"
  else
    puts "⚠️  Cannot access remote repository (check credentials/network)"
    puts "💡 You may need to set up authentication (SSH keys or Personal Access Token)"
  end
  
  true
end

# Command line interface
def show_help
  puts <<~HELP
    Jekyll Post Processor for StatNativ Blog
    ========================================
    
    Usage:
      ruby process_posts_enhanced.rb [options]
    
    Options:
      -i, --interactive    Ask for metadata input interactively
      -p, --push          Push processed posts to GitHub automatically
      -g, --git-check     Check git setup and remote configuration
      -h, --help          Show this help message
    
    The script will:
    1. Process all .md files in the Tobeprocessed folder
    2. Extract or ask for metadata (Title, Date, Categories, Tags, GitHub repo)
    3. Create properly formatted Jekyll posts
    4. Update tag and category systems
    5. Move processed files to Tobeprocessed/processed/
    6. Optionally commit and push to GitHub (with -p flag)
    
    Required metadata for each post:
    - Title (extracted from H1 or filename if not provided)
    - Date (current date if not provided)
    - Categories (defaults to 'uncategorized')
    - Tags (optional but recommended)
    - GitHub repo (optional)
    
    Examples:
      ruby process_posts_enhanced.rb                    # Process files automatically
      ruby process_posts_enhanced.rb -i                 # Interactive mode
      ruby process_posts_enhanced.rb -p                 # Process and push to GitHub
      ruby process_posts_enhanced.rb -i -p              # Interactive mode + GitHub push
      ruby process_posts_enhanced.rb -g                 # Check git setup
  HELP
end

# Main execution
if __FILE__ == $0
  interactive = ARGV.include?('-i') || ARGV.include?('--interactive')
  push_to_github = ARGV.include?('-p') || ARGV.include?('--push')
  git_check = ARGV.include?('-g') || ARGV.include?('--git-check')
  
  if ARGV.include?('-h') || ARGV.include?('--help')
    show_help
  elsif git_check
    puts "Jekyll Post Processor - Git Setup Check"
    puts "========================================"
    puts
    check_git_setup
  else
    puts "Jekyll Post Processor for StatNativ Blog"
    puts "========================================="
    puts
    
    # Check git setup if push is requested
    if push_to_github
      puts "🔍 Checking git setup (required for push)..."
      unless check_git_setup
        puts "❌ Cannot push to GitHub due to git setup issues"
        exit 1
      end
      puts
    end
    
    if interactive
      puts "🎯 Running in INTERACTIVE mode"
      puts "You will be asked to provide metadata for each post."
    else
      puts "🤖 Running in AUTOMATIC mode"
      puts "Metadata will be extracted from files automatically."
    end
    
    if push_to_github
      puts "🚀 GITHUB PUSH enabled - processed posts will be committed and pushed"
    end
    puts
    
    process_markdown_files(interactive, push_to_github)
  end
end