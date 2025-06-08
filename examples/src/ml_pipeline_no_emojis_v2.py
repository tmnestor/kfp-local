"""
ML Data Processing Pipeline - KFP v2
4-step workflow demonstrating v1 to v2 migration
"""

from kfp import compiler, dsl


@dsl.component(base_image='python:3.9-slim')
def generate_data_op() -> str:
    """Step 1: Generate sample dataset"""
    import random
    
    print("=== DATA GENERATION STEP ===")
    
    # Generate sample data
    num_samples = 50
    temperatures = []
    
    for i in range(num_samples):
        temp = round(20 + random.gauss(0, 5), 2)  # Normal distribution around 20°C
        temperatures.append(temp)
    
    avg_temp = sum(temperatures) / len(temperatures)
    min_temp = min(temperatures)
    max_temp = max(temperatures)
    
    print(f"Generated {num_samples} temperature readings")
    print(f"Temperature range: {min_temp:.2f}°C to {max_temp:.2f}°C")
    print(f"Average temperature: {avg_temp:.2f}°C")
    print("Data generation completed!")
    
    return f"Generated {num_samples} samples, avg: {avg_temp:.2f}°C"


@dsl.component(base_image='python:3.9-slim')
def clean_data_op(data_summary: str) -> str:
    """Step 2: Clean and validate the data"""
    import random
    
    print("=== DATA CLEANING STEP ===")
    print(f"Processing data: {data_summary}")
    
    # Simulate data cleaning process
    total_records = 50
    outliers_found = random.randint(2, 5)
    valid_records = total_records - outliers_found
    
    print(f"Processing {total_records} records...")
    print(f"Found and removed {outliers_found} outliers")
    print(f"Clean dataset: {valid_records} valid records")
    print("Data cleaning completed!")
    
    return f"Cleaned data: {valid_records} valid records"


@dsl.component(base_image='python:3.9-slim')
def analyze_data_op(clean_data_summary: str) -> str:
    """Step 3: Perform statistical analysis"""
    import random
    
    print("=== DATA ANALYSIS STEP ===")
    print(f"Analyzing: {clean_data_summary}")
    
    # Simulate analysis results
    mean_temp = round(20 + random.gauss(0, 2), 2)
    std_dev = round(abs(random.gauss(3, 1)), 2)
    correlation = round(random.uniform(0.7, 0.95), 3)
    
    print("Statistical Analysis Results:")
    print(f"Mean temperature: {mean_temp}°C")
    print(f"Standard deviation: {std_dev}°C")
    print(f"Data correlation: {correlation}")
    print(f"Quality score: {correlation * 100:.1f}%")
    print("Statistical analysis completed!")
    
    return f"Analysis: mean={mean_temp}°C, std={std_dev}°C, quality={correlation*100:.1f}%"


@dsl.component(base_image='python:3.9-slim')
def generate_report_op(analysis_summary: str) -> str:
    """Step 4: Generate final report"""
    from datetime import datetime
    
    print("=== REPORT GENERATION STEP ===")
    print(f"Creating report from: {analysis_summary}")
    
    report = f"""
    ========================================
    ML DATA PROCESSING PIPELINE REPORT (v2)
    ========================================
    
    Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
    
    PIPELINE SUMMARY:
    Step 1: Data Generation - COMPLETED
    Step 2: Data Cleaning - COMPLETED  
    Step 3: Statistical Analysis - COMPLETED
    Step 4: Report Generation - COMPLETED
    
    WORKFLOW RESULTS:
    Multi-pod execution: SUCCESS
    KFP v2 data passing: OPERATIONAL
    Sequential workflow completed properly
    Data processing pipeline validated
    
    ML PIPELINE FEATURES DEMONSTRATED:
    KFP v2 @dsl.component decorators
    Automatic data passing via .output
    Independent container execution per step
    Sequential workflow orchestration
    Kubeflow Pipelines UI integration
    Production-ready ML workflow pattern
    
    ANALYSIS RESULTS:
    {analysis_summary}
    
    STATUS: KFP v2 PIPELINE SUCCESSFUL
    
    This demonstrates a working KFP v2 multi-step ML pipeline
    with automatic data passing between components!
    ========================================
    """
    
    print(report)
    print("KFP v2 ML pipeline completed successfully!")
    
    return "KFP v2 Pipeline execution completed successfully"


@dsl.pipeline(
    name='ml-pipeline-no-emojis-v2',
    description='ML data processing pipeline using KFP v2 syntax'
)
def ml_pipeline_v2() -> str:
    """
    4-step ML data processing pipeline using KFP v2:
    1. Generate sample sensor data
    2. Clean and validate data (with data from step 1)
    3. Perform statistical analysis (with data from step 2)
    4. Generate comprehensive report (with analysis from step 3)
    
    Each step runs in its own container with automatic data passing
    """
    
    # Step 1: Generate data
    data_task = generate_data_op()
    
    # Step 2: Clean data (receives output from step 1)
    clean_task = clean_data_op(data_summary=data_task.output)
    
    # Step 3: Analyze data (receives output from step 2)
    analysis_task = analyze_data_op(clean_data_summary=clean_task.output)
    
    # Step 4: Generate report (receives output from step 3)
    report_task = generate_report_op(analysis_summary=analysis_task.output)
    
    # Return final output
    return report_task.output


if __name__ == "__main__":
    print("Compiling ML Pipeline (KFP v2)...")
    compiler.Compiler().compile(
        pipeline_func=ml_pipeline_v2,
        package_path="ml_pipeline_no_emojis_v2.yaml"
    )
    print("KFP v2 ML Pipeline compiled successfully!")
    print("Output: ml_pipeline_no_emojis_v2.yaml")
    print("Key v2 improvements:")
    print("- @dsl.component decorators")
    print("- Automatic data passing between steps")
    print("- Enhanced type safety with return annotations")
    print("- Simplified pipeline orchestration")
    print("Ready for upload to KFP UI!")