Feature: Validate the input file for a biobox
  In order for developers to build bioboxes
  The validate-input provides useful errors if the input file in invalid
  So that the developer can return these errors to the user

  Scenario Outline: Arguments are missing
   Given an empty file named "thresholds.yml"
     And an empty file named "schema.yml"
    When I run the bash command:
      """
      ${BINARY} <arguments>
      """
    Then the stderr should contain exactly:
      """
      usage: validate-input [-h] --schema SCHEMA_FILE --input INPUT_FILE
      validate-input: error: argument <arg> is required

      """
     And the exit status should not be 0

    Examples:
      | arguments           | arg         |
      | --input=input.yml   | --schema/-s |
      | --schema=schema.yml | --input/-i  |

  Scenario Outline: Files are missing
   Given an empty file named "exists.yml"
    When I run the bash command:
      """
      ${BINARY} <arguments>
      """
    Then the stderr should contain exactly:
      """
      File not found: missing.yml

      """
     And the exit status should not be 0

    Examples:
      | arguments                               |
      | --input=missing.yml --schema=exists.yml |
      | --input=exists.yml --schema=missing.yml |


  Scenario Outline: The input file is not valid
   Given a file named "<error>" with:
      """
      'invalid yaml
      """
     And a file named "<valid>" with:
      """
      ---
        - valid yaml
      """
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the stdout should not contain anything
     And the stderr should contain exactly:
      """
      Error parsing the YAML file: <error>

      """
     And the exit status should be 1

    Examples:
      | error      | valid     |
      | schema.yml | input.yml |


  Scenario Outline: The input file is missing a property
   Given a file named "input.yml" with:
      """
      ---
        <key>: "value"
      """
     And a file named "schema.yml" with:
      """
      ---
      $schema: http://json-schema.org/draft-04/schema
      title: Bioboxes short read assembler input file validator
      type: object
      properties:
        version: {}
        arguments: {}
      required:
        - version
        - arguments
      """
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the stdout should not contain anything
     And the stderr should contain:
      """
      Required field '<missing>' is missing
      """
     And the exit status should be 1

    Examples:
      | key       | missing   |
      | version   | arguments |
      | arguments | version   |


  Scenario: The input file has too many items
   Given a file named "input.yml" with:
      """
      ---
      - item
      - item
      - item
      """
     And a file named "schema.yml" with:
      """
      ---
      $schema: http://json-schema.org/draft-04/schema
      title: Bioboxes short read assembler input file validator
      type: array
      maxItems: 2
      """
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the stdout should not contain anything
     And the stderr should contain:
      """
      must have length less than or equal to 2
      """
     And the exit status should be 1


  Scenario: The input file is valid
   Given a file named "input.yml" with:
      """
      ---
        version: "value"
        arguments: "value"
      """
     And a file named "schema.yml" with:
      """
      ---
      $schema: http://json-schema.org/draft-04/schema
      title: Bioboxes short read assembler input file validator
      type: object
      properties:
        version: {}
        arguments: {}
      required:
        - version
        - arguments
      """
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the stdout should not contain anything
     And the stderr should not contain anything
     And the exit status should be 0
