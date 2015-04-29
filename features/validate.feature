Feature: Validate the biobox file
  In order for developers to build bioboxes
  The validate-biobox-file provides useful errors if the given file in invalid
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
      usage: validate-biobox-file [-h] --schema SCHEMA_FILE --input INPUT_FILE
      validate-biobox-file: error: argument <arg> is required

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
      | error      | valid      |
      | schema.yml | input.yml  |
      | input.yml  | schema.yml |


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
      '<missing>' is a required property\n
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
      ['item', 'item', 'item'] is too long\n
      """
     And the exit status should be 1


  Scenario Outline: The specified <type> file is missing
   Given a file named "input.yml" with:
      """
      ---
        version: 0.9.0
        arguments:
          - <type>:
            - id: "pe"
              value: "missing_file"
              type: paired
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
      Provided path 'missing_file' in item 'pe' does not exist.
      """
     And the exit status should be 1

    Examples:
      | type  |
      | fastq |
      | fasta |


  Scenario: The inner input yaml is invalid
   Given a file named "input.yml" with:
      """
      ---
        version: 0.9.0
        arguments:
          - invalid_fastq:
            - id: "pe"
              value: "example.fa"
              type: paired
      """
     And a file named "schema.yml" with:
      """
      ---
      $schema: "http://json-schema.org/draft-04/schema#"
      title: "Bioboxes short read assembler input file validator"
      type: "object"
      properties: 
          version: 
            type: "string"
            pattern: "^0.9.\\d+$"
          arguments: 
            type: "array"
            minItems: 1
            maxItems: 2
            items: 
              oneOf: 
                - 
                  $ref: "#/definitions/fastq"
                - 
                  $ref: "#/definitions/fragment"
      required: 
          - "version"
          - "arguments"
      additionalProperties: false
      definitions: 
          fastq: 
            type: "object"
            additionalProperties: false
            required: 
              - "fastq"
            properties: 
              fastq: 
                $ref: "#/definitions/values"
          fragment: 
            type: "object"
            additionalProperties: false
            properties: 
              fragment_size: 
                $ref: "#/definitions/values"
          values: 
            type: "array"
            uniqueItems: true
            minItems: 1
            items: 
              type: "object"
              additionalProperties: false
              required: 
                - "id"
                - "value"
              properties: 
                id: {}
                type: {}
                value: {}
      """
     And an empty file named "example.fa"
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the exit status should be 1

  Scenario Outline: The input file is valid
   Given a file named "input.yml" with:
      """
      ---
        version: 0.9.0
        arguments:
          - <type>:
            - id: "pe"
              value: "example_file"
              type: paired
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
     And an empty file named "example_file"
    When I run the bash command:
      """
      ${BINARY} --schema=schema.yml --input=input.yml
      """
    Then the stdout should not contain anything
     And the stderr should not contain anything
     And the exit status should be 0

    Examples:
      | type  |
      | fastq |
      | fasta |
