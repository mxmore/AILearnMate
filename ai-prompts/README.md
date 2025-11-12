# AI Prompts Library

This directory contains AI prompt templates for various tasks in the AILearnMate system.

## Prompt Categories

### 1. Knowledge Extraction
- Extract knowledge points from learning materials
- Identify key concepts and relationships
- Generate knowledge hierarchies

### 2. Question Generation
- Generate questions from knowledge points
- Create questions from text content
- Adapt question difficulty

### 3. Quality Assessment
- Evaluate question quality
- Assess difficulty appropriateness
- Check for clarity and accuracy

### 4. Answer Evaluation
- Grade subjective answers
- Provide detailed feedback
- Identify missing key points

## Usage

Each prompt template includes:
- Template text with placeholders
- Required variables
- Recommended model (GPT-4, Qwen3, etc.)
- Temperature and max_tokens settings
- Example outputs

## JSON Schema Validation

All AI-generated outputs follow strict JSON schemas defined in `schemas/` directory.

Use the validation scripts to ensure output quality:

```bash
python scripts/validate_ai_output.py --schema question --output output.json
```
