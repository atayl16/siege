require 'rack'

NEW_SITE_URL = "https://www.siege-clan.com"

app = lambda do |env|
  request_path = env['PATH_INFO']
  
  if request_path == '/staying'
    # Just redirect immediately
    [302, {'Location' => NEW_SITE_URL}, []]
  else
    # Show redirect page with countdown
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Siege Clan Has Moved!</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
          <style>
            body { background-color: #121212; color: white; }
            .card { background-color: #212121; }
          </style>
        </head>
        <body>
          <div class="container text-center my-5">
            <div class="card text-white border-warning p-4">
              <h1 class="display-4">Siege Clan Has Moved!</h1>
              
              <div class="my-4">
                <p class="lead">
                  We've moved to a new website with improved performance and features.
                </p>
                <p>
                  Please update your bookmarks to our new address:
                </p>
                <div class="d-grid gap-2 col-md-6 mx-auto my-4">
                  <a href="#{NEW_SITE_URL}" class="btn btn-warning btn-lg">
                    Go to our new site
                  </a>
                  <p class="text-muted mt-2">You will be redirected automatically in <span id="countdown">10</span> seconds...</p>
                </div>
              </div>
            </div>
          </div>

          <script>
            // Auto redirect after countdown
            let seconds = 10;
            const countdown = document.getElementById('countdown');
            
            const timer = setInterval(function() {
              seconds--;
              countdown.textContent = seconds;
              if (seconds <= 0) {
                clearInterval(timer);
                window.location.href = "#{NEW_SITE_URL}";
              }
            }, 1000);
          </script>
        </body>
      </html>
    HTML
    
    [200, {'Content-Type' => 'text/html'}, [html]]
  end
end

run app
