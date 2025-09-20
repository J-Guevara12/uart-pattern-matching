# AI Agent Usage

This file contains a reconstruction of the prompts given to the AI agent during the development and debugging of the UART Pattern Matching FSM project.

Unfortunately, part of the prompts were lost an as I'm using the gemini API under the hood I was unable to retrieve them, being that the reason behind the first prompt.

## Prompt History

1.  `do you remember the latest prompts over this folder?`
2.  `Is there any way to query it?`
3.  `Well, please then start by reading the assignment.md and the rest of the files of this directory to update your context, after that share with me your understandig of this project`
4.  `First thing I need you to do is to document the sipo_reg module, include the image and follow the structure of the other modules, explain the test case selection criteria and discuss the results`
5.  `yes, we shall` (In response to "Shall we create the `detector.v` module first?")
6.  `6` (In response to "what is the last digit of your student ID?")
7.  `before that, we'll docuemnt that case in the README, take into account the images/ folder`
8.  `yes` (In response to "Shall I proceed with creating the `top.v` module?")
9.  `Please include at least other 5 test cases, including edge cases and what could be unexpected behavior`
10. `There's not documentation of the top module, do it and a general description of the system, also clean the testbench. Finally dump all the prompts I've given to you in a ai_agent_usage.md file`

## Strategy

Using Gemini CLI the strategy was to let it create the boilerplate or base code for each of the modules with it's test bench and initial documentation, then manually reiterate over it, tweaking its parameters or when a new module behavior conflicted with it.
