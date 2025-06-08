"""
KFP v2 Multi-Step Pipeline - Converted from v1
"""

from kfp import compiler, dsl


@dsl.component(base_image='python:3.9-slim')
def step_a_op() -> str:
    """Step A: Generate a simple message."""
    print("Step A executing: Hello from Step A")
    return "Hello from Step A"


@dsl.component(base_image='python:3.9-slim')
def step_b_op(message_from_a: str) -> str:
    """Step B: Process message from Step A.""" 
    print(f"Step B executing: Received '{message_from_a}'")
    print("Step B executing: Hello from Step B")
    result = f"Step B processed: {message_from_a}"
    print(f"Step B result: {result}")
    return result


@dsl.component(base_image='python:3.9-slim')
def step_c_op(message_from_b: str) -> str:
    """Step C: Final step with data from previous steps."""
    print(f"Step C executing: Received '{message_from_b}'")
    print("Step C executing: Hello from Step C - Pipeline Complete!")
    print("Multi-step KFP v2 pipeline completed successfully!")
    final_result = f"Step C final: {message_from_b} -> Pipeline Complete!"
    print(f"Final result: {final_result}")
    return final_result


@dsl.pipeline(
    name='v2-multi-step-pipeline',
    description='KFP v2 multi-step pipeline with data passing'
)
def v2_pipeline() -> str:
    """Multi-step pipeline using KFP v2 syntax with automatic data passing."""
    
    # Step A
    task_a = step_a_op()
    
    # Step B (receives output from A)
    task_b = step_b_op(message_from_a=task_a.output)
    
    # Step C (receives output from B)
    task_c = step_c_op(message_from_b=task_b.output)
    
    # Return final result
    return task_c.output


if __name__ == "__main__":
    print("Compiling KFP v2 multi-step pipeline...")
    compiler.Compiler().compile(
        pipeline_func=v2_pipeline,
        package_path="v1_multi_step_v2.yaml"
    )
    print("KFP v2 pipeline compiled successfully!")
    print("Output: v1_multi_step_v2.yaml")
    print("v2 improvements:")
    print("- Automatic data passing between steps")
    print("- No need for .after() dependencies")
    print("- Type-safe component interfaces")