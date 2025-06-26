# Customize AWS WAF rate-based rule blocking period 

This solution helps to customize the block period for an AWS WAF rate-based rule to prevent malicious actors from reusing the same set of IP addresses for generating HTTP request floods. By blocking the IPs for longer durations and restricting the malicious users from reusing the IPs, the rate-based rules can be made more effective against HTTP request floods.

## Solution overview

This solution lets you configure the time period for which you want the originating IP address to be blocked if it has previously violated the configured threshold for the rate-based rule.
- It works with both IPv4 and IPv6 traffic.
- It blocks the IP addresses blocked by a rate-based rule for a **configurable time period**. Minimum block period is 06 minutes. 
- The solution blocks a maximum of 10000 IPs for both IPv4 and IPv6 at a time.
- The solution might release the blocked IP addresses with a delay of up to 75 seconds than the configured block period.

## Deploying the solution

The solution assumes that you’ve previously set up an AWS WAF WebACL with a rate-based rule. If you have not done so, then follow the instructions for creating [AWS WAF Rate-Based Rule.](https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based.html)

Create a CloudFormation stack using the [template](https://github.com/aws-samples/aws-waf-rate-based-rule-customized-block-period/blob/main/cloudformation-template/customized-block-period-template.yaml) in the AWS Region where your WebACL is deployed. 

**Note:** To use this solution with a WebACL associated with Amazon CloudFront, deploy the stack in the US East (N. Virginia) Region.

Provide the following parameters while launching the stack:
- Custom Block Period: Specify the time in minutes to keep the IP address blocked, minimum is 06 minutes
- Rate-Based Rule Name: Existing rate-based rule’s name
- Scope: CLOUDFRONT or REGIONAL
- WebACL Id: Existing WebACL Id
- Web ACL Name: Existing WebACL name

The template spins up multiple cloud resources, such as the following:
- AWS WAF IPSets
- Amazon EventBridge Rule 
- Amazon S3 buckets 
- AWS Identity and Access Management (IAM) Role
- AWS Lambda Function

The solution is quickly deployed to your account and is ready to use in less than 15 minutes. Once the stack status changes to CREATE_COMPLETE the next step is to create a custom AWS WAF rule to block the IPs present in the IPSet created by the template.

**Note:** You must make sure that the IP field for this rule (source IP address or IP address in header) is same as your rate-based rule.

## Validating the solution

Once solution is deployed, you can run a validation test using the [bash script](https://github.com/aws-samples/aws-waf-rate-based-rule-customized-block-period/blob/main/validation-script/customized-block-period-validation-script.sh) which generates a flood of HTTP GET requests at the beginning to the specified test URL, and then sends a request every 3 seconds to check the IP block status. It measures the time for which the source IP was blocked by calculating the time difference between the first and the last request with the 403 Forbidden status code.

**Prerequisites** before using this script: 
1. Make sure that your test URL returns a 200 status code by using the following command:
```
curl -s -o /dev/null -w "%{http_code}\n" http://example.com
```                         
**Note:** Ensure to replace the URL in the command with your own test URL.

2. Make sure that the rate-based rule and the custom rule doesn't have a custom response code set, as the validation script expects a 403 status code on getting blocked by AWS WAF.

3. Set the rate-based rule’s threshold limit to around 150 requests per 5 minutes for using this script.

To execute this script, use the following commands from a Linux terminal. In the second command below, replace the given URL with your test URL:
```
[ec2-user@ip-10-0-0-89 ~]$ chmod +x customized-block-period-validation-script.sh
[ec2-user@ip-10-0-0-89 ~]$ ./customized-block-period-validation-script.sh http://example.com
Completed 10 requests without block
Completed 20 requests without block
Completed 30 requests without block
……
Completed 820 requests without block
Completed 830 requests without block
Your IP is blocked now
Your IP is blocked now
2023-06-03 17:22:27 HTTP Status Code= 403
2023-06-03 17:22:28 HTTP Status Code= 403
……
2023-06-03 18:02:16 HTTP Status Code= 403
2023-06-03 18:02:19 HTTP Status Code= 403
Your IP was blocked for around: 10 minutes 25 seconds
```
For this validation test, I had specified the custom block period as 10 minutes while deploying the solution and as my source IP was blocked for around 10 minutes 25 seconds which is within the expected range of variance in block period by the solution(a delay of up to 75 seconds than the configured block period). Therefore the solutions works as expected.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.