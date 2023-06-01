## Customize AWS WAF rate-based rule blocking period 

This solution helps to customize the block period for an AWS WAF rate-based rule to prevent malicious actors from reusing the same set of IP addresses for generating HTTP request floods. By blocking the IPs for longer durations and restricting the malicious users from reusing the IPs, the rate-based rules can be made more effective against HTTP request floods.

## Solution overview and architecture

This solution lets you configure the time period for which you want the originating IP address to be blocked if it has previously violated the configured threshold for the rate-based rule.
- It works with both IPv4 and IPv6 traffic.
- It blocks the IP addresses blocked by a rate-based rule for a configurable time period.
- The solution blocks a maximum of 10000 IPs for both IPv4 and IPv6 at a time.
- The solution might release the blocked IP address up to 45 seconds earlier or later than the configured block period.

## Architecture overview 

![Architecture Diagram for the customize rate-based rule blocking period solution](https://github.com/aws-solutions/aws-waf-security-automations/blob/main/architecture-diagram/architecture_diagram.png)

## Deploying the solution

The solution assumes that you’ve previously set up an AWS WAF WebACL with a rate-based rule. If you have not done so, then follow the instructions for creating [AWS WAF Rate-Based Rule.](https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based.html)

Create a CloudFormation stack using the [template](https://github.com/aws-solutions/aws-waf-security-automations/blob/main/cloudformation-template/aws-waf-rate-based-rule-customized-block-period-template.yaml) in the AWS Region where your WebACL is deployed. 
*Note:* To use this solution with a WebACL associated with Amazon CloudFront, deploy the stack in the US East (N. Virginia) Region.

Provide the following parameters while launching the stack:
- Custom Block Period: Specify the time in minutes to keep the IP address blocked
- Rate-Based Rule Name: Existing rate-based rule’s name
- Scope: CLOUDFRONT or REGIONAL
- WebACL Id: Existing WebACL Id.
- Web ACL Name: Existing WebACL name

The template spins up multiple cloud resources, such as the following:
- AWS WAF IPSets
- Amazon EventBridge Rule 
- Amazon S3 bucket 
- AWS Identity and Access Management (IAM) Role
- AWS Lambda Function

The solution is quickly deployed to your account and is ready to use in less than 15 minutes. Once the stack status changes to CREATE_COMPLETE the next step is to create a custom AWS WAF rule to block the IPs present in the IPSet created by the template:
*Note:* You must make sure that the IP field for this rule (source IP address or IP address in header) is same as your rate-based rule.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.