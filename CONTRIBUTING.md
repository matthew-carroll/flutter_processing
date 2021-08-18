# Contributing
Thanks for your interest in contributing to flutter_processing. This guide describes the expectations for all contributors working on the flutter_processing project.

## Filing dev experience complaints
flutter_processing aims to provide a similar value as the traditional Processing project, but with Flutter as the substrate. If you think flutter_processing made poor API decisions, feel free to express that concern in a ticket.

Please make sure to clearly explain why the API should be changed from what it is now, to what you want it to be.

Developers who triage these issues should apply the "api design" tag.

## Filing Bugs
Before filing a bug, check existing issues to avoid duplicate tickets.

All bug issues must include at least the following elements:

 * A description of the problem
 * The minimum code required to reproduce the problem
 * The expected behavior of flutter_processing
 * The actual behavior of flutter_processing

This information is needed to effectively reproduce and fix a bug. Any bug filed without the above information will be closed.

## Filing Feature Requests
In general, flutter_processing will not implement features that do not exist within Processing, itself. Occasionally, this rule may be exempted, but there is no guarantee that a non-Processing behavior will be accepted into flutter_processing.

Before filing a feature request, check the existing tickets to avoid duplicate issues.

If you'd like flutter_processing to implement a missing Processing API, file a ticket with a description that explains why you need that API.

## Working on bug fixes
Bugs are typically pretty simple to fix. If you find a bug ticket that you'd like to work on, tag @matthew-carroll to assign the ticket to you.

To avoid duplicated work, don't work on an issue until it's assigned to you.

All bug fixes should include effective tests.

## Working on new features
All work requires a corresponding issue ticket. Work on a ticket only if it's assigned to you. Only ask for a ticket assignment if you're ready to work on it immediately.

Simple and obvious implementations don't require any proposals. You can implement them directly.

Features that touch multiple areas and/or require API changes should begin with a proposal for how you plan to implement it. Upon approval, you can implement that proposal and submit a pull request.

All new features should include effective tests.

## Pull requests
To merge your changes into flutter_processing, submit a pull request.

Request a review by @matthew-carroll.

A PR that does not have an associated issue ticket will not be accepted.

A PR without tests will not be accepted (with rare exceptions).

A PR for work that is currently assigned to someone else will not be accepted.