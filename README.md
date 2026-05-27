# SmartGlasses Challenge — TSA-ASR Scoring Toolkit

This repository hosts the official scoring scripts for the **TSA-ASR (Time-Stamped Speaker-Attributed ASR) task** of the [SmartGlasses Challenge @ SLT 2026](https://aslp-lab.github.io/SmartGlasses/). It is a thin wrapper around [MeetEval](https://github.com/fgnt/meeteval) that fixes the metrics, the collar, and the input format used during the official evaluation, so that participants can reproduce their dev-set numbers locally before each submission.

## About the Challenge

The SmartGlasses Challenge benchmarks egocentric speech interaction on AI glasses in real-world environments. Audio is captured by a 4-channel microphone array integrated into the glasses frame, and the recordings cover dynamic acoustic conditions: ambient noise, motion noise, and overlapping speech from surrounding talkers.

The challenge is organised into two tracks, each with two tasks:

| Track | Scenario | Task 1 | Task 2 |
|---|---|---|---|
| Track 1 | Dyadic dialogue (two-person, face-to-face conversation) | TSA-ASR | SLU (multiple-choice QA) |
| Track 2 | Multi-party meeting (varying number of speakers, long context) | TSA-ASR | SLU (multiple-choice QA) |

**This repository covers Task 1 (TSA-ASR) for both Track 1 and Track 2.** Given an audio session, a participating system is expected to produce, jointly, the transcription, the speaker label, and the start/end timestamps of every utterance. The primary ranking metric is **tcpWER** (time-constrained minimum-permutation WER) with a 0.25 s collar, and we additionally report **cpWER** and **DER** for diagnostic purposes.

For dataset details, registration and the timeline, please refer to the [challenge website](https://aslp-lab.github.io/SmartGlasses/).

## Installation

The toolkit only depends on MeetEval. We recommend a clean Python ≥ 3.8 environment.

Install from PyPI:

```bash
pip install meeteval
```

or from source (useful if you want to inspect / patch the metric implementations):

```bash
git clone https://github.com/fgnt/meeteval
pip install -e ./meeteval
```

Then clone this repo:

```bash
git clone <this-repo-url> Smart-Glass-Challenge
cd Smart-Glass-Challenge
```

A quick sanity check — running the bundled example should print three blocks of metrics without errors:

```bash
bash run.sh
```

## Usage

### Input format

Both the reference and the hypothesis must be supplied in [STM (Segmental Time Mark)](https://github.com/usnistgov/SCTK/blob/master/doc/infmts.htm#L75) format. Each line describes one utterance:

```
<session_id> <channel> <speaker_id> <begin_time> <end_time> <transcript>
```

- `session_id`: the recording / session identifier. **It must match exactly between `ref.stm` and `hyp.stm`**, otherwise the session will be skipped and treated as a failure.
- `channel`: ignored by MeetEval; we use `1` by convention.
- `speaker_id`: a string that identifies the speaker (or the system output stream). Speaker IDs in the hypothesis do **not** need to match those in the reference — the metrics solve the optimal permutation internally.
- `begin_time`, `end_time`: utterance boundaries in **seconds** (floating point).
- `transcript`: a **space-separated** list of tokens. For Chinese audio, tokens are individual characters; please insert a space between every two characters. English / mixed-language utterances follow the usual word-level tokenisation (lower-cased, punctuation stripped). One utterance per line, no line breaks inside the transcript.

A short example (see [`example/ref.stm`](example/ref.stm)):

```
session_001 1 SPK01 0.00 2.30 你 好 请 问 你 是 新 来 的 同 事 吗
session_001 1 SPK02 2.40 4.10 是 的 我 今 天 第 一 天 报 到
session_001 1 SPK01 4.20 6.00 欢 迎 加 入 有 任 何 问 题 都 可 以 找 我
session_002 1 SPK01 0.00 1.90 我 们 下 午 三 点 开 会 讨 论 项 目 进 度
```

A few practical notes:

- Use the **session id of the original audio file** (typically the wav filename without extension) as `session_id`.
- All sessions present in the reference must also appear in the hypothesis — see the [Failure rules](#failure-rules) section.
- Sessions across the two tracks can be put into a single `hyp.stm` or split into two files; both work as long as the session ids stay consistent with the reference.

### Running the scoring

Once your system has produced `hyp.stm`, run:

```bash
bash run.sh
```

By default `run.sh` reads `example/ref.stm` and `example/hyp.stm`. To score your own files, either edit the `REF` / `HYP` defaults at the top of `run.sh`, or override them on the command line:

```bash
REF=/path/to/ref.stm HYP=/path/to/hyp.stm bash run.sh
```

The script invokes three MeetEval commands:

```bash
# Diarization Error Rate, computed via dscore (md-eval-22)
meeteval-der dscore  -r ref.stm -h hyp.stm --collar .25

# Concatenated minimum-Permutation WER (no time constraint)
meeteval-wer cpwer   -r ref.stm -h hyp.stm

# Time-Constrained minimum-Permutation WER — primary ranking metric
meeteval-wer tcpwer  -r ref.stm -h hyp.stm --collar .25
```

The `--collar` parameter controls the time tolerance (in seconds) when matching reference and hypothesis utterances. The official setting is **0.25 s** for both DER and tcpWER and must not be changed for valid submissions. Each command writes a JSON result file next to `hyp.stm` (e.g. `hyp_tcpwer.json`) and prints a one-line summary to stdout.

## Results

The numbers below are produced on the public dev set with [VibeVoice](https://github.com/microsoft/VibeVoice) as the front-end TTS used to construct part of the simulated overlap, and a baseline TSA-ASR pipeline. **They are placeholders** — final baseline numbers will be released together with the test set.

| Track | Setting | DER (%) | cpWER (%) | tcpWER (%) |
|---|---|:---:|:---:|:---:|
| Track 1 (Dyadic) | VibeVoice baseline | 18.7 | 32.4 | 38.1 |
| Track 2 (Meeting) | VibeVoice baseline | 24.5 | 41.2 | 47.6 |

More baselines (front-ends, beamforming variants, end-to-end systems, and multi-channel systems) will be added to this table over the next few weeks. Stay tuned.

## Failure rules

A submission is considered **valid** for the TSA-ASR task only if:

1. Every audio session in the official test set has a corresponding result in the submitted file. Missing sessions are not tolerated and will fail the whole submission.
2. The submitted file can be parsed as an `hyp.stm` file with the layout described in [Input format](#input-format) — no extra columns, no missing fields, no malformed timestamps. Any unparseable line invalidates the submission.
3. The exact submission format (file name, packaging, optional metadata) will be announced before the test phase opens. Submissions that cannot be loaded by the organisers' scoring pipeline will be rejected and not ranked.

In short: every test audio must have a result, and that result must round-trip through MeetEval without errors. Anything else is treated as a failed submission.

## Acknowledgement

The metrics and reference implementations come from [MeetEval](https://github.com/fgnt/meeteval). Please cite their work if you use this scoring toolkit in a publication.
