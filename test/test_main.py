import helper              as f
import nose.tools          as nose
import validate_input.main as main

from pymonad.Either      import Left, Right
from pymonad.Applicative import *

def validate(schema, input_):
    """
    Helper method to run validation
    """
    return Right(input_) >> (Right(schema) >> main.validate)

def test_loading_valid_yaml():
    file_  = f.create_temp_file("---\n- valid yaml")
    result = main.parse_yaml(file_)
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), ["valid yaml"])

def test_loading_invalid_yaml():
    file_  = f.create_temp_file("'invalid yaml")
    result = main.parse_yaml(file_)
    f.assert_failure(result)

def test_generate_exit_status():
    nose.assert_equal(main.generate_exit_status(Left("msg")),  (1, "msg\n"))
    nose.assert_equal(main.generate_exit_status(Right("msg")), (0, ""))

def test_validate_with_valid_data():
    result = main.validate({"maxItems" : 2}, [1, 2])
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), [1, 2])


def validate(schema, input_):
    return  Right(input_) >> (Right(schema) >> main.validate)

def test_validate_with_valid_data():
    result = validate({"maxItems" : 2}, [1, 2])
    f.assert_successful(result)

def test_check_mounted_files_with_not_existing_files():
    input_ = {
        "version" : "0.9.0",
        "arguments" : [
                {
                 "fastq" : [{
                     "id" : "t",
                     "value" : "/path/to/file",
                     "type": "paired"
                 }]
                }
              ]
    }
    result = main.check_mounted_files(input_)
    f.assert_failure(result)

def test_validate_with_invalid_large_list():
    result = validate({"maxItems" : 2}, [1, 2, 3])
    f.assert_failure(result)
    nose.assert_equal(result.getValue(),
      "Value [1, 2, 3] for field '<obj>' must have length less than or equal to 2")

def test_validate_with_missing_properties():
    schema = {"properties": {"version": {}, "arguments": {}},
              "required"  : ["version", "arguments"]}
    input_ = {"version" : {}}
    result = validate(schema, input_)
    f.assert_failure(result)
    nose.assert_equal(result.getValue(), "Required field 'arguments' is missing")
