The test script is a framework for the control of test case execution.

To learn more start with execution of help and man:

./bin/runTTF --help

and

./bin/runTTF --man

In directory samples you can see the Test Collection ANewTest, which is a sample for a basic Test Collection

It is recommended to enter the location of the test framework into your PATH like:

export PATH="<location of test framework>/bin:$PATH"

Whats new:
----------
Version 0.2.0:
- Dummy Suite support: Test cases can be defined without suite context.
- Test collection now requires a TestCollection.sh file and the TestProperties file is now optional
- Installer
- New global initialization in streamsutils
- Use variables for sab file main composite ..
- New test cases
- Streams sample

