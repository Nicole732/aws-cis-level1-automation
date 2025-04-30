#!/bin/bash
aws sns publish --topic-arn "${aws_sns_topic.current_contact_details.arn}"  
    --subject "Update Your AWS Contact Information"  
    --message "Hi! Please ensure your AWS account contact details are up-to-date as per CIS AWS Foundations Benchmark 1.1"   

