"""
KFP 2.0 Tutorial Pipeline
Converting from v1 syntax to demonstrate the differences
"""

from kfp import compiler, dsl


@dsl.component(base_image='python:3.9-slim')
def say_hello(name: str) -> str:
    """Say hello to someone - KFP v2 syntax"""
    hello_text = f'Hello, {name}!'
    print(hello_text)
    return hello_text

@dsl.component(base_image='python:3.9-slim')  
def process_greeting(greeting: str) -> str:
    """Process the greeting - demonstrates v2 data passing"""
    processed = f"Processed: {greeting} (via KFP v2.0)"
    print(processed)
    return processed

@dsl.pipeline(
    name='hello-pipeline-v2',
    description='KFP v2 hello world pipeline with data passing'
)
def hello_pipeline_v2(recipient: str = 'World') -> str:
    """
    KFP v2 pipeline demonstrating:
    - @dsl.component decorator
    - Automatic data passing between components
    - Updated pipeline syntax
    """
    
    # Step 1: Say hello
    hello_task = say_hello(name=recipient)
    
    # Step 2: Process the greeting (demonstrates v2 data passing)
    process_task = process_greeting(greeting=hello_task.output)
    
    # Return final output
    return process_task.output

if __name__ == "__main__":
    print("Compiling KFP v2.0 Pipeline...")
    
    # Use KFP v2 compiler
    compiler.Compiler().compile(
        pipeline_func=hello_pipeline_v2,
        package_path='kfp_tutorial_v2.yaml'
    )
    
    print("KFP v2.0 Pipeline compiled successfully!")
    print("Output: kfp_tutorial_v2.yaml")
    print("Key v2 differences:")
    print("- @dsl.component decorator instead of create_component_from_func")  
    print("- Automatic data passing via .output")
    print("- Simplified pipeline return values")
    print("- Enhanced type safety")