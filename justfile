pick:
  fd --type=d | fzf

new $FOLDER:
  #!/usr/bin/env bash
  if [ -d "$FOLDER" ]; then
    echo "Folder already exists"
    exit 1
  fi

  cp -r html-base $FOLDER
  just edit $FOLDER

edit $ROOT='':
  #!/usr/bin/env bash
  if [ -z "$ROOT" ]; then
    ROOT=$(just pick)
  fi

  kitten @ launch --type=tab --cwd=$(realpath $ROOT) --title=$ROOT --keep-focus web-dev-server --node-resolve --watch --esbuild-target auto --app-index $ROOT
  cd $ROOT
  if [ -f index.html ]; then
    $(sleep 0.5 ; open http://localhost:8000/index.html) &
    nvim index.html
  else
    nvim
  fi

fork $FOLDER='':
  #!/usr/bin/env bash
  if [ -z "$FOLDER" ]; then
    FOLDER=$(just pick)
  fi

  if [ -z "$FOLDER" ]; then
    echo "No folder selected"
    exit 1
  fi

  new_folder="$FOLDER-$(date +%s)"
  cp -r $FOLDER $new_folder
  echo "Forked $FOLDER to $new_folder"
  just edit $new_folder
