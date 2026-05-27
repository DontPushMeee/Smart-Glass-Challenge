# SLT 2026 SmartGlasses Challenge: Official Evaluation Toolkit

## Introduction
Welcome to the official evaluation toolkit for the SLT 2026 SmartGlasses Challenge. This challenge focuses on advancing speech processing technologies in the context of smart glasses, aiming to solve real-world problems in wearable scenarios. 

This repository provides the evaluation scripts and guidelines for the **TSA-ASR (Target Speaker Automatic Speech Recognition)** task, which corresponds to **Task 1 in both Track 1 and Track 2**.

## Installation
The evaluation toolkit relies on `meeteval` for calculating metrics such as DER, cpWER, and tcpWER. To install the required dependencies, please run:

```bash
pip install meeteval
```
For more detailed installation instructions or troubleshooting regarding `meeteval`, please refer to the [official meeteval repository](https://github.com/fgnt/meeteval).

## Usage & Input Format
To evaluate your model's predictions, you need to provide the hypothesis file in the standard **STM (Segment Time Mark)** format. 

### STM Format Requirements
The STM file should be organized with the following fields separated by spaces:
`[filename] [channel] [speaker_id] [start_time] [end_time] [transcript]`

**Important Note for Chinese Transcripts:** 
For Chinese characters, you must insert a space between each character in the transcript to ensure correct Word Error Rate (WER) calculation. For example, "你好世界" should be formatted as "你 好 世 界".

### Example
You can find example reference and hypothesis files in the `example/` directory.

### Running the Evaluation
You can use the provided `run.sh` script to calculate the metrics. The script includes examples of how to set the parameters for different metrics:

```bash
bash run.sh
```
The script calculates:
- **DER (Diarization Error Rate)** and **D-Score** using `meeteval-der dscore`
- **cpWER (Concatenated Minimum-Permutation Word Error Rate)** using `meeteval-wer cpwer`
- **tcpWER (Time-Constrained Minimum-Permutation Word Error Rate)** using `meeteval-wer tcpwer`

## Current Baseline Results
Below are the current baseline results for Track 1 & 2 on the ViboVoice ASR dataset. We currently provide DER (D-Score), cpWER, and tcpWER metrics. **More test results will be released and updated here in the future.**

| Track | Scenario | cpWER (%) | tcpWER (%) | D-Score Error Rate (%) |
|-------|----------|-----------|------------|------------------------|
| Track 1 | Chat | 15.50 | 15.95 | 9.90 |
| Track 2 | Meet | 30.72 | 31.56 | 17.39 |

*(Note: The error rates are presented as percentages.)*

## Failure Rules (Fail Criteria)
For the TSA-ASR task, **all audio files must have corresponding results** and must be successfully parsed into the `hyp.stm` format. 
In the future, we will release the exact required submission format for the organizers to parse. **Any submission that fails to be parsed correctly will be considered an invalid result.**

## SLU Task Evaluation
For the time being, participating teams can evaluate their SLU models locally by simply calculating the **Accuracy** (i.e., the percentage of correctly answered multiple-choice questions) against the provided Dev set references. Since the metric is straightforward, a unified evaluation script is not provided at this stage.

We will release the standardized submission format requirements and integrate the official SLU scoring pipeline into this repository well before the test phase and leaderboard submission open. Please stay tuned.
