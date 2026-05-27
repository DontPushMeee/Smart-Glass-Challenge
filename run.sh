#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# SmartGlasses Challenge — TSA-ASR scoring script
#
# This script evaluates a system's hypothesis (hyp.stm) against the reference
# transcript (ref.stm) using the MeetEval toolkit. Three metrics are reported:
#   1) DER     — Diarization Error Rate
#   2) cpWER   — Concatenated minimum-Permutation Word Error Rate
#   3) tcpWER  — Time-Constrained minimum-Permutation Word Error Rate
#
# Usage:
#   bash run.sh                       # use the bundled example files
#   REF=path/to/ref.stm HYP=path/to/hyp.stm bash run.sh    # custom inputs
#
# Arguments used below:
#   -r / --reference   reference STM file (ground truth)
#   -h / --hypothesis  hypothesis STM file produced by your system
#   --collar           time tolerance (seconds) on segment boundaries
#                      0.25 s is the official setting for this challenge
# ---------------------------------------------------------------------------

REF=${REF:-example/ref.stm}
HYP=${HYP:-example/hyp.stm}

# 1. Diarization Error Rate (uses dscore / md-eval-22 under the hood)
meeteval-der dscore -r "${REF}" -h "${HYP}" --collar .25

# 2. cpWER — speaker-attributed WER without time constraint
meeteval-wer cpwer -r "${REF}" -h "${HYP}"

# 3. tcpWER — speaker-attributed WER with a 0.25 s time-alignment collar.
#    This is the primary ranking metric for the TSA-ASR task.
meeteval-wer tcpwer -r "${REF}" -h "${HYP}" --collar .25
