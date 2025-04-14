namespace :runewatch do
  desc 'Check active clan members against RuneWatch reports'
  task check_reported_members: :environment do
    require 'net/http'
    require 'uri'
    require 'nokogiri'
    require 'json'
    
    # --- Get active clan members from database with improved matching ---
    def fetch_clan_members_from_db
      active_members = Player.where(deactivated: false).pluck(:name)
      members = active_members.map { |name| name.downcase.gsub(/\s+/, '') }
      puts "✅ Found #{active_members.size} active clan members in database."
      members
    end

    # --- Scrape reported usernames from RuneWatch with caching ---
    def fetch_reported_usernames
      cache_file = Rails.root.join('tmp', 'runewatch_cache.json')
      cache_expiry = 24.hours # Cache expires after 24 hours
      
      # Check if we have a recent cache
      if File.exist?(cache_file) && File.mtime(cache_file) > Time.now - cache_expiry
        puts "📋 Using cached RuneWatch data (#{((Time.now - File.mtime(cache_file))/3600).round(1)} hours old)"
        return Set.new(JSON.parse(File.read(cache_file)))
      end
      
      # Scrape fresh data from the cases page
      reported = Set.new
      
      puts "🌐 Fetching RuneWatch cases..."
      url = "https://runewatch.com/cases/"
      
      begin
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Get.new(uri.request_uri)
        # Add browser-like headers to avoid anti-scraping measures
        request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15'
        request['Accept'] = 'text/html,application/xhtml+xml,application/xml'
        request['Accept-Language'] = 'en-US,en;q=0.9'
        
        response = http.request(request)
        
        # Follow redirects if needed
        redirect_count = 0
        while response.is_a?(Net::HTTPRedirection) && redirect_count < 5
          redirect_count += 1
          redirect_url = response['location']
          puts "  Following redirect (#{redirect_count}) to: #{redirect_url}"
          
          # Handle relative URLs
          redirect_url = "#{uri.scheme}://#{uri.host}#{redirect_url}" if redirect_url.start_with?('/')
          
          uri = URI(redirect_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')
          
          request = Net::HTTP::Get.new(uri.request_uri)
          request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15'
          request['Accept'] = 'text/html,application/xhtml+xml,application/xml'
          response = http.request(request)
        end
        
        unless response.is_a?(Net::HTTPSuccess)
          puts "⚠️ Failed to fetch cases: HTTP #{response.code}"
          return reported
        end
        
        # Save HTML for debugging - fix encoding issues
        debug_file = Rails.root.join('tmp', 'runewatch_debug.html')
        # Use binary write to avoid encoding issues
        File.binwrite(debug_file, response.body)
        puts "  Saved HTML to #{debug_file} for inspection"
        
        # Handle encoding when parsing HTML
        html_with_encoding = response.body.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)
        doc = Nokogiri::HTML(html_with_encoding)
        
        # Extract usernames directly from table rows
        # The structure appears to be a table with columns: Reference, RSN, Published Date, View
        rows = doc.css('tr')
        puts "  Found #{rows.size} table rows"
        
        if rows.any?
          count_found = 0
          
          rows.each do |row|
            # Get the cells in this row
            cells = row.css('td')
            
            # Skip header rows or malformed rows (should have at least 3 cells)
            next if cells.size < 3
            
            # The RSN appears to be in the second cell
            rsn_cell = cells[1]
            next unless rsn_cell
            
            # Extract the username
            username = rsn_cell.text.strip
            
            # Validate it looks like a RuneScape name (1-12 chars, alphanumeric + underscores)
            if username.match?(/^[a-zA-Z0-9_]{1,12}$/)
              if count_found < 10 # Show first few for debugging
                puts "    Found username: #{username}"
              end
              reported.add(username.downcase)
              count_found += 1
            end
          end
          
          puts "  ✅ Added #{count_found} usernames from table rows"
        else
          puts "⚠️ No table rows found. Trying alternative extraction methods..."
          
          # Fall back to text analysis to find RuneScape usernames
          body_text = doc.text
          
          # First look for patterns that match the RuneWatch case format (#ID NAME DATE)
          # This handles multi-word names like "Pvm Scrub"
          case_pattern = /#[a-f0-9]{6,7}\s+([a-zA-Z0-9_\s]{3,16})\s+\d{2}-\d{2}-\d{4}/i
          case_matches = body_text.scan(case_pattern)
          
          if case_matches.any?
            puts "  Found #{case_matches.size} matches using RuneWatch case pattern."
            case_matches.flatten.each do |name|
              clean_name = name.strip
              puts "    Found name with spaces: #{clean_name}" if clean_name.include?(' ')
              reported.add(clean_name.downcase)
              
              # Also add version without spaces for better matching
              if clean_name.include?(' ')
                reported.add(clean_name.downcase.gsub(/\s+/, ''))
              end
            end
          end
          
          # Then also do standard username pattern matching as a fallback
          potential_usernames = body_text.scan(/\b[a-zA-Z0-9_]{3,12}\b/)
            .reject { |u| u =~ /view|case|reference|published|date/i }
          
          puts "  Found #{potential_usernames.size} potential username patterns."
          
          # Filter common words that might be false positives
          common_words = %w[the and for if but not with has key]
          filtered_usernames = potential_usernames.uniq.reject { |u| common_words.include?(u.downcase) }
          
          # Add ALL usernames, not just the first 100
          filtered_usernames.each do |username|
            reported.add(username.downcase)
          end
          
          puts "  ⚠️ Added #{filtered_usernames.size} usernames using fallback method."
        end
        
      rescue => e
        puts "⚠️ Error scraping cases: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
      
      # Filter out common false positives
      common_false_positives = %w[view case reference published date rsn key]
      reported.reject! { |username| common_false_positives.include?(username.downcase) }
      
      # Save to cache
      puts "✅ Scraped #{reported.size} reported users from RuneWatch."
      FileUtils.mkdir_p(File.dirname(cache_file))
      File.write(cache_file, reported.to_a.to_json)
      
      reported
    end

    # --- Find reported clan members function ---    
    def find_reported_clan_members(clan_members_with_names, reported_users)
      reported_clan_members = []
      
      # Convert original set to one with space-normalized versions too
      reported_with_spaces = Set.new
      reported_users.each do |name|
        # Keep original
        reported_with_spaces.add(name)
        # Add version with spaces removed
        if name.include?(' ')
          reported_with_spaces.add(name.gsub(/\s+/, ''))
        end
      end
      
      # Check each clan member against the reported list
      clan_members_with_names.each do |id, name|
        normalized_name = name.downcase.gsub(/\s+/, '')
        
        # Check with multiple comparison methods
        is_reported = reported_users.include?(name.downcase) ||
                      reported_users.include?(normalized_name) ||
                      reported_users.any? { |r| r.downcase.gsub(/\s+/, '') == normalized_name }
        
        if is_reported
          reported_clan_members << name
          # Update the player's reported status in the database
          Player.find(id).update_column(:runewatch_reported, true)
        end
      end
      
      reported_clan_members
    end

    # --- Main task logic ---
    reported_users = fetch_reported_usernames
    
    # Get clan members with IDs for database updates
    clan_members_with_names = Player.where(deactivated: false).pluck(:id, :name)
    reported_clan_members = find_reported_clan_members(clan_members_with_names, reported_users)

    puts "\n=== 🚨 Reported Clan Members ==="
    if reported_clan_members.any?
      reported_clan_members.each { |member| puts "- #{member}" }
    else
      puts "✅ No reported clan members found."
    end
  end
  
  desc 'Force refresh of RuneWatch cache'
  task refresh_cache: :environment do
    cache_file = Rails.root.join('tmp', 'runewatch_cache.json')
    if File.exist?(cache_file)
      File.delete(cache_file)
      puts "🗑️ RuneWatch cache deleted. Will be rebuilt on next check."
    end
    
    # Run the check to rebuild the cache
    Rake::Task["runewatch:check_reported_members"].invoke
  end
  
  desc 'Check a specific username against RuneWatch'
  task :check_username, [:name] => :environment do |t, args|
    require 'json'
    if args[:name].blank?
      puts "⚠️ Please provide a username to check. Example: rake runewatch:check_username[playername]"
      next
    end
    
    username = args[:name].downcase.strip
    puts "🔍 Checking '#{username}' against RuneWatch..."
    
    # Load cached data if available
    cache_file = Rails.root.join('tmp', 'runewatch_cache.json')
    if File.exist?(cache_file)
      reported_users = Set.new(JSON.parse(File.read(cache_file)))
      
      # Normalize for comparison
      normalized_username = username.gsub(/\s+/, '')
      
      # Look for matches with improved comparison
      is_reported = reported_users.any? do |reported|
        reported.downcase.gsub(/\s+/, '') == normalized_username
      end
      
      if is_reported
        puts "🚨 ALERT: #{username} IS REPORTED on RuneWatch!"
      else
        puts "✅ #{username} is not found on RuneWatch."
      end
      
      puts "ℹ️ Using cached data from #{((Time.now - File.mtime(cache_file))/3600).round(1)} hours ago."
      puts "   Run 'rake runewatch:refresh_cache' first for fresh data."
    else
      puts "⚠️ No cached data found. Please run 'rake runewatch:check_reported_members' first."
    end
  end

  desc 'Debug specific usernames'
  task debug_runewatch: :environment do
    puts "🔍 Debugging RuneWatch detection..."
    
    # Names to check
    test_names = ["pvmsoldier", "pvm scrub"]
    
    # 1. Check if these players exist in the database
    test_names.each do |name|
      player = Player.where("LOWER(name) = ?", name.downcase).first
      if player
        puts "✅ Player '#{name}' exists in database as '#{player.name}'"
      else
        matches = Player.where("LOWER(name) LIKE ?", "%#{name.downcase.gsub(/\s+/, '')}%").pluck(:name)
        if matches.any?
          puts "⚠️ Player '#{name}' not found exactly, but similar names: #{matches.join(', ')}"
        else
          puts "❌ Player '#{name}' does not exist in database"
        end
      end
    end
    
    # 2. Check the cached data
    cache_file = Rails.root.join('tmp', 'runewatch_cache.json')
    if File.exist?(cache_file)
      reported_users = JSON.parse(File.read(cache_file))
      puts "📋 Found #{reported_users.size} cached usernames"
      
      # Check if our test names are in the reported data
      test_names.each do |name|
        normalized = name.downcase.gsub(/\s+/, '')
        
        # Direct match check
        if reported_users.include?(name.downcase)
          puts "✅ '#{name}' is directly in the reported list"
        else
          puts "❌ '#{name}' is not directly in the reported list"
        end
        
        # Normalized match check
        found = reported_users.any? do |reported|
          reported.downcase.gsub(/\s+/, '') == normalized
        end
        
        if found
          matching = reported_users.select { |r| r.downcase.gsub(/\s+/, '') == normalized }
          puts "✅ Normalized '#{normalized}' matches: #{matching.join(', ')}"
        else
          # Look for partial matches
          partial = reported_users.select { |r| r.downcase.include?(normalized) }
          if partial.any?
            puts "⚠️ Partial matches for '#{normalized}': #{partial.first(5).join(', ')}"
          else
            puts "❌ No normalized match for '#{normalized}'"
          end
        end
      end
    else
      puts "❌ No cache file found"
    end
  end
end
