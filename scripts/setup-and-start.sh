#!/bin/bash
# PLaMo翻訳 ローカルサーバー セットアップ＆起動（Muse VM / Linux x64 前提）
# 使い方: bash setup-and-start.sh   作業場所は ~/plamo-local/
set -e
WORK="$HOME/plamo-local"
mkdir -p "$WORK" && cd "$WORK"

# 1) モデル（GGUF Q4_K_M, 573,126,848 bytes）を Hugging Face から取得
if [ ! -f plamo-3-translate-0.8b-Q4_K_M.gguf ]; then
  curl -L -o plamo-3-translate-0.8b-Q4_K_M.gguf \
    https://huggingface.co/pfnet/plamo-3-translate-0.8b-GGUF/resolve/main/plamo-3-translate-0.8b-Q4_K_M.gguf
fi

# 2) llama.cpp 公式バイナリ（b12201, ubuntu-x64）を取得
if [ ! -f llama-bin/llama-server ]; then
  curl -L -o llama.tar.gz \
    https://github.com/ggml-org/llama.cpp/releases/download/b12201/llama-b12201-bin-ubuntu-x64.tar.gz
  mkdir -p llama-bin
  tar -xzf llama.tar.gz -C llama-bin --strip-components=1 --no-same-owner || true
fi

# 3) サーバー起動（127.0.0.1:18080、常駐）
cat > start_server.sh <<'EOS2'
#!/bin/bash
cd "$HOME/plamo-local"
export LD_LIBRARY_PATH=$PWD/llama-bin
exec ./llama-bin/llama-server -m plamo-3-translate-0.8b-Q4_K_M.gguf \
  --host 127.0.0.1 --port 18080 -t 4 -c 4096 --no-webui >> server.log 2>&1
EOS2
chmod +x start_server.sh
nohup ./start_server.sh > /dev/null 2>&1 &

# 4) 起動確認（health が ok になるまで待つ）
for i in $(seq 1 30); do
  sleep 1
  if curl -s http://127.0.0.1:18080/health | grep -q '"ok"'; then
    echo "OK: llama-server is up (127.0.0.1:18080)"
    exit 0
  fi
done
echo "FAILED: server did not become healthy. See ~/plamo-local/server.log"
exit 1
