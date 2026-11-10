#!/bin/bash
#
# Puts the game in docs/game, so that it can be played in a browser:
#
#  - docs/game/pron.pde: the game
#  - docs/game/processing.min.js: Processing.js, to run the game
#  - docs/game/pron.html: the page that runs the game
#
# Usage, from the project root:
#
#   ./scripts/add_game_to_website.sh

set -e

if [[ ! -f pron.pde ]]; then
    echo "FATAL ERROR: cannot find 'pron.pde'."
    echo "Please run the script from the project root."
    exit 42
fi

cp pron.pde docs/game/

if [[ ! -f docs/game/processing.min.js ]]; then
    curl --fail --silent --show-error --location \
      --output docs/game/processing.min.js \
      https://cdnjs.cloudflare.com/ajax/libs/processing.js/1.6.6/processing.min.js
fi

cat > docs/game/pron.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Pron</title>
  <script src="processing.min.js"></script>
  <style>html, body { margin: 0; padding: 0; background: black; overflow: hidden; }</style>
</head>
<body>
  <canvas data-processing-sources="pron.pde" tabindex="0"></canvas>
</body>
</html>
EOF
