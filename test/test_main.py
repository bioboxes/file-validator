import helper              as f
import nose.tools          as nose
import validate_input.main as main

def test_loading_valid_yaml():
    file_  = f.create_temp_file("---\n- valid yaml")
    result = main.parse_yaml(file_)
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), ["valid yaml"])

def test_loading_invalid_yaml():
    file_  = f.create_temp_file("'invalid yaml")
    result = main.parse_yaml(file_)
    f.assert_failure(result)
