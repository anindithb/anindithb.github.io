---
title: Guidance for Developing Applications Using Generative AI with Amazon CodeWhisperer
summary: Use this Guidance to learn how CodeWhisperer can improve your code development productivity with different use cases
published: true
hide_sidebar: false
sidebar: codewhisperer_sidebar
permalink: ai-ml/developing-applications-using-generative-ai-with-amazon-codewhisperer.html
folder: guides
tags: aiml
layout: page
---

---

This Guidance aims to familiarize users with a machine learning-powered code generator to assist and improve their development productivity. It demonstrates how CodeWhisperer can generate code for various development-related uses such as unit testing, and creating and integrating with AWS resources.

## Starting CodeWhisperer

Use the following documentation to get CodeWhisperer configured for your development environment:

 * [Setting Up](https://docs.aws.amazon.com/codewhisperer/latest/userguide/setting-up.html){:target="_blank"} - steps needed before using CodeWhisperer for the first time.
 * [Getting Started](https://docs.aws.amazon.com/codewhisperer/latest/userguide/getting-started.html){:target="_blank"} - how to set up CodeWhisperer with each of the supported integrated development environments (IDEs).


## Use Case: Automate unit test generation (Python)

CodeWhisperer can offload writing repetitive unit test code. Based on natural language comments, CodeWhisperer automatically recommends unit test code that matches your implementation code. In the snippets below,
you will see how CodeWhisperer can assist developers with automatic generation of unit tests to improve code coverage.

1.  Open an empty directory in your IDE, such as Visual Studio Code. For this use case, we used Python in Visual Studio Code.

{: .note }
CodeWhisperer uses artificial intelligence (AI) to provide code recommendations that are non-deterministic. The code suggestions that CodeWhisperer generates in your development session may vary.

{:style="counter-reset:none"}
2.  (Optional) In the terminal, create a new Python virtual environment:

```shell
python3 -m venv .venv
source .venv/bin/activate
```

{:style="counter-reset:none"}
3.  Install basic testing libraries:

```shell
pip install pytest pytest-cov
```

{:style="counter-reset:none"}
4.  Create a new file named **calculator.py**

5.  Insert the following comment at the beginning of the file to start
    building a simple calculator class, and then select **Enter**:
    
```
# example Python class for a simple calculator
```

CodeWhisperer will then start making suggestions to generate new code.

{:style="counter-reset:none"}
6.  To accept these suggestions, select **Tab**. 

{% include image.html file="CodeWhisperer/CW_Figure6.gif"%}

<!--[](media/image6.gif){width="6.5in" height="4.189583333333333in"}-->

*Figure 6 - Building a simple calculator class*

If CodeWhisperer does not automatically make a suggestion, you can
manually trigger CodeWhisperer with **Alt + C** for Windows/Linux, or
**Option + C** for macOS. Additional suggestions can be viewed by
selecting the **Right** arrow key. To see previous suggestions, select
the **Left** arrow key. To reject a recommendation, select **ESC** or
the **backspace/delete** key.

Continue building the calculator class by selecting the **Enter** key
and accepting CodeWhisperer suggestions (automatically or manually).
CodeWhisperer will suggest basic functions for the calculator class,
such as add(), subtract(), multiply(), and divide(). It can also suggest
more advanced functions such as square(), cube(), and square_root().

```python
# example Python class for a simple calculator

class Calculator:
# add two numbers
def add(self, a, b):
 return a + b

# subtract two numbers
def subtract(self, a, b):
 return a - b

# multiply two numbers
def multiply(self, a, b):
 return a * b

# divide two numbers
def divide(self, a, b):
 return a / b

# square a number
def square(self, a):
 return a * a

# cube a number
def cube(self, a):
 return a * a * a

# square root a number
def square_root(self, a):
 return a ** 0.5

# cube root a number
def cube_root(self, a):
 return a ** (1/3)
```

**Automate the generating** **of** **unit tests**

Now, let's run some tests to examine code coverage. Enter:
```shell
pytest ---cov=.
```
And you will likely see:

{% include image.html file="CodeWhisperer/CW_Figure7.png"%}

*Figure 7 - Displays 'no tests ran'*

<!--[](media/image7.png){width="6.239583333333333in"height="3.7930555555555556in"}-->

That's right, we don't have any tests, nor do we have any code coverage!
Let's use CodeWhisperer to help us automatically generate unit tests,
and improve our code coverage.  

1.  Create a new file named **test_calculator**

2.  Insert the following code and comment at the beginning of the file
    to start building unit tests for the Calculator class, and then
    select **Enter**:

```python
import pytest from calculator import Calculator

# fixture for calculator
```

{% include image.html file="CodeWhisperer/CW_Figure8.gif"%}

<!--[](media/image8.gif){width="6.5in" height="6.597916666666666in"}-->

*Figure 8 - Building unit tests for the Calculator class*

{:style="counter-reset:none"}
3.  Continue building the calculator class by pressing the **Enter** key
    and accepting CodeWhisperer suggestions (automatically or manually).
    CodeWhisperer will suggest unit tests with the previously
    implemented class as context.

```python
import pytestfrom calculator import Calculator

# fixture for calculator
@pytest.fixture
def calculator():
return Calculator()

# unit test for multiply()
def test_multiply(calculator):
assert calculator.multiply(2, 3) == 6

# unit test for divide()
def test_divide(calculator):
assert calculator.divide(6, 3) == 2
with pytest.raises(ZeroDivisionError):
calculator.divide(6, 0)

# unit test for add()
def test_add(calculator):
assert calculator.add(2, 3) == 5
assert calculator.add(2, -3) == -1
assert calculator.add(0, 0) == 0

# unit test for subtract()
def test_subtract(calculator):
assert calculator.subtract(2, 3) == -1
assert calculator.subtract(2, -3) == 5
assert calculator.subtract(0, 0) == 0

# unit test for square()
def test_square(calculator):
assert calculator.square(2) == 4
assert calculator.square(0) == 0
with pytest.raises(TypeError):
calculator.square("a")

# unit test for cube()
def test_cube(calculator):
assert calculator.cube(2) == 8
assert calculator.cube(0) == 0
with pytest.raises(TypeError):
calculator.cube("a")*
```

Let's try running our newly implemented unit tests to examine code
coverage. Enter:

```shell
pytest -cov=.
```

{% include image.html file="CodeWhisperer/CW_Figure9.png"%}

*Figure 9 - CodeWhisperer automatically generating the unit test methods*

<!--[](media/image9.png){width="6.236805555555556in"height="3.5381944444444446in"}-->

As you can see, CodeWhisperer was able to automatically generate the
unit test methods (including the appropriate assertion values),
increasing code coverage and reducing implementation time.

## Use Case: Build applications using AWS services

Builders can speed up the development process for their applications with code recommendations for AWS APIs across the most popular services, including Amazon Elastic Compute (Amazon EC2), AWS Lambda, and Amazon Simple Storage Service (Amazon S3). CodeWhisperer can analyze and suggest custom AWS resources tailored to the context you provide.

1.  Open an empty directory in your IDE, such as Visual Studio Code or JetBrains. For this use case, we used Python in JetBrains PyCharm IDE.

{: .note }
CodeWhisperer uses AI to provide code recommendations that are non-deterministic. The code suggestions that CodeWhisperer generates in your development session may vary.

{:style="counter-reset:none"}
2.  (Optional) In the terminal, create a new Python virtual environment:

```shell
python3 -m venv .venv
source .venv/bin/activate
```

{:style="counter-reset:none"}
3.  Install basic software development kit (SDK) libraries:

```shell
pip install boto3
```

{:style="counter-reset:none"}
4.  Open a new or existing Python file, and try a few of the examples
    below.

**Examples**

### Generating custom IAM policies

```
# create an IAM policy with read and write access to S3
```

{% include image.html file="CodeWhisperer/CW_Figure10.gif"%}

<!--[](media/image10.gif){width="6.5in" height="6.663194444444445in"}-->

*Figure 10 - Creating an IAM policy with read and write access to Amazon S3*

### Paginating Results from SDK

```
# retrieve and iterate through paginated IAM users in account
```

{% include image.html file="CodeWhisperer/CW_Figure11.gif"%}

<!--[](media/image11.gif){width="6.5in" height="2.3819444444444446in"}-->

*Figure 11 - Retrieving and iterating through paginated IAM users*

### Creating encryption-enabled resources

```
# create bucket with server-side encryption enabled
```

{% include image.html file="CodeWhisperer/CW_Figure12.gif"%}

<!--[](media/image12.gif){width="6.5in" height="1.8784722222222223in"}-->

*Figure 12 - Creating bucket with server-side encryption*

### Creating database schemas

```
# create DynamoDB table for users using email as primary key and date created as sort key
```

{% include image.html file="CodeWhisperer/CW_Figure13.gif"%}

<!--[](media/image13.gif){width="6.5in" height="7.129861111111111in"}-->

*Figure 13 - Creating Amazon DynamoDB table*
