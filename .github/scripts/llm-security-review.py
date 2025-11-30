#!/usr/bin/env python3
import boto3
import json
import sys
from datetime import datetime

def review_terraform_plan(plan_output):
    """Use Claude via Bedrock to review Terraform plan for security issues"""
    
    bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')
    
    prompt = f"""You are a security expert reviewing Terraform infrastructure code. Analyze this Terraform plan and provide a security assessment.

TERRAFORM PLAN:
{plan_output}

Evaluate the following security aspects:
1. IAM permissions - Are they following least privilege?
2. Network security - Are resources properly isolated?
3. Encryption - Is data encrypted at rest and in transit?
4. Public exposure - Are any resources unnecessarily public?
5. Resource limits - Are there appropriate constraints?
6. Compliance - Does it follow AWS best practices?

Provide your response in this exact JSON format:
{{
  "decision": "APPROVED" or "DENIED",
  "risk_level": "LOW", "MEDIUM", or "HIGH",
  "security_score": 0-100,
  "findings": [
    {{"severity": "INFO|LOW|MEDIUM|HIGH|CRITICAL", "issue": "description", "recommendation": "fix"}}
  ],
  "summary": "brief explanation of decision"
}}

Be strict but fair. Approve if security is acceptable with minor issues. Deny if critical security flaws exist."""

    try:
        response = bedrock.invoke_model(
            modelId='anthropic.claude-3-5-haiku-20241022-v1:0',
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 2000,
                "messages": [{
                    "role": "user",
                    "content": prompt
                }]
            })
        )
        
        result = json.loads(response['body'].read())
        content = result['content'][0]['text']
        
        # Extract JSON from response
        json_start = content.find('{')
        json_end = content.rfind('}') + 1
        review_data = json.loads(content[json_start:json_end])
        
        return review_data
        
    except Exception as e:
        print(f"Error calling Bedrock: {e}")
        # Fail-safe: deny on error
        return {
            "decision": "DENIED",
            "risk_level": "HIGH",
            "security_score": 0,
            "findings": [{"severity": "CRITICAL", "issue": f"LLM review failed: {str(e)}", "recommendation": "Manual review required"}],
            "summary": "Automated review failed - manual approval needed"
        }

def create_review_log(review_data, plan_output):
    """Create detailed log file of the review"""
    
    timestamp = datetime.utcnow().isoformat()
    
    log_content = f"""
================================================================================
TERRAFORM SECURITY REVIEW LOG
================================================================================
Timestamp: {timestamp}
Reviewer: Amazon Bedrock Claude 3.5 Haiku
Decision: {review_data['decision']}
Risk Level: {review_data['risk_level']}
Security Score: {review_data['security_score']}/100

================================================================================
EXECUTIVE SUMMARY
================================================================================
{review_data['summary']}

================================================================================
SECURITY FINDINGS
================================================================================
"""
    
    for idx, finding in enumerate(review_data['findings'], 1):
        log_content += f"""
Finding #{idx}
  Severity: {finding['severity']}
  Issue: {finding['issue']}
  Recommendation: {finding['recommendation']}
"""
    
    log_content += f"""
================================================================================
TERRAFORM PLAN ANALYZED
================================================================================
{plan_output}

================================================================================
END OF REVIEW
================================================================================
"""
    
    with open('security-review.log', 'w') as f:
        f.write(log_content)
    
    print(f"✅ Review log saved to security-review.log")

def main():
    if len(sys.argv) < 2:
        print("Usage: llm-security-review.py <terraform-plan-file>")
        sys.exit(1)
    
    plan_file = sys.argv[1]
    
    try:
        with open(plan_file, 'r') as f:
            plan_output = f.read()
    except FileNotFoundError:
        print(f"❌ Error: Plan file '{plan_file}' not found")
        sys.exit(1)
    
    print("🤖 Starting LLM security review...")
    print("📋 Analyzing Terraform plan with Amazon Bedrock Claude...")
    
    review_data = review_terraform_plan(plan_output)
    
    print(f"\n{'='*80}")
    print(f"SECURITY REVIEW RESULT")
    print(f"{'='*80}")
    print(f"Decision: {review_data['decision']}")
    print(f"Risk Level: {review_data['risk_level']}")
    print(f"Security Score: {review_data['security_score']}/100")
    print(f"Summary: {review_data['summary']}")
    print(f"{'='*80}\n")
    
    # Create detailed log
    create_review_log(review_data, plan_output)
    
    # Exit with appropriate code
    if review_data['decision'] == 'APPROVED':
        print("✅ APPROVED - Proceeding to deployment")
        sys.exit(0)
    else:
        print("❌ DENIED - Deployment blocked due to security concerns")
        print("\nFindings:")
        for finding in review_data['findings']:
            if finding['severity'] in ['HIGH', 'CRITICAL']:
                print(f"  [{finding['severity']}] {finding['issue']}")
        sys.exit(1)

if __name__ == '__main__':
    main()
