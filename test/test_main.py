import helper                    as f
import nose.tools                as nose
import validate_biobox_file.main as main

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

def test_validate_with_invalid_large_list():
    result = validate({"maxItems" : 2}, [1, 2, 3])
    f.assert_failure(result)
    nose.assert_equal(result.getValue(),
      "[1, 2, 3] is too long")

def test_validate_with_missing_properties():
    schema = {"properties": {"version": {}, "arguments": {}},
              "required"  : ["version", "arguments"]}
    input_ = {"version" : {}}
    result = validate(schema, input_)
    f.assert_failure(result)
    nose.assert_equal(result.getValue(), "'arguments' is a required property")

def test_check_mounted_files_with_list_having_missing_file():
    input_ = [{"fastq" : [
                {"id"    : "t",
                 "value" : "/path/to/file"}]}]
    result = main.check_mounted_files(f.create_biobox_dict(input_))
    f.assert_failure(result)
    nose.assert_equal(result.getValue(), "Provided path '/path/to/file' does not exist.")

def test_check_mounted_files_with_single_entry_having_missing_file():
    input_ = [{"fastq" :
               {"id"    : "t",
                "value" : "/path/to/file"}}]
    result = main.check_mounted_files(f.create_biobox_dict(input_))
    f.assert_failure(result)
    nose.assert_equal(result.getValue(), "Provided path '/path/to/file' does not exist.")

def test_check_mounted_files_with_single_entry_having_existing_file():
    input_ = [{"fastq" :
               {"id"    : "t",
                "value" : f.create_temp_file("")}}]
    result = main.check_mounted_files(f.create_biobox_dict(input_))
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), f.create_biobox_dict(input_))

def test_check_mounted_files_with_key_value_entries():
    input_ = {"sequences" :
                   {"id"    : "t",
                    "value" : f.create_temp_file("")}}
    result = main.check_mounted_files(f.create_biobox_dict(input_))
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), f.create_biobox_dict(input_))