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

  pid=$(kitten @ launch \
      --type=tab \
      --cwd=$(realpath $ROOT) \
      --title=$ROOT \
      --keep-focus \
        web-dev-server --app-index $ROOT)
  cd $ROOT
  echo pid: $pid

  # Grabbing host from output of last command
  # ...
  #     Local:    http://localhost:8000/
  # ...
  while [ -z "$host" ]; do
    host=$(kitten @ get-text --match "id:$pid" --extent last_cmd_output | rg '\s*Local:\s+(http://.*)$' -r '$1')
    sleep 0.1 # wait for the server to have started
  done

  if [ -f index.html ]; then
    suffix="index.html"
  fi

  open "${host}${suffix}" --background
  nvim ${suffix:-''}

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
