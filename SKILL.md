---
name: plamo-translate-space
description: "Build a local translation Space in Muse powered by the open-weight PLaMo 3 Translate 0.8B model: download the GGUF weights, run llama.cpp (llama-server) inside the Muse VM, build a fullstack Space that calls it on localhost, and verify the result with fixed test translations. Use when a user wants a PLaMo translation app or Space in Muse, wants translation that never leaves their own VM, or wants to share a dynamic Muse Space as a rebuildable recipe instead of a public link."
---

# PLaMo Translate Space

Build a translation app as a Muse Space whose engine is a local model running
inside the user's own Muse VM. Nothing the user pastes for translation leaves
the VM, and no external translation API or cloud LLM is used.

This skill is also a worked example of how to share a *dynamic* Muse Space.
A dynamic (fullstack) Space cannot be shared by public link, because its
server side and its data live in the owner's VM. What can be shared is the
recipe: materials, build order, specification, and acceptance tests. Another
person's Muse follows this skill and rebuilds the same Space inside their
own VM, with their own data.

## Materials

- Model: `pfnet/plamo-3-translate-0.8b-GGUF`, quantization Q4_K_M
  (573,126,848 bytes), from Hugging Face. License: PLaMo Community License —
  free for private/personal use with no registration. Commercial use has
  separate conditions; check with the user before building for commercial use.
- Runtime: llama.cpp official binary (verified with b12201, ubuntu-x64).
- Space specification: `references/space-spec.md` in this repository.
- Setup script: `scripts/setup-and-start.sh` in this repository.

## Method

Work through the steps in order. Verify each step before moving to the next.

### Step 1: Stand up the local translation server

Run `scripts/setup-and-start.sh`. It:

1. Downloads the model into `~/plamo-local/`.
2. Downloads the llama.cpp binary.
3. Starts `llama-server` on 127.0.0.1:18080 (`-t 4 -c 4096`, no web UI).
4. Waits until `GET /health` returns `{"status":"ok"}`.

If the VM is not Linux x64, substitute the matching official llama.cpp binary
(for example macOS arm64). Do not change the model source or the server
options. The reference environment is a GPU-less 4-core Muse VM; one
sentence takes roughly 1.5 seconds on CPU.

### Step 2: Test the server on its own (verification gate)

`POST http://127.0.0.1:18080/v1/chat/completions` with
`{"messages":[{"role":"user","content":"<source>"}], "temperature":0, "max_tokens":512}`
must return:

- 「会議は来週の月曜日に変更されました。」 → "The meeting has been rescheduled for next Monday."
- "Please send me the report by Friday afternoon." → 「金曜日の午後までにレポートを送ってください。」

If either differs, stop and fix the server side. Do not proceed to the Space.

### Step 3: Build the Space

Create a fullstack Space named 「PLaMo翻訳」, placed in the sidebar, exactly
as specified in `references/space-spec.md`. The Space's server layer calls
the local server from Step 1 on localhost. Language direction is decided by
the model's own chat template (Japanese → English, anything else →
Japanese); do not implement language detection in the app.

### Step 4: Verify through the Space (acceptance)

- The Space action returns health ok.
- The same two test sentences from Step 2 return the same translations
  through the Space.
- UI: typing/pasting shows a translation, the copy button enables, and
  "クリア" resets both panes.
- With the server stopped, the Space shows 「ローカル翻訳サーバーが起動していません」
  and never a dummy translation (checking the code path is acceptable).

## Boundaries and notes

- The llama-server is a resident process; a VM restart or replacement stops
  it. Recovery is re-running `~/plamo-local/start_server.sh`. Tell the user
  this recovery step when you hand over the finished Space.
- No data migrates with this recipe: the app keeps no translation history by
  design, and source text is never sent outside the user's VM.
- Verified end-to-end on 2026-11-08 in the author's Muse VM (build,
  health check, both translation directions, and UI operations all
  confirmed). Muse and Space internals change quickly; if a step fails,
  re-check the current behavior instead of forcing this procedure.
