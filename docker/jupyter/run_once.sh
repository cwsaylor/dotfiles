docker run -dit \
  -e GRANT_SUDO=yes \
  -e JUPYTER_ENABLE_LAB=yes \
  --user root \
  -p 8888:8888 \
  -v /Users/$USER/Code/jupyter:/home/jovyan/work \
  --name jupyter \
  cwsaylor/jupyter_with_ruby \
  start-notebook.sh --NotebookApp.token="token"
